#ifndef _ARVORE_H_
#define _ARVORE_H_

#include "iloc.h"

typedef struct asd_tree
{
  char *label;
  int type;
  int number_of_children;
  struct asd_tree **children;

  iloc_list_t *code;
  char *temp;
} asd_tree_t;

/*
 * Função asd_new, cria um nó sem filhos com o label informado.
 */
asd_tree_t *asd_new(const char *label);

/*
 * Função asd_tree, libera recursivamente o nó e seus filhos.
 */
void asd_free(asd_tree_t *tree);

/*
 * Função asd_add_child, adiciona child como filho de tree.
 */
void asd_add_child(asd_tree_t *tree, asd_tree_t *child);

/*
 * Função asd_print, imprime recursivamente a árvore.
 */
void asd_print(asd_tree_t *tree);

/*
 * Função asd_print_graphviz, idem, em formato DOT
 */
void asd_print_graphviz(asd_tree_t *tree);

/*
 * Função para exportar a árvore no formato requerido
 */
void exporta_arvore(asd_tree_t *tree);

asd_tree_t *list_of_commands(asd_tree_t *tree);

#endif //_ARVORE_H_