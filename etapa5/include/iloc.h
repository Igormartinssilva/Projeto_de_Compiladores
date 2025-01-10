#ifndef _ILOC_H_
#define _ILOC_H_

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include <math.h>

#define MAX_NUM_ARGS 3

typedef struct iloc {
    char  *operation;
    char **args;
    int num_args;
}iloc_t;

typedef struct iloc_list {
    iloc_t **iloc;
    int num_ilocs;
}iloc_list_t;

char *create_label();
char *create_temp();

iloc_t *create_iloc(char *operation, char* arg1, char* arg2, char* arg3);
void add_iloc_arg(iloc_t *iloc, char* arg);

iloc_list_t *create_iloc_list();
void add_iloc(iloc_list_t *iloc_list, iloc_t *iloc);

iloc_list_t *generate_code(char *operation, char* arg1, char* arg2, char* arg3);
iloc_list_t *merge_code(int num_codes, ...);
void export_code(iloc_list_t *iloc_list);


#endif