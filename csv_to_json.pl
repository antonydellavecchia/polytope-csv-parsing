use application "polytope";
use warnings;
use JSON::Parse 'parse_json';

use File::Basename;


sub main {
  my $path_to_polytope_csv = $ARGV[0];

  unless (open(INPUTFILE, $path_to_polytope_csv)) {
    print "Cannot read from '$path_to_polytope_csv'.\nProgram closing.\n";
    <STDIN>;
    exit;
  }
  
  my @polytope_parameters = <INPUTFILE>;
  $polytope_parameters[0] =~ tr/\n//d;
  my @parameter_keys = split(",", $polytope_parameters[0]);
  
  my @polytopes = ();
  
  foreach my $line (@polytope_parameters[1..$#polytope_parameters]) {
    my @pairs = ();
    my $index = 0;
    my @line_values = split(/,(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)/, $line);
    $line_values[2] =~ tr/"//d;
    my $vertices = parse_json($line_values[2]);
    my $polytope = new Polytope(VERTICES=>$vertices);

    foreach my $key (@parameter_keys){
      $line_values[$index] =~ tr/\n//d;
      $line_values[$index] =~ tr/"//d;
      $line_values[$index] =~ s/'/"/ig;
      $line_values[$index] =~ s/T/t/ig;
      $line_values[$index] =~ s/F/f/ig;

      if ($key && $key ne "PolytopeVertices") {
	my $value;
	eval {
	  $value = parse_json($line_values[$index]);
	} or do {
	  $line_values[$index] =~ s/]]/]/ig;
	  $value = $line_values[$index];
	};
	
	$polytope->attach($key, $value);
      }

      $index++;
    }
    
    #my $polytope_data = new Map<String, String>(@pairs);

    push @polytopes, $polytope;
  }
  
  save_data(\@polytopes, "mBies_polytopes.poly", canonical=>true);
}


main();
