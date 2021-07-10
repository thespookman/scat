# Scat
Openscad code formatter

## Depends
Scat depends on Fig for reading the format config files. Fig can be obtained from https://github.com/thespookman/fig

Building Scat will also need flex, which is included by default in many linux distros.

Building Fig will need bison.

## Build

Scat uses g++ by default, but can probably be compiled with other C++ compilers, just edit the Makefile if you want.

1. Download the repo  
```
git clone https://github.com/thespookman/scat.git
```
2. Enter the lib directory
```
cd scat/lib
```
3. Download Fig
```
git clone https://github.com/thespookman/fig.git
```
4. Enter the Fig directory
```
cd fig
```
5. Build Fig
```
make all
```
6. Move fig library to Scad's lib.
```
mv libfig.a include/fig.h ..
```
7. Return to Scad's directory.
```
cd ../..
```
8. Build Scad
```
make all
```

## Usage

`scat file1 [file2...]`

Scat will format each file passed as an argument _in place_ i.e. it will overwrite the original file. It will make formatting decisions based on the contents of a config file, if found.

Scat will look for a config file called `.scad-format` in the working directory, if it doesn't find one, it will check the parent directory, and so on. This allows the user to specify different formats for different projects, if desired.

If no config file is found, a set of default settings will be used, which result in compactly formatted code, with tabs for indentation.

## Config format

`.scad-format` files should be made up key-value pairs, each pair being on its own line, with an equals sign in between the key and value.

Following is a list of valid keys, with their default values:

- `comma padding = 0` the number of spaces after each comma.
- `function padding = 1` the number of spaces before each function call, when called in sequence (e.g. `translate([1,1,1]) rotate([45,0,0]) cube([1,1,1]);`.
- `indent spaces = 4` when used with `indent type = spaces`, sets the size of indents.
- `indent type = tabs` sets whether to use tabs or spaces for indentation.
- `line after function = 0` the number of blank lines to be inserted after each function definition.
- `line after module = 0` the number of blank lines to be inserted after each module definition.
- `no new identifiers after` has no default. If to a number, when functions are called in sequence (e.g. `translate([1,1,1]) rotate([45,0,0]) cube([1,1,1]);`), functions that start further right than the specified number of columns will be moved to a new line.
- `one function per line = false` if set to true, functions called in sequence will each be on a new line, but indented.
- `operator padding = 0` the number of spaces before and after any operator.
- `pad before angular = 0` the number of spaces before angular brackets (e.g. in `use <file.scad>`)
- `pad before comment = 0` when a comment follows code on the same line, the number of spaces in between the end of the code and the `//`. Has no effect when used with `tab before comment = true`.
- `pad before brace = 0` the number of spaces between the parameter list and opening brace in module definitions etc.
- `pad before bracket = 0` the number of spaces between the function identifier and opening bracket of the parameter list in function calls and definitions etc.
- `pad comment start = 0` the number of spaces between the `//` and the first word of comments.
- `pad inside angular = 0` the number of spaces either side of the file name inside angular brackets.
- `pad inside bracket = 0` the number of spaces either side of the parameter list inside brackets.
- `pad inside square = 0` the number of spaces either side of an array inside suqare brackets.
- `tab before comment = false` overrides `pad before comment` to use a tab instead of spaces.
- `tab width = 4` when used with `no new identifiers after`, sets the number of columns taken by tabs when calculating line length.

Keys and values are case-insensitive, and whitespace (except the spaces inside key strings) is ignored. Any line without an equals will be ignored, so can be used as comments.
