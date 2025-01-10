## Igor Martins Silva - 00333069
## Carlos Eduardo Menin - 00332900

CC = gcc
OBJECTS = bin/main.o bin/lex.yy.o bin/parser.tab.o

CFLAGS = -O0 -Wall -g -lfl

all: etapa2

etapa2: $(OBJECTS)
	$(CC) -o etapa2 bin/*.o $(CFLAGS) 

bin/main.o: src/main.c src/parser.tab.c
	$(CC) -o bin/main.o -c src/main.c $(CFLAGS)

bin/lex.yy.o: src/lex.yy.c
	$(CC) -o bin/lex.yy.o -c src/lex.yy.c -O0 -g

bin/parser.tab.o: src/parser.tab.c
	$(CC) -o bin/parser.tab.o -c src/parser.tab.c $(CFLAGS)

src/lex.yy.c: scanner.l
	flex -o src/lex.yy.c scanner.l

src/parser.tab.c src/parser.tab.h: parser.y
	bison -o src/parser.tab.c -d parser.y

clean:
	rm -f etapa2
	rm -f bin/*.o
	rm src/lex.yy.c src/parser.tab.c src/parser.tab.h
