#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include "../include/arvore.h"
#define ARQUIVO_SAIDA "saida.dot"

asd_tree_t *asd_new(const char *label)
{
  asd_tree_t *ret = NULL;
  ret = calloc(1, sizeof(asd_tree_t));
  if (ret != NULL)
  {
    ret->label = strdup(label);
    ret->number_of_children = 0;
    ret->children = NULL;
  }
  return ret;
}

void asd_free(asd_tree_t *tree)
{
  if (tree != NULL)
  {
    int i;
    for (i = 0; i < tree->number_of_children; i++)
    {
      asd_free(tree->children[i]);
    }
    free(tree->children);
    free(tree->label);
    free(tree);
  }
  else
  {
    printf("Erro: %s recebeu parâmetro tree = %p.\n", __FUNCTION__, tree);
  }
}

void asd_add_child(asd_tree_t *tree, asd_tree_t *child)
{
  if (tree != NULL && child != NULL)
  {
    tree->number_of_children++;
    tree->children = realloc(tree->children, tree->number_of_children * sizeof(asd_tree_t *));
    tree->children[tree->number_of_children - 1] = child;
  }
  else
  {
    printf("Erro: %s recebeu parâmetro tree = %p / %p.\n", __FUNCTION__, tree, child);
  }
}

static void _asd_print(FILE *foutput, asd_tree_t *tree, int profundidade)
{
  int i;
  if (tree != NULL)
  {
    fprintf(foutput, "%d%*s: Nó '%s' tem %d filhos:\n", profundidade, profundidade * 2, "", tree->label, tree->number_of_children);
    for (i = 0; i < tree->number_of_children; i++)
    {
      _asd_print(foutput, tree->children[i], profundidade + 1);
    }
  }
  else
  {
    printf("Erro: %s recebeu parâmetro tree = %p.\n", __FUNCTION__, tree);
  }
}

void asd_print(asd_tree_t *tree)
{
  FILE *foutput = stderr;
  if (tree != NULL)
  {
    _asd_print(foutput, tree, 0);
  }
  else
  {
    printf("Erro: %s recebeu parâmetro tree = %p.\n", __FUNCTION__, tree);
  }
}

static void _asd_print_graphviz(FILE *foutput, asd_tree_t *tree)
{
  int i;
  if (tree != NULL)
  {
    fprintf(foutput, "  %ld [ label=\"%s\" ];\n", (long)tree, tree->label);
    for (i = 0; i < tree->number_of_children; i++)
    {
      fprintf(foutput, "  %ld -> %ld;\n", (long)tree, (long)tree->children[i]);
      _asd_print_graphviz(foutput, tree->children[i]);
    }
  }
  else
  {
    printf("Erro: %s recebeu parâmetro tree = %p.\n", __FUNCTION__, tree);
  }
}

void asd_print_graphviz(asd_tree_t *tree)
{
  FILE *foutput = fopen(ARQUIVO_SAIDA, "w+");
  if (foutput == NULL)
  {
    printf("Erro: %s não pude abrir o arquivo [%s] para escrita.\n", __FUNCTION__, ARQUIVO_SAIDA);
  }
  if (tree != NULL)
  {
    fprintf(foutput, "digraph grafo {\n");
    _asd_print_graphviz(foutput, tree);
    fprintf(foutput, "}\n");
    fclose(foutput);
  }
  else
  {
    printf("Erro: %s recebeu parâmetro tree = %p.\n", __FUNCTION__, tree);
  }
}

void _exporta(asd_tree_t *tree)
{
  if (tree == NULL)
  {
    return;
  }
  else
  {
    printf("%p [label=\"%s\"];\n", tree, tree->label);
    for (int i = 0; i < tree->number_of_children; i++)
    {
      if (tree->children[i] != NULL)
      {
        printf("%p,%p\n", tree, tree->children[i]);
        _exporta(tree->children[i]);
      }
    }
  }
}

void exporta_arvore(asd_tree_t *tree)
{
  _exporta(tree);
}

asd_tree_t *list_of_commands(asd_tree_t *tree)
{
  asd_tree_t *aux = tree;
  while (aux->number_of_children > 0 && !strcmp(aux->children[aux->number_of_children - 1]->label, "<="))
  {
    aux = aux->children[aux->number_of_children - 1];
  }
  return aux;
}