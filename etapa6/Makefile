## Igor Martins Silva - 00333069
## Carlos Eduardo Menin - 00332900

CC = gcc
CFLAGS = -O0 -Wall -g -lfl -lm -I include

SRC_FILES = $(wildcard src/*.c)
OBJ_FILES = $(patsubst src/%.c, bin/%.o, $(SRC_FILES))

all: etapa6

etapa6: $(OBJ_FILES) bin/lex.yy.o bin/parser.tab.o
	$(CC) -o $@ $^ $(CFLAGS)

bin/%.o: src/%.c include/%.h
	$(CC) -o $@ -c $< $(CFLAGS)

bin/main.o: src/main.c src/parser.tab.c include/arvore.h
	$(CC) -o $@ -c $< $(CFLAGS)

bin/parser.o: src/funcParser.c include/funcParser.h 
	$(CC) -o $@ -c $< $(CFLAGS)

bin/lex.yy.o: src/lex.yy.c 
	$(CC) -o $@ -c $<  -O0 -g -I include

bin/parser.tab.o: src/parser.tab.c
	$(CC) -o $@ -c $<  -O0 -g -I include

src/lex.yy.c: scanner.l include/arvore.h include/valLex.h
	flex -o $@ $< 

src/parser.tab.c src/parser.tab.h: parser.y include/valLex.h
	bison -o src/parser.tab.c -d parser.y 

clean:
	rm -f etapa6
	rm -f bin/*.o
	rm -f src/lex.yy.c src/parser.tab.c src/parser.tab.h
	rm -f *.s *.dot
