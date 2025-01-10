#ifndef ERROR_H
#define ERROR_H

#include "tabela.h"
#include "types.h"

#define NO_ERROR 0

#define ERR_UNDECLARED       10 //2.3
#define ERR_DECLARED         11 //2.3
#define ERR_VARIABLE         20 //2.4
#define ERR_FUNCTION         21 //2.4

int check_use(struct entry *entry, int nature, int line, char *label);

int check_declaration(struct entry *entry, int line);

int check_nature(struct entry entry, int nature, int line);

void error_message(int error, char *label, int nature, int d_line, int u_line);

#endif