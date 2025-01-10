#include "../include/errors.h"
#include <string.h>
#include <stdio.h>

int check_use(struct entry *entry, int nature, int line, char *label)
{
    if (entry == NULL)
    {
        error_message(ERR_UNDECLARED, label, nature, 0, line);
        return ERR_UNDECLARED;
    }

    return check_nature(*entry, nature, line);
}

int check_declaration(struct entry *entry, int line)
{
    if (entry != NULL)
    {
        error_message(ERR_DECLARED, entry->value.token_value, entry->nature, entry->line, line);
        return ERR_DECLARED;
    }
    return NO_ERROR;
}

int check_nature(struct entry entry, int nature, int line)
{
    if (entry.nature == VAR && nature == FUNC)
    {
        error_message(ERR_VARIABLE, entry.value.token_value, entry.nature, entry.line, line);
        return ERR_VARIABLE;
    }
    if (entry.nature == FUNC && nature == VAR)
    {
        error_message(ERR_FUNCTION, entry.value.token_value, entry.nature, entry.line, line);
        return ERR_FUNCTION;
    }
    return NO_ERROR;
}

void error_message(int error, char *label, int nature, int d_line, int u_line)
{
    char *nature_str = nature == VAR ? "variável" : "função";
    switch (error)
    {
    case ERR_UNDECLARED:
        printf("Erro na linha %d: A %s %s não foi declarada!\n", u_line, nature_str, label);
        return;
    case ERR_DECLARED:
        printf("Erro na linha %d: O identificador %s já foi declarado na linha %d!\n", u_line, label, d_line);
        return;
    case ERR_VARIABLE:
        printf("Erro na linha %d: A %s %s declarada foi utilizada como uma função na linha %d!\n", d_line, nature_str, label, u_line);
        return;
    case ERR_FUNCTION:
        printf("Erro na linha %d: A %s %s declarada foi utilizada como uma variável na linha %d!\n", d_line, nature_str, label, u_line);
        return;
    }
}