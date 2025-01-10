#ifndef _PARSER_H_
#define _PARSER_H_

#define UNIT_CODE 2
#define EXPR_NUM 3
#define UNARY_NUM 2
#define ASSIGN_NUM 2
#define IF_NUM 6
#define IF_ELSE_NUM 8
#define WHILE_NUM 7
#define AND_OR_NUM 15

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "arvore.h"
#include "tabela.h"

asd_tree_t *asd_create(const char *label);
asd_tree_t *asd_create_with_type(const char *label, int type);
asd_tree_t *asd_create_with_child(const char *label, asd_tree_t *child);
asd_tree_t *asd_create_with_child_and_type(const char *label, asd_tree_t *child, int type);
asd_tree_t *asd_create_with_children(const char *label, asd_tree_t *child1, asd_tree_t *child2);
asd_tree_t *asd_create_with_children_and_type(const char *label, asd_tree_t *child1, asd_tree_t *child2, int type);
asd_tree_t *asd_create_control_node(const char *label, asd_tree_t *condition, asd_tree_t *block1, asd_tree_t *block2); 
struct entry *handle_declaration(struct table_stack *stack, int line_number, char *label_table, int entry_type, int var_type, struct valLex *token_value);
struct entry *handle_use(struct table_stack *stack, char *label,  int expected_type, int line_number);
asd_tree_t *gen_and_merge_expr_code(asd_tree_t *node, char *label, asd_tree_t *child1, asd_tree_t *child2);
asd_tree_t *gen_and_merge_unary_code(asd_tree_t *node, char *label, asd_tree_t *child1, char *constant);
asd_tree_t *gen_and_merge_if_code(asd_tree_t *node, asd_tree_t *expr, asd_tree_t *command_block);
asd_tree_t *gen_and_merge_if_else_code(asd_tree_t *node, asd_tree_t *expr, asd_tree_t *command_block_if, asd_tree_t *command_block_else);
asd_tree_t *gen_and_merge_while_code(asd_tree_t *node, asd_tree_t *expr, asd_tree_t *command_block);
asd_tree_t *gen_lit_code(asd_tree_t *node);
asd_tree_t *gen_oper_code(asd_tree_t *node, struct entry *entry);
asd_tree_t *gen_assign_code(asd_tree_t *node, struct entry *entry, asd_tree_t *expr);
asd_tree_t *gen_and_merge_neg_code(asd_tree_t *node, asd_tree_t *expr);
asd_tree_t *gen_or_iloc_code(asd_tree_t *node, asd_tree_t *expr1, asd_tree_t *expr2);
asd_tree_t *gen_and_iloc_code(asd_tree_t *node, asd_tree_t *expr1, asd_tree_t *expr2);


#endif //_PARSER_H_