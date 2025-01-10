#include <stdio.h>
#include "../include/arvore.h"

extern int yyparse(void);
extern int yylex_destroy(void);
void *arvore = NULL;

void exporta(void *arvore)
{
  exporta_arvore(arvore);
}

int main(int argc, char **argv)
{
  int ret = yyparse();
  exporta(arvore);
  asd_free(arvore);
  yylex_destroy();
  return ret;
}