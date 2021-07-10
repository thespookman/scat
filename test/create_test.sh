#!/bin/bash

if [ $# -ne 1 ]; then
	echo "Needs one argument"
	exit 1
fi

scad_file=`echo $1 | cut -d '/' -f 4`

openscad ./$1 -o ./$scad_file.exp.stl >./$scad_file.exp.log 2>&1

cp $1 $scad_file.exp

../../../scat ./$scad_file.exp

echo
echo "Check the formatting: "

echo "START FILE"
cat ./$scad_file.exp
echo "END FILE"
echo

read -p "Everything as expected? (y/N)" -N 1 choice

if [ "$choice" != "y" ]; then
	rm ./$scad_file.exp*
fi

echo
