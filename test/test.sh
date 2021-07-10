#!/bin/bash

success=0

cd test_files

for directory in $( find . -maxdepth 1 -mindepth 1 -type d | cut -d '/' -f 2 ); do
	cd $directory
	for scad_file in $( find ../../scad_files/ -maxdepth 1 -mindepth 1 -type f | cut -d '/' -f 4 ); do
		echo "Testing $directory on $scad_file"
		cp ../../scad_files/$scad_file ./$scad_file.tmp
		../../../scat ./$scad_file.tmp >/dev/null 2>&1
		diff -y ./$scad_file.tmp ./$scad_file.exp > ./$scad_file.res
		res=$?
		if [ ${res} -ne 0 ]; then
			echo -e "\tChecking formatting\t\e[31m FAIL \e[0m"
			cat ./$scad_file.res
			echo
			success=1;
		else
			echo -e "\tChecking formatting\t\e[32m PASS \e[0m"
		fi
		openscad ./$scad_file.tmp -o ./$scad_file.tmp.stl > ./$scad_file.tmp.log 2>&1
		diff -y ./$scad_file.tmp.stl ./$scad_file.exp.stl > ./$scad_file.res
		res=$?
		if [ ${res} -ne 0 ]; then
			echo -e "\tChecking built file\t\e[31m FAIL \e[0m"
			cat ./$scad_file.res
			echo
			success=1;
		else
			echo -e "\tChecking built file\t\e[32m PASS \e[0m"
		fi
		diff -y ./$scad_file.tmp.log ./$scad_file.exp.log > ./$scad_file.res
		res=$?
		if [ ${res} -ne 0 ]; then
			echo -e "\tChecking build output\t\e[31m FAIL \e[0m"
			cat ./$scad_file.res
			echo
			success=1;
		else
			echo -e "\tChecking build output\t\e[32m PASS \e[0m"
		fi
		rm ./$scad_file.tmp ./$scad_file.tmp.stl ./$scad_file.tmp.log ./$scad_file.res
	done
	cd ..
done

if [ ${success} -eq 0 ]; then
	echo -e "\e[32mAll tests passed.\e[0m"
else
	echo -e "\e[31mTests failing.\e[0m"
fi
exit $success
