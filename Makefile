CC = g++

COMPILER_FLAGS = -std=c++17 -Wall

INCLUDES = -Iinclude -I. -Ilib

LINKER_FLAGS = -Llib -lfig -lstdc++fs

OUTPUT = scat

.PHONY: all
all: $(OUTPUT)

SRC = lexer.yy.c src/main.cpp

$(OUTPUT): $(SRC) lib/libfig.a lib/fig.h 
	$(CC) $(COMPILER_FLAGS) $(SRC) -o $@ $(INCLUDES) $(LINKER_FLAGS)


lexer.yy.c: src/lexer.l
	flex -o $@ $<

.PHONY: test
test: $(OUTPUT)
	cd test && ./test.sh

.PHONY: clean
clean:
	rm lexer.yy.c $(OUTPUT)
