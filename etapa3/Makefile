## Igor Martins Silva - 00333069
## Carlos Eduardo Menin - 00332900

CC = gcc
OBJECTS = bin/main.o bin/lex.yy.o bin/parser.tab.o bin/arvore.o bin/valLex.o

CFLAGS = -O0 -Wall -g -lfl

all: etapa3

etapa3: $(OBJECTS)
	$(CC) -o etapa3 bin/*.o $(CFLAGS) 

bin/main.o: src/main.c src/parser.tab.c include/arvore.h
	$(CC) -o bin/main.o -c src/main.c $(CFLAGS)

bin/arvore.o: src/arvore.c include/arvore.h
	$(CC) -o bin/arvore.o -c src/arvore.c

bin/valLex.o: src/valLex.c include/valLex.h
	$(CC) -o bin/valLex.o -c src/valLex.c

bin/lex.yy.o: src/lex.yy.c
	$(CC) -o bin/lex.yy.o -c src/lex.yy.c -O0 -g

bin/parser.tab.o: src/parser.tab.c
	$(CC) -o bin/parser.tab.o -c src/parser.tab.c $(CFLAGS)

src/lex.yy.c: scanner.l include/arvore.h include/valLex.h
	flex -o src/lex.yy.c scanner.l

src/parser.tab.c src/parser.tab.h: parser.y include/valLex.h
	bison -o src/parser.tab.c -d parser.y

clean:
	rm -f etapa3
	rm -f bin/*.o
	rm -f src/lex.yy.c src/parser.tab.c src/parser.tab.h