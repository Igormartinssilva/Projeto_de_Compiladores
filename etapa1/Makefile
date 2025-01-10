## Igor Martins Silva - 00333069
## Carlos Eduardo Menin - 00332900

CFLAGS = -Wall -g -lfl

all: etapa1

etapa1: scanner.c main.c tokens.h
	gcc $(CFLAGS) scanner.c main.c -o etapa1

scanner.c: scanner.l tokens.h
	flex -o scanner.c scanner.l

clean:
	rm -rf *.o *~ etapa1 scanner.c
