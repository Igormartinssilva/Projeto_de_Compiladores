#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "../include/arvore.h"
#include "../include/valLex.h"
#include "../include/errors.h"
#include "../include/tabela.h"
#include "../include/types.h"
#include "../include/funcParser.h"
#include "../include/iloc.h"

asd_tree_t *asd_create(const char *label)
{
    asd_tree_t *node = asd_new(label);

    return node;
}

asd_tree_t *asd_create_with_type(const char *label, int type)
{
    asd_tree_t *node = asd_new(label);
    node->type = type;

    return node;
}

asd_tree_t *asd_create_with_child(const char *label, asd_tree_t *child)
{
    asd_tree_t *node = asd_new(label);
    if (child != NULL) {
        asd_add_child(node, child);
    }

    return node;
}

asd_tree_t *asd_create_with_child_and_type(const char *label, asd_tree_t *child, int type) 
{
    asd_tree_t *node = asd_new(label);
    node->type = type;
    if (child != NULL) {
        asd_add_child(node, child);
    }

    return node;
}

asd_tree_t *asd_create_with_children(const char *label, asd_tree_t *child1, asd_tree_t *child2) 
{
    asd_tree_t *node = asd_new(label);
    if (child1 != NULL) {
        asd_add_child(node, child1);
        if (child2 != NULL) {
        asd_add_child(node, child2);
        }
    }

    return node;
}

asd_tree_t *asd_create_with_children_and_type(const char *label, asd_tree_t *child1, asd_tree_t *child2, int type) 
{
    asd_tree_t *node = asd_new(label);
    node->type = type;
    if (child1 != NULL) {
        asd_add_child(node, child1);
        if (child2 != NULL) {
        asd_add_child(node, child2);
        }
    }

    return node;
}

asd_tree_t *asd_create_control_node(const char *label, asd_tree_t *condition, asd_tree_t *block1, asd_tree_t *block2) 
{
    asd_tree_t *node = asd_new(label);

    if (condition != NULL) {
        asd_add_child(node, condition);
        if (block1 != NULL) {
            asd_add_child(node, block1);
            if (block2 != NULL) {
                asd_add_child(node, block2);
            }
        }
    }

    return node;
}

struct entry *handle_declaration(struct table_stack *stack, int line_number, char *label_table, int entry_type, int var_type, struct valLex *token_value)
{
    struct entry *entry = search_table(stack->top, label_table);
    int error = check_declaration(entry, line_number);

    if (error != NO_ERROR) {
        exit(error);
    }

    entry = calloc(1, sizeof(struct entry));
    *entry = new_entry(line_number, entry_type, var_type, token_value);
    add_entry(stack->top, entry);

    return entry;
}

struct entry *handle_use(struct table_stack *stack, char *label,  int expected_type, int line_number) 
{
    struct entry *entry = search_table_stack(stack, label);
    int error = check_use(entry, expected_type, line_number, label);
    if (error != NO_ERROR) {
        exit(error);
    }

    return entry;
}

asd_tree_t *gen_and_merge_expr_code(asd_tree_t *node, char *label, asd_tree_t *child1, asd_tree_t *child2)
{
    node->temp = create_temp();
    iloc_list_t *code = generate_code(label, child1->temp, child2->temp, node->temp);
    node->code = merge_code(EXPR_NUM, child1->code, child2->code,code);
    
    return node;
}

asd_tree_t *gen_and_merge_unary_code(asd_tree_t *node, char *label, asd_tree_t *child1, char *constant)
{
    node->temp = create_temp();
    iloc_list_t *code = generate_code(label, child1->temp, constant, node->temp);
    
    node->code = merge_code(UNARY_NUM, child1->code,code);
    return node;
}

asd_tree_t *gen_and_merge_if_code(asd_tree_t *node, asd_tree_t *expr, asd_tree_t *command_block)
{
    char *label_t = create_label();    // Verdadeiro
    char *label_o = create_label();    // Out
    // Se for verdadeiro, coloca label_t no PC. Senao poe label_f
    iloc_list_t *code1 = generate_code("cbr", expr->temp, label_t, label_o);
    // Instrucao com mais de um rotulo necessita de nop
    iloc_list_t *code2 = generate_code("nop", label_t, NULL, NULL);
    // Se for falso, pula imediatamente para label_f
    iloc_list_t *code3 = generate_code("jumpI", label_o, NULL, NULL);
    // Instrucao com mais de um rotulo necessita de nop
    iloc_list_t *code4 = generate_code("nop", label_o, NULL, NULL);
    // Uniao do codigo
    if(command_block != NULL)
        node->code = merge_code(IF_NUM, expr->code, code1, code2, command_block->code, code3, code4);
    else
        node->code = merge_code(IF_NUM-1, expr->code, code1, code2, code3, code4);
    return node;
}

asd_tree_t *gen_and_merge_if_else_code(asd_tree_t *node, asd_tree_t *expr, asd_tree_t *command_block_if, asd_tree_t *command_block_else)
{
    char *label_t = create_label();    // Verdadeiro
    char *label_o = create_label();    // Falso
    iloc_list_t *code1 = generate_code("cbr", expr->temp, label_t, label_o);
    // Criacao de label para else
    char *label_f = create_label();
    // Instrucao com mais de um rotulo necessita de nop
    iloc_list_t *code2 = generate_code("nop", label_t, NULL, NULL);
    // Se for falso, pula imediatamente para label_f
    iloc_list_t *code3 = generate_code("jumpI", label_f, NULL, NULL);
    // Instrucao com mais de um rotulo necessita de nop
    iloc_list_t *code4 = generate_code("nop", label_o, NULL, NULL);
    // Instrucao com mais de um rotulo necessita de nop
    iloc_list_t *code5 = generate_code("nop", label_f, NULL, NULL);
    // Uniao do codigo
    if(command_block_if != NULL && command_block_else != NULL)
        node->code = merge_code(IF_ELSE_NUM, expr->code, code1, code2, command_block_if->code, code3, code4, command_block_else->code, code5);
    else if(command_block_if == NULL && command_block_else != NULL)
        node->code = merge_code(IF_ELSE_NUM-1, expr->code, code1, code2, code3, code4, command_block_else->code, code5);
    else if(command_block_if != NULL && command_block_else == NULL)
        node->code = merge_code(IF_ELSE_NUM-1, expr->code, code1, code2, command_block_if->code, code3, code4, code5);
    else
        node->code = merge_code(IF_ELSE_NUM-2, expr->code, code1, code2, code3, code4, code5);
    return node;
}

asd_tree_t *gen_and_merge_while_code(asd_tree_t *node, asd_tree_t *expr, asd_tree_t *command_block)
{
    // Rotulo inicio
    char *label_inicio = create_label();
    // Rotulo verdadeiro
    char *label_t = create_label();
    // Rotulo falso
    char *label_f = create_label();
    iloc_list_t *code1 = generate_code("nop", label_inicio, NULL, NULL);
    iloc_list_t *code2 = generate_code("cbr", expr->temp, label_t, label_f);
    iloc_list_t *code3 = generate_code("nop", label_t, NULL, NULL);
    iloc_list_t *code4 = generate_code("jumpI", label_inicio, NULL, NULL);
    iloc_list_t *code5 = generate_code("nop", label_f, NULL, NULL);
    if(command_block != NULL)
        node->code = merge_code(WHILE_NUM, code1, expr->code, code2, code3, command_block->code, code4, code5);
    else
        node->code = merge_code(WHILE_NUM-1, code1, expr->code, code2, code3, code4, code5);
    return node;
}

asd_tree_t *gen_lit_code(asd_tree_t *node)
{
    node->temp = create_temp();
    node->code = generate_code("loadI", node->label, node->temp, NULL);
    return node;
}

asd_tree_t *gen_oper_code(asd_tree_t *node, struct entry *entry)
{
    node->temp = create_temp();
    node->code = generate_code("loadAI", entry->scope, (char *) entry->shift, node->temp);
    return node;
}

asd_tree_t *gen_assign_code(asd_tree_t *node, struct entry *entry, asd_tree_t *expr)
{
    iloc_list_t *code = generate_code("storeAI", expr->temp, entry->scope, entry->shift);
    node->code = merge_code(ASSIGN_NUM, expr->code, code);
    return node;
}


asd_tree_t *gen_and_merge_neg_code(asd_tree_t *node, asd_tree_t *expr)
{

    node->temp = create_temp();
    // Coloca 0 no registrador temp 1
    iloc_list_t * code1 = generate_code("loadI", "0", node->temp, NULL); 
    // Compara se o valor da expressao igual a 0 e coloca resultado no temp2
    iloc_list_t *code2 = generate_code("cmp_EQ", node->temp, expr->temp, node->temp);
    node->code = merge_code(3, expr->code, code1, code2);

    return node;
}