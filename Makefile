## Igor Martins Silva - 00333069
## Carlos Eduardo Menin - 00332900

SOURCES = main.c lex.yy.c parser.tab.c
OBJECTS = main.o lex.yy.o parser.tab.o

CFLAGS = -Wall -g -lfl

all: etapa2

etapa2: $(OBJECTS)
	$(CC) -o $@ $^

lex.yy.c: scanner.l
	flex $<

parser.tab.c parser.tab.h: parser.y
	bison -d $<

%.o: %.c
	$(CC) -c $<

clean:
	rm -f $(OBJECTS) etapa2