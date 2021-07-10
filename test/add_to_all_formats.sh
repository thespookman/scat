#!/bin/bash

if [ $# -ne 1 ]; then
	echo "Needs one argument"
	exit 1
fi

cd test_files

for directory in $( find . -maxdepth 1 -mindepth 1 -type d | cut -d '/' -f 2 ); do
	cd $directory
	echo
	echo "$directory"
	../../create_test.sh ../../$1
	cd ..
done
