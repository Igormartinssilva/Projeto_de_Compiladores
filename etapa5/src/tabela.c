#include "../include/tabela.h"
#include <string.h>
#include <stdlib.h>
#include <stdio.h>

void print_table(struct table *tabela)
{
    for (int i = 0; i < tabela->num_entries; i++)
    {
        printf("%d - %s\n", i, tabela->entries[i]->value.token_value);
    }
}

void print_table_stack(struct table_stack *table_stack)
{
    int i = 0;
    while (table_stack != NULL)
    {
        printf("Index: %d\n", i);
        print_table(table_stack->top);
        table_stack = table_stack->next;
        i++;
    }
}

// Inicialização da entrada da tabela
struct entry new_entry(int line, int nature, int type, struct valLex *value)
{
    struct entry entry;
    entry.line = line;
    entry.nature = nature;
    entry.type = type;
    entry.value = *value;
    return entry;
}

// Criação da tabela
struct table *new_table()
{
    struct table *table = NULL;
    table = calloc(1, sizeof(struct table));
    if (table != NULL)
    {
        table->entries = NULL;
        table->num_entries = 0;
        table->scope = "rbss";
    }
    return table;
}

// Adiciona entrada na tabela atualizando o número de entradas
void add_entry(struct table *table, struct entry *entry)
{
    if (table == NULL || entry == NULL)
        return;

    int deslocamento = sizeof(int) * table->num_entries;
    entry->shift = malloc(32); // Aloca espaço para a string
    if (entry->shift != NULL) {
        snprintf(entry->shift, 32, "%d", deslocamento); // Converte o número para string
    }

    entry->scope = strdup(table->scope);

    table->num_entries++;
    table->entries = realloc(table->entries, table->num_entries * sizeof(struct entry));
    table->entries[table->num_entries - 1] = entry;

    entry->value.token_value = strdup(entry->value.token_value);
}

// Busca posição da label na tabela e retorna se encontrar
struct entry *search_table(struct table *table, char *label)
{
    if (table == NULL)
        return NULL;

    for (int i = 0; i < table->num_entries; i++)
    {
        struct entry *entry = table->entries[i];
        if (!strncmp(entry->value.token_value, label, strlen(label)))
            return entry;
    }
    return NULL;
}

// Libera a tabela da memória
void free_table(struct table *table)
{
    if (table == NULL)
        return;

    int i;
    for (i = 0; i < table->num_entries; i++)
    {
        free(table->entries[i]->value.token_value);
        free(table->entries[i]);
    }
    free(table->entries);
    free(table);
}

// Cria uma nova pilha de tabelas
struct table_stack *new_table_stack()
{
    struct table_stack *table_stack = NULL;
    table_stack = calloc(1, sizeof(struct table_stack));
    if (table_stack != NULL)
    {
        table_stack->top = NULL;
        table_stack->next = NULL;
    }
    return table_stack;
}

// Insere a tabela no topo da pilha
void push_table(struct table_stack **table_stack, struct table *new_table)
{
    if (new_table == NULL)
        return;

    if (*table_stack == NULL)
    {
        *table_stack = new_table_stack();
    }
    if ((*table_stack)->top != NULL)
    {
        struct table_stack *next = new_table_stack();
        next->top = (*table_stack)->top;
        next->next = (*table_stack)->next;
        (*table_stack)->next = next;
        new_table->scope = "rfp";
    }
    (*table_stack)->top = new_table;
}

// Retira a tabela do topo da pilha
void pop_table(struct table_stack *table_stack)
{
    if (table_stack == NULL)
        return;

    free_table(table_stack->top);
    if (table_stack->next != NULL)
    {
        struct table_stack *aux = table_stack->next;
        table_stack->top = aux->top;
        table_stack->next = aux->next;
        free(aux);
    }
    else
    {
        free(table_stack);
        table_stack = NULL;
    }
}

// Busca entrada na tabela
struct entry *search_table_stack(struct table_stack *table_stack, char *label)
{
    if (table_stack == NULL)
        return NULL;

    struct table_stack *aux = table_stack;
    while (aux != NULL)
    {
        struct entry *entry = search_table(aux->top, label);
        if (entry != NULL)
            return entry;
        aux = aux->next;
    }
    return NULL;
}

// Libera a pilha de tabelas da memória
void free_table_stack(struct table_stack *table_stack)
{
    if (table_stack == NULL)
        return;

    free_table_stack(table_stack->next);
    free_table(table_stack->top);
    free(table_stack);
}