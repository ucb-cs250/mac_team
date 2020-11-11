#!/bin/bash

for CFG in 0 1 2 4 5 6 8 9 10 12 13 14 
do
	./simulator-mac_test_harness +cfg=$CFG +num_tests=10000
done