using Oscar

test = Polymake.load("test.json")

# error when this line tries to show ina repl
test_arrays = Polymake.to_array_bigobject(test)

# currently errors while trying to print attachment
attachment = Polymake.get_attachment(test_arrays[1], "CiGenus")



