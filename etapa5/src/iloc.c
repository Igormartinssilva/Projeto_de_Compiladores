#include "../include/iloc.h"


char *create_label() {
    static int label = 1;
    int num_digits = (label == 0) ? 1 : floor(log10(label)) + 1;
    char *str = calloc(1, sizeof(char) * (num_digits + 2));
    sprintf(str, "L%d", label);
    label++;
    return str;
}


char *create_temp() {
    static int temp = 1;
    int num_digits = (temp == 0) ? 1 : floor(log10(temp)) + 1;   // Calcula o número exato de dígitos
    char *str = calloc(1, sizeof(char) * (num_digits + 2));      // +1 para o prefixo, +1 para '\0'
    sprintf(str, "r%d", temp);
    temp++;
    return str;
}

void export_code(iloc_list_t *iloc_list){
    if(iloc_list == NULL)
        return;
        
    for (int i = 0; i < iloc_list->num_ilocs; i++)
    {
        iloc_t *iloc = iloc_list->iloc[i];
        char *operation = iloc->operation;
        char **args = iloc->args;
        if(!strcmp(operation, "storeAI")){
            printf("%s %s => %s, %s\n", operation, args[0], args[1], args[2]);
        }
        else if(!strcmp(operation, "loadI")){
            printf("%s %s => %s\n", operation, args[0], args[1]);
        }
        else if(!strcmp(operation, "cmp_NE")){
            printf("%s %s, %s -> %s\n", operation, args[0], args[1], args[2]);
        }
        else if(!strcmp(operation, "nop")){
            printf("%s:\n%s\n", args[0], operation);
        }
        else if(!strcmp(operation, "jumpI")){
            printf("%s -> %s\n", operation, args[0]);
        }
        else if(!strcmp(operation, "or")){
            printf("%s %s, %s => %s\n", operation, args[0], args[1], args[2]);
        }
        else if(!strcmp(operation, "and")){
            printf("%s %s, %s => %s\n", operation, args[0], args[1], args[2]);
        }
        else if(!strcmp(operation, "cmp_EQ")){
            printf("%s %s, %s -> %s\n", operation, args[0], args[1], args[2]);
        }
        else if(!strcmp(operation, "cmp_GE")){
            printf("%s %s, %s -> %s\n", operation, args[0], args[1], args[2]);
        }   
        else if(!strcmp(operation, "cmp_LE")){
            printf("%s %s, %s -> %s\n", operation, args[0], args[1], args[2]);
        }
        else if(!strcmp(operation, "cmp_GT")){
            printf("%s %s, %s -> %s\n", operation, args[0], args[1], args[2]);
        }
        else if(!strcmp(operation, "cmp_LT")){
            printf("%s %s, %s -> %s\n", operation, args[0], args[1], args[2]);
        }
        else if(!strcmp(operation, "add")){
            printf("%s %s, %s => %s\n", operation, args[0], args[1], args[2]);
        }
        else if(!strcmp(operation, "sub")){
            printf("%s %s, %s => %s\n", operation, args[0], args[1], args[2]);
        }
        else if(!strcmp(operation, "mult")){
            printf("%s %s, %s => %s\n", operation, args[0], args[1], args[2]);
        }
        else if(!strcmp(operation, "div")){
            printf("%s %s, %s => %s\n", operation, args[0], args[1], args[2]);
        }
        else if(!strcmp(operation, "multI")){
            printf("%s %s, %s => %s\n", operation, args[0], args[1], args[2]);
        }
        else if(!strcmp(operation, "loadAI")){
            printf("%s %s, %s => %s\n", operation, args[0], args[1], args[2]);
        }
        else if(!strcmp(operation, "cbr")){
            printf("%s %s -> %s, %s\n", operation, args[0], args[1], args[2]);
        }
    }
}

iloc_list_t *merge_code(int num_codes, ...){
    iloc_list_t *list = create_iloc_list();
    va_list valist;

    va_start(valist, num_codes);
    for(int i = 0; i < num_codes; i++){
        iloc_list_t *aux = va_arg(valist, iloc_list_t *);
        if(aux != NULL){
            for(int j = 0; j < aux->num_ilocs; j++)
            {
            
                add_iloc(list, aux->iloc[j]);   
            }
        }
    }
    va_end(valist);
    return list;
}

iloc_list_t *generate_code(char *operation, char* arg1, char* arg2, char* arg3){
    iloc_list_t *list = create_iloc_list();
    iloc_t *iloc = create_iloc(operation, arg1, arg2, arg3);
    add_iloc(list, iloc);   
    return list;
}

iloc_list_t *create_iloc_list()
{
  iloc_list_t *ret = NULL;
  ret = calloc(1, sizeof(iloc_list_t));
  if (ret != NULL) {
    ret->iloc = NULL;
    ret->num_ilocs = 0;
  }
  return ret;
}

struct iloc *create_iloc(char *operation, char* arg1, char* arg2, char* arg3)
{
  iloc_t *ret = NULL;
  ret = calloc(1, sizeof(iloc_t));
  if (ret != NULL) {
    ret->operation = operation;
    ret->num_args = 0;
    add_iloc_arg(ret, arg1);
    add_iloc_arg(ret, arg2);
    add_iloc_arg(ret, arg3);
  }
  return ret;
}

void add_iloc_arg(iloc_t *iloc, char* arg)
{
  if (iloc != NULL && arg != NULL) {
    iloc->num_args++;
    iloc->args = realloc(iloc->args, iloc->num_args * sizeof(char*));
    iloc->args[iloc->num_args-1] = arg;
  }
}

void add_iloc(iloc_list_t *iloc_list, iloc_t *iloc)
{
  if (iloc_list != NULL && iloc != NULL) {
    iloc_list->num_ilocs++;
    iloc_list->iloc = realloc(iloc_list->iloc, iloc_list->num_ilocs * sizeof(iloc_t *));
    iloc_list->iloc[iloc_list->num_ilocs-1] = iloc;
  }
}