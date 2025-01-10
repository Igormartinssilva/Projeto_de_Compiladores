#include "iloc.h"


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

int get_register_index(int *registers){
    for(int i = 0; i < MAX_NUMBER_OF_REGISTERS; i++){
        if(registers[i] == FALSE)
        {
            //registers[i] = TRUE;
            return i;
        }
    }
    return -1;
}

void clear_registers(int *registers){
    for(int i = 0; i < MAX_NUMBER_OF_REGISTERS; i++){
        registers[i] = FALSE;
    }
}

void generateAsm(iloc_list_t *iloc_list){
    if(iloc_list == NULL)
        return;
           
    int registers[MAX_NUMBER_OF_REGISTERS] = {FALSE}; // inicializa os registradores como livres
    char *register_names[MAX_NUMBER_OF_REGISTERS] = {"%r8d", "%r9d", "%r10d", "%r11d", "%r12d", "%r13d", "%r14d", "%r15d",
                                                     "%r16d", "%r17d", "%r18d", "%r19d", "%r20d", "%r21d", "%r22d", "%r23d"};

    for (int i = 0; i < iloc_list->num_ilocs; i++)
    {
        int index = get_register_index(registers);
        iloc_t *iloc = iloc_list->iloc[i];
        char *operation = iloc->operation;
        char **args = iloc->args;
        
        if(!strcmp(operation, "storeAI")){
            printf("\tmovl %s, %s(%%%s)\n", register_names[index-1], args[2], args[1]);
            registers[index-1] = FALSE;
        }
        else if(!strcmp(operation, "loadI")){
            printf("\tmovl $%s, %s\n", args[0], register_names[index]);
            registers[index] = TRUE;
        }
        else if(!strcmp(operation, "cmp_NE")){
            printf("\tcmp %s, %s\n", register_names[index-1], register_names[index-2]);
            printf("\tsetne %%al\n");
            printf("\tmovzbl %%al, %s\n", register_names[index-2]);
            printf("\ttestl $1, %s\n", register_names[index-2]);
            registers[index-1] = FALSE;
        }
        else if(!strcmp(operation, "cmp_EQ")){
            printf("\tcmp %s, %s\n", register_names[index-1], register_names[index-2]);
            printf("\tsete %%al\n");
            printf("\tmovzbl %%al, %s\n", register_names[index-2]);
            printf("\ttestl $1, %s\n", register_names[index-2]);
            registers[index-1] = FALSE;
        }
        else if(!strcmp(operation, "label")){
            printf(".%s:\n", args[0]);
        }
        else if(!strcmp(operation, "jumpI")){
            printf("\tjmp .%s\n", args[0]);
            clear_registers(registers);
        }
        else if(!strcmp(operation, "cmp_GE")){
            printf("\tcmp %s, %s\n", register_names[index-1], register_names[index-2]);
            printf("\tsetge %%al\n");
            printf("\tmovzbl %%al, %s\n", register_names[index-2]);
            printf("\ttestl $1, %s\n", register_names[index-2]);
            registers[index-1] = FALSE;
        }   
        else if(!strcmp(operation, "cmp_LE")){
            printf("\tcmp %s, %s\n", register_names[index-1], register_names[index-2]);
            printf("\tsetle %%al\n");
            printf("\tmovzbl %%al, %s\n", register_names[index-2]);
            printf("\ttestl $1, %s\n", register_names[index-2]);
            registers[index-1] = FALSE;
        }
        else if(!strcmp(operation, "cmp_GT")){
            printf("\tcmp %s, %s\n", register_names[index-1], register_names[index-2]);
            printf("\tsetg %%al\n");
            printf("\tmovzbl %%al, %s\n", register_names[index-2]);
            printf("\ttestl $1, %s\n", register_names[index-2]);
            registers[index-1] = FALSE;  
        }
        else if(!strcmp(operation, "cmp_LT")){
            printf("\tcmp %s, %s\n", register_names[index-1], register_names[index-2]);
            printf("\tsetl %%al\n");
            printf("\tmovzbl %%al, %s\n", register_names[index-2]);
            printf("\ttestl $1, %s\n", register_names[index-2]);
            registers[index-1] = FALSE;
        }
        else if(!strcmp(operation, "add")){
            printf("\taddl %s, %s\n", register_names[index-1], register_names[index-2]);
            registers[index-1] = FALSE;
        }
        else if(!strcmp(operation, "sub")){
            printf("\tsubl %s, %s\n", register_names[index-1], register_names[index-2]);
            registers[index-1] = FALSE;
        }
        else if(!strcmp(operation, "mult")){
            printf("\timull %s, %s\n", register_names[index-1], register_names[index-2]);
            registers[index-1] = FALSE;
        }
        else if(!strcmp(operation, "div")){
            printf("\tmovl %s, %%ecx\n", register_names[index-1]);
            printf("\tmovl %s, %%eax\n", register_names[index-2]);
            printf("\tcltd\n");
            printf("\tidivl %%ecx\n");
            printf("\tmovl %%eax, %s\n", register_names[index-2]);
            registers[index-1] = FALSE;
        }
        else if(!strcmp(operation, "loadAI")){
            printf("\tmovl %s(%%%s), %s\n", args[1], args[0], register_names[index]);
            registers[index] = TRUE;
        }
        else if(!strcmp(operation, "je")){
            printf("\tje .%s\n", args[1]);
            clear_registers(registers);
        }
        else if(!strcmp(operation, "jne")){
            printf("\tjne .%s\n", args[1]);
            clear_registers(registers);
        }
        else if(!strcmp(operation, "neg")){
            printf("\tnegl %s\n", register_names[index-1]);
        }
        else if(!strcmp(operation, "return")){
            printf("\tmovl %s, %%eax\n", register_names[index-1]);
            printf("\tpopq %%rbp\n");
            printf("\tret\n\n");
        }
        else if(!strcmp(operation, "func")){
            printf("\t.text\n");
            printf("\t.globl %s\n", args[0]);
            printf("\t.type %s, @function\n", args[0]);
            printf("%s:\n", args[0]);
            printf(".LFB0:\n");
            printf("\tpushq %%rbp\n");
            printf("\tmovq %%rsp, %%rbp\n");
        }
        else if(!strcmp(operation, "jz")){
            printf("\tjz .%s\n", args[1]);
            clear_registers(registers);
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