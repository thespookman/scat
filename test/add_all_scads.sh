#!/bin/bash

for scad_file in $( find ../../scad_files/ -maxdepth 1 -mindepth 1 -type f ); do
	echo
	echo "$scad_file"
	../../create_test.sh $scad_file
done
