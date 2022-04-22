use application "polytope";
use warnings;
use JSON::Parse 'parse_json';

use File::Basename;


sub main {
  my $path_to_polytope_csv = $ARGV[0];
  my $output_filename = $ARGV[1];

  unless (open(INPUTFILE, $path_to_polytope_csv)) {
    print "Cannot read from '$path_to_polytope_csv'.\nProgram closing.\n";
    <STDIN>;
    exit;
  }

  # Read File and get Parameters from csv Header
  my @polytope_parameters = <INPUTFILE>;
  $polytope_parameters[0] =~ tr/\n//d;
  my @parameter_keys = split(",", $polytope_parameters[0]);
  
  my @polytopes = ();
  
  foreach my $line (@polytope_parameters[1..$#polytope_parameters]) {
    my @pairs = ();
    my $index = 0;

    # split each line into array of its values
    my @line_values = split(/,(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)/, $line);

    # remove quotes from vertices value
    $line_values[2] =~ tr/"//d;
    my $vertices = parse_json($line_values[2]);

    my $polytope = new Polytope(VERTICES=>$vertices);

    foreach my $key (@parameter_keys){
      # remove characters to satisfy JSON data format
      $line_values[$index] =~ tr/\n//d;
      $line_values[$index] =~ tr/"//d;
      $line_values[$index] =~ s/'/"/ig;

      # change characters in booleans to satisfy JSON data format
      $line_values[$index] =~ s/T/t/ig;
      $line_values[$index] =~ s/F/f/ig;

      if ($key && $key ne "PolytopeVertices") {
	# Parse the values to a value accepted by JSON
	my $value;
	eval {
	  $value = parse_json($line_values[$index]);

	} or do {
	  # handle funny error with square brackets
	  $line_values[$index] =~ s/]]/]/ig;
	  $value = $line_values[$index];
	};

	my $value_type = ref($value);

	if ($value_type eq "ARRAY") {
	  my $array_entry_type = ref(@$value[0]);

	  # this may need to be refactored to allow arbitrarily nested arrays
	  # but should be fine for now
	  if ($array_entry_type eq "ARRAY") {
	    #handle 2 dimensional array
	    my $first_entry = @$value[0];

	    if (ref(@$first_entry[0])) {
	      die "Error: csv files contains an array of dimension larger than 2"
	    }

	    $value = new Array<Array<Rational>>(\@$value);
	  } else {
	    # one dimensional array
	    if (defined(@$value[0]) && (@$value[0] !~ /^[0-9,.E]+$/)) {
	      # handle string arrays
	      $value = new Array<String>(\@$value);
	    } else {
	      $value = new Array<Rational>(\@$value);
	    }
	  }
	}

	$polytope->attach($key, $value);
      }

      $index++;
    }
    
    push @polytopes, $polytope;
  }
  my $polytope_array = new Array<Polytope>(\@polytopes);
  save_data($polytope_array, $output_filename, canonical=>true);
}

# run file with following command
# polymake --script csv_to_json.pl "/path/to/file.csv" "/path/to/output"
main();
