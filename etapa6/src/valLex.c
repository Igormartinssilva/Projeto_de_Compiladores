#include "../include/valLex.h"

struct valLex *create(int line_number, int token_type, const char *token_value)
{
    struct valLex *val = NULL;
    val = calloc(1, sizeof(struct valLex));
    val->line_number = line_number;
    val->token_type = token_type;
    val->token_value = (char *)malloc(strlen(token_value) + 1);

    if (val->token_value != NULL)
    {
        strcpy(val->token_value, token_value);
    }
    else
    {
        fprintf(stderr, "Erro ao alocar memória para token_value.\n");
        val->token_value = NULL;
    }

    return val;
}