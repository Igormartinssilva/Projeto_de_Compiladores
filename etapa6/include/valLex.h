#ifndef VALLEX_H
#define VALLEX_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct valLex
{
      int line_number;
      int token_type;
      char *token_value;
};

struct valLex *create(int line_number, int token_type, const char *token_value);

#endif // VALLEX_H
