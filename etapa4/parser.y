// Igor Martins Silva - 00333069
// Carlos Eduardo Menin - 00332900


%{
    #include <stdio.h>
    #include <string.h>
    #include <stdlib.h>

    int get_line_number();
    int yylex(void);
    void yyerror (char const *mensagem);
%}

%{
    extern void *arvore;
    struct table_stack *stack;
    int var_type;
%}

%code requires{ 
  #include "../include/arvore.h"
  #include "../include/valLex.h"
  #include "../include/errors.h"
  #include "../include/tabela.h"
  #include "../include/types.h"
}

%union{
	struct valLex valor_lexico;
	asd_tree_t *nodo;
}

%define parse.error verbose

%token TK_PR_INT
%token TK_PR_FLOAT
%token TK_PR_IF
%token TK_PR_ELSE
%token TK_PR_WHILE
%token TK_PR_RETURN
%token TK_OC_LE
%token TK_OC_GE
%token TK_OC_EQ
%token TK_OC_NE
%token TK_OC_AND
%token TK_OC_OR
%token<valor_lexico> TK_IDENTIFICADOR
%token<valor_lexico> TK_LIT_INT
%token<valor_lexico> TK_LIT_FLOAT
%token TK_ERRO

%type<nodo> program function_list function header return_types parameter_list mult_parameters parameters body command_block command_seq command
simple_command var_lit var_declaration var_list var assignment function_call args return_op flux_control expr expr_or expr_and expr_equality expr_relational
expr_additive expr_multiplicative expr_unary primary_expr oper push pop


%%

/* ----------------------------- inicialização do programa ----------------------------- */

program:            push function_list pop  {$$ = $2; arvore = $$;}
                |   /* vazio */             {$$ = NULL; arvore = $$;};

function_list:      function function_list  {   
                                                $$ = $1;
                                                if($2 != NULL){
                                                    asd_add_child($$, $2);
                                                }
                                            }
                |   function                {$$ = $1;};

function:   push header body pop    {   
                                        $$ = $2;
                                        if($3 != NULL){
                                            asd_add_child($$, $3);
                                        }
                                    };

/* ----------------------------- Cabeçalho da função ----------------------------- */

header:             TK_IDENTIFICADOR '=' parameter_list '>' return_types    {
                                                                                struct entry *entry = search_table(stack->next->top, $1.token_value);
                                                                                int error = check_declaration(entry, get_line_number());
                                                                                if(error != NO_ERROR){
                                                                                    exit(error);
                                                                                }
                                                                                else{
                                                                                    entry = calloc(1, sizeof(struct entry));
                                                                                    *entry = new_entry(get_line_number(), FUNC, var_type, $1);
                                                                                    add_entry(stack->next->top, entry);
                                                                                    $$ = asd_new($1.token_value, var_type);
                                                                                }
                                                                                free($1.token_value);
                                                                            };

return_types:       TK_PR_INT           {$$ = NULL; var_type = T_INT;}
                |   TK_PR_FLOAT         {$$ = NULL; var_type = T_FLOAT;};

parameter_list:     /* empty */         {$$ = NULL;}    
                |   mult_parameters     {$$ = NULL;};

mult_parameters:    mult_parameters TK_OC_OR parameters
                |   parameters;

parameters:         TK_IDENTIFICADOR '<' '-' return_types   {
                                                                struct entry *entry = search_table(stack->top, $1.token_value);
                                                                int error = check_declaration(entry, get_line_number());
                                                                if(error != NO_ERROR){
                                                                    exit(error);
                                                                }
                                                                else{
                                                                    $$ = NULL;
                                                                    entry = calloc(1, sizeof(struct entry));
                                                                    *entry = new_entry(get_line_number(), VAR, var_type, $1);
                                                                    add_entry(stack->top, entry);
                                                                }
                                                                free($1.token_value);
                                                            };

/* -----------------------------Corpo da função ----------------------------- */

/* ----------------------------- Comandos ----------------------------- */

body:               command_block           {$$ = $1;};

command_block:      '{' command_seq '}'     {$$ = $2;};

command_seq:        /* empty */             {$$ = NULL;}
                |   command command_seq     {
                                                if($1 != NULL){
                                                    $$ = $1;
                                                    if($2 != NULL){
                                                        asd_add_child(list_of_commands($$),$2);
                                                    }
                                                }
                                                else{
                                                    $$ = $2;
                                                }
                                            };

command:            simple_command ';'      {$$ = $1;};

simple_command:     var_declaration         {if($1!=NULL){$$ = $1;}}
                |   assignment              {if($1!=NULL){$$ = $1;}}
                |   flux_control            {if($1!=NULL){$$ = $1;}}
                |   return_op               {if($1!=NULL){$$ = $1;}}
                |   push command_block pop  {if($2!=NULL){$$ = $2;}}
                |   function_call           {if($1!=NULL){$$ = $1;}};

/* ----------------------------- Declaração de variável ----------------------------- */

var_lit:            TK_LIT_FLOAT    {$$ = asd_new($1.token_value, T_FLOAT); free($1.token_value);}
                |   TK_LIT_INT      {$$ = asd_new($1.token_value, T_INT); free($1.token_value);};

var_declaration:    return_types var_list   {$$ = $2;};

var_list:           var                     {if($1 != NULL){$$ = $1;}}
                |   var ',' var_list        {if($1 != NULL){$$ = $1;if($3 != NULL) asd_add_child($$, $3);}else{$$=$3;}};

var:                TK_IDENTIFICADOR                        {   
                                                                $$ = NULL;
                                                                struct entry *entry = search_table(stack->top, $1.token_value);
                                                                int error = check_declaration(entry, get_line_number());
                                                                if(error != NO_ERROR){
                                                                    exit(error);
                                                                }
                                                                else{
                                                                    entry = calloc(1, sizeof(struct entry));
                                                                    *entry = new_entry(get_line_number(), VAR, var_type, $1);
                                                                    add_entry(stack->top, entry);
                                                                }
                                                                free($1.token_value);
                                                            };
                |   TK_IDENTIFICADOR TK_OC_LE var_lit       {
                                                                struct entry *entry = search_table(stack->top, $1.token_value);
                                                                int error = check_declaration(entry, get_line_number());
                                                                if(error != NO_ERROR){
                                                                    exit(error);
                                                                }
                                                                else{
                                                                    entry = calloc(1, sizeof(struct entry));
                                                                    *entry = new_entry(get_line_number(), VAR, var_type, $1);
                                                                    add_entry(stack->top, entry);
                                                                    $$ = asd_new("<=", var_type);
                                                                    asd_add_child($$, asd_new($1.token_value, var_type));
                                                                    if($3 != NULL){
                                                                    asd_add_child($$, $3);
                                                                    }                                                             
                                                                }
                                                                free($1.token_value);
                                                            };


/* ----------------------------- Atribuição ----------------------------- */

assignment:         TK_IDENTIFICADOR '=' expr               {   
                                                                struct entry *entry = search_table_stack(stack, $1.token_value);
                                                                int error = check_use(entry, VAR, get_line_number(), $1.token_value);
                                                                if(error != NO_ERROR){
                                                                    exit(error);
                                                                }
                                                                else{
                                                                    $$ = asd_new("=", entry->type);
                                                                    asd_add_child($$, asd_new($1.token_value, entry->type));
                                                                    if($3 != NULL){
                                                                        asd_add_child($$, $3);
                                                                    }
                                                                }
                                                                free($1.token_value);
                                                            };

    
     

/* ----------------------------- Chamada de função ----------------------------- */

function_call:      TK_IDENTIFICADOR '(' args ')'           {
                                                                struct entry *entry = search_table_stack(stack, $1.token_value);
                                                                int error = check_use(entry, FUNC, get_line_number(), $1.token_value);
                                                                if(error != NO_ERROR){
                                                                    exit(error);
                                                                }
                                                                else{
                                                                    char buffer[6 + strlen($1.token_value)];
                                                                    strcpy(buffer, "call ");
                                                                    strcat(buffer, $1.token_value);
                                                                    $$ = asd_new(buffer, entry->type);
                                                                    if($3 != NULL){
                                                                        asd_add_child($$, $3);
                                                                    }
                                                                }
                                                                free($1.token_value);
                                                            };

args:               expr                                    {$$ = $1;}
                |   expr ',' args                           {$$ = $1; if($3 != NULL){asd_add_child($$, $3);}};

/* ----------------------------- Comando de retorno ----------------------------- */

return_op:          TK_PR_RETURN expr                       {$$ = asd_new("return", $2->type); if($2 != NULL){asd_add_child($$, $2);}}; 

/* ----------------------------- Controle de fluxo ----------------------------- */

flux_control:       TK_PR_IF '(' expr ')' push command_block pop                    {
                                                                                        $$ = asd_new("if", T_INT);
                                                                                        if($3 != NULL){
                                                                                            asd_add_child($$, $3);
                                                                                            if($6 != NULL){
                                                                                                asd_add_child($$, $6);
                                                                                            }
                                                                                        }
                                                                                    }
                |   TK_PR_IF '(' expr ')' push command_block pop TK_PR_ELSE push command_block pop  {
                                                                                                        $$ = asd_new("if", T_INT);
                                                                                                        if($3 != NULL){
                                                                                                            asd_add_child($$, $3);
                                                                                                            if($6 != NULL){
                                                                                                                asd_add_child($$, $6);
                                                                                                                if($10 != NULL){
                                                                                                                    asd_add_child($$, $10);
                                                                                                                }
                                                                                                            }
                                                                                                        }
                                                                                                    }
                |   TK_PR_WHILE '(' expr ')' push command_block pop                 {
                                                                                        $$ = asd_new("while", T_INT);
                                                                                        if($3 != NULL){
                                                                                            asd_add_child($$, $3);
                                                                                            if($6 != NULL){
                                                                                                asd_add_child($$, $6);
                                                                                            }
                                                                                        }
                                                                                    };

/* ----------------------------- Expressoes ----------------------------- */

expr:               expr_or                                 {$$ = $1;}; 

expr_or:            expr_or TK_OC_OR expr_and               {
                                                                $$ = asd_new("|", get_type($1->type, $3->type));
                                                                if($1 != NULL){
                                                                    asd_add_child($$, $1);
                                                                    if($3 != NULL){
                                                                        asd_add_child($$, $3);
                                                                    }
                                                                }
                                                            }
                |   expr_and                                {$$ = $1;};

expr_and:           expr_and TK_OC_AND expr_equality        {
                                                                $$ = asd_new("&", get_type($1->type, $3->type));
                                                                if($1 != NULL){
                                                                    asd_add_child($$, $1);
                                                                    if($3 != NULL){
                                                                        asd_add_child($$, $3);
                                                                    }
                                                                }
                                                            }
                |   expr_equality                           {$$ = $1;};

expr_equality:      expr_equality TK_OC_EQ expr_relational  {
                                                                $$ = asd_new("==", get_type($1->type, $3->type));
                                                                if($1 != NULL){
                                                                    asd_add_child($$, $1);
                                                                    if($3 != NULL){
                                                                        asd_add_child($$, $3);
                                                                    }
                                                                }
                                                            }
                |   expr_equality TK_OC_NE expr_relational  {
                                                                $$ = asd_new("!=", get_type($1->type, $3->type));
                                                                if($1 != NULL){
                                                                    asd_add_child($$, $1);
                                                                    if($3 != NULL){
                                                                        asd_add_child($$, $3);
                                                                    }
                                                                }
                                                            }
                |   expr_relational                         {$$ = $1;};

expr_relational:    expr_relational '<' expr_additive       {
                                                                $$ = asd_new("<", get_type($1->type, $3->type));
                                                                if($1 != NULL){
                                                                    asd_add_child($$, $1);
                                                                    if($3 != NULL){
                                                                        asd_add_child($$, $3);
                                                                    }
                                                                }
                                                            }
                |   expr_relational '>' expr_additive       {
                                                                $$ = asd_new(">", get_type($1->type, $3->type));
                                                                if($1 != NULL){
                                                                    asd_add_child($$, $1);
                                                                    if($3 != NULL){
                                                                        asd_add_child($$, $3);
                                                                    }
                                                                }
                                                            }
                |   expr_relational TK_OC_LE expr_additive  {
                                                                $$ = asd_new("<=", get_type($1->type, $3->type));
                                                                if($1 != NULL){
                                                                    asd_add_child($$, $1);
                                                                    if($3 != NULL){
                                                                        asd_add_child($$, $3);
                                                                    }
                                                                }
                                                            }
                |   expr_relational TK_OC_GE expr_additive  {
                                                                $$ = asd_new(">=", get_type($1->type, $3->type));
                                                                if($1 != NULL){
                                                                    asd_add_child($$, $1);
                                                                    if($3 != NULL){
                                                                        asd_add_child($$, $3);
                                                                    }
                                                                }
                                                            }
                |   expr_additive                           {$$ = $1;};

expr_additive:      expr_additive '+' expr_multiplicative   {
                                                                $$ = asd_new("+", get_type($1->type, $3->type));
                                                                if($1 != NULL){
                                                                    asd_add_child($$, $1);
                                                                    if($3 != NULL){
                                                                        asd_add_child($$, $3);
                                                                    }
                                                                }
                                                            }
                |   expr_additive '-' expr_multiplicative   {
                                                                $$ = asd_new("-", get_type($1->type, $3->type));
                                                                if($1 != NULL){
                                                                    asd_add_child($$, $1);
                                                                    if($3 != NULL){
                                                                        asd_add_child($$, $3);
                                                                    }
                                                                }
                                                            }
                |   expr_multiplicative                     {$$ = $1;};

expr_multiplicative:    expr_multiplicative '*' expr_unary  {
                                                                $$ = asd_new("*", get_type($1->type, $3->type));
                                                                if($1 != NULL){
                                                                    asd_add_child($$, $1);
                                                                    if($3 != NULL){
                                                                        asd_add_child($$, $3);
                                                                    }
                                                                }
                                                            }
                    |   expr_multiplicative '/' expr_unary  {
                                                                $$ = asd_new("/", get_type($1->type, $3->type));
                                                                if($1 != NULL){
                                                                    asd_add_child($$, $1);
                                                                    if($3 != NULL){
                                                                        asd_add_child($$, $3);
                                                                    }
                                                                }
                                                            }
                    |   expr_multiplicative '%' expr_unary  {
                                                                $$ = asd_new("%", get_type($1->type, $3->type));
                                                                if($1 != NULL){
                                                                    asd_add_child($$, $1);
                                                                    if($3 != NULL){
                                                                        asd_add_child($$, $3);
                                                                    }
                                                                }
                                                            }
                    |   expr_unary                          {$$ = $1;};

expr_unary:         '-' expr_unary                          {
                                                                $$ = asd_new("-", $2->type);
                                                                if($2 != NULL){
                                                                    asd_add_child($$, $2);
                                                                }
                                                            }
                |   '!' expr_unary                          {
                                                                $$ = asd_new("!", $2->type);
                                                                if($2 != NULL){
                                                                    asd_add_child($$, $2);
                                                                }
                                                            }
                |   primary_expr                            {$$ = $1;};

primary_expr:       oper                                    {$$ = $1;}
                |   '(' expr ')'                            {$$ = $2;};

/* ----------------------------- Operandos ----------------------------- */

oper:               TK_IDENTIFICADOR                        {
                                                                struct entry *entry = search_table_stack(stack, $1.token_value);
                                                                int error = check_use(entry, VAR, get_line_number(), $1.token_value);
                                                                if(error != NO_ERROR){
                                                                    exit(error);
                                                                }
                                                                else{
                                                                    $$ = asd_new($1.token_value, entry->type); 
                                                                    free($1.token_value);    
                                                                }
                                                            }
                |   TK_LIT_FLOAT                            {$$ = asd_new($1.token_value, T_FLOAT); free($1.token_value);}
                |   TK_LIT_INT                              {$$ = asd_new($1.token_value, T_INT); free($1.token_value);}
                |   function_call                           {$$ = $1;};

push:   {   
            struct table *table = new_table();
            push_table(&stack, table);
            $$ = NULL;
        };
pop:    {
            pop_table(&stack);
            $$ = NULL;
        };

%%

void yyerror(char const *mensagem) {
    printf("Erro na linha %d: %s\n", get_line_number(), mensagem);
}
