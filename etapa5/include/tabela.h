#ifndef TABELA_S
#define TABELA_S

#include "valLex.h"
#include "types.h"

struct entry{
    int line;
    int nature;
    int type;
    struct valLex value;
    char *shift;
    char *scope;
};

struct table{
    struct entry **entries;
    int num_entries;
    char *scope;
};

struct table_stack{
    struct table *top;
    struct table_stack *next;
};

// Entries
struct entry new_entry(int line, int nature, int type, struct valLex *value);

// Tables
struct table *new_table();
void add_entry(struct table *table, struct entry *entry);
struct entry *search_table(struct table *table, char *label);
void free_table(struct table *table);

// Stack
struct table_stack *new_table_stack();
void push_table(struct table_stack **table_stack, struct table *new_table);
void pop_table(struct table_stack *table_stack);
struct entry *search_table_stack(struct table_stack *table_stack, char *label);
void free_table_stack(struct table_stack *table_stack);

void print_table_stack(struct table_stack *table_stack);
void print_table(struct table *tabela);

#endif