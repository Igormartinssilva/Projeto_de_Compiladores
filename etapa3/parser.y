// Igor Martins Silva - 00333069
// Carlos Eduardo Menin - 00332900


%{
    #include <stdio.h>
    #include <string.h>

    int get_line_number();
    int yylex(void);
    void yyerror (char const *mensagem);
%}

%{
    extern void *arvore;
%}

%code requires{ 
  #include "../include/arvore.h"
  #include "../include/valLex.h"
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
expr_additive expr_multiplicative expr_unary primary_expr oper


%%

/* ----------------------------- INCIALIZACAO DO PROGRAMA ----------------------------- */

program:            function_list   {$$ = $1; arvore = $$;}
                |   /* vazio */     {$$ = NULL; arvore = $$;};

function_list:      function function_list {$$ = $1;if($2 != NULL){asd_add_child($$, $2);}}
                |   function                {$$ = $1;};

function:           header body {$$ = $1;if($2 != NULL){asd_add_child($$, $2);}};

/* ----------------------------- CABECALHO DA FUNCAO ----------------------------- */

header:             TK_IDENTIFICADOR '=' parameter_list '>' return_types {$$ = asd_new($1.token_value); free($1.token_value);};

return_types:       TK_PR_INT           {$$ = NULL;}
                |   TK_PR_FLOAT         {$$ = NULL;};

parameter_list:     /* empty */         {$$ = NULL;}    
                |   mult_parameters     {$$ = NULL;};

mult_parameters:    mult_parameters TK_OC_OR parameters
                |   parameters;

parameters:         TK_IDENTIFICADOR '<' '-' return_types   {$$ = NULL; free($1.token_value);};

/* ----------------------------- CORPO DA FUNCAO ----------------------------- */

/* ----------------------------- COMANDOS ----------------------------- */

body:               command_block           {$$ = $1;};

command_block:      '{' command_seq '}'     {$$ = $2;};

command_seq:        /* empty */             {$$ = NULL;}
                |   command command_seq     {if($1 != NULL){$$ = $1; if($2 != NULL){asd_add_child(list_of_commands($$),$2);}}else{$$ = $2;}};

command:            simple_command ';'      {$$ = $1;};

simple_command:     var_declaration {if($1!=NULL){$$ = $1;}}
                |   assignment      {if($1!=NULL){$$ = $1;}}
                |   flux_control    {if($1!=NULL){$$ = $1;}}
                |   return_op       {if($1!=NULL){$$ = $1;}}
                |   command_block   {if($1!=NULL){$$ = $1;}}
                |   function_call   {if($1!=NULL){$$ = $1;}};

/* ----------------------------- DECLARACAO DE VARIAVEIS ----------------------------- */

var_lit:            TK_LIT_FLOAT    {$$ = asd_new($1.token_value); free($1.token_value);}
                |   TK_LIT_INT      {$$ = asd_new($1.token_value); free($1.token_value);};

var_declaration:    return_types var_list   {$$ = $2;};

var_list:           var                     {if($1 != NULL){$$ = $1;}}
                |   var ',' var_list        {if($1 != NULL){$$ = $1;if($3 != NULL) asd_add_child($$, $3);}else{$$=$3;}};

var:                TK_IDENTIFICADOR                        {$$ = NULL; free($1.token_value);};
                |   TK_IDENTIFICADOR TK_OC_LE var_lit       {$$ = asd_new("<="); asd_add_child($$, asd_new($1.token_value)); if($3 != NULL){asd_add_child($$, $3);} free($1.token_value);};


/* ----------------------------- ATRIBUICAO ----------------------------- */

assignment:         TK_IDENTIFICADOR '=' expr               {$$ = asd_new("="); asd_add_child($$, asd_new($1.token_value)); if($3 != NULL){asd_add_child($$, $3);} free($1.token_value);};

/* ----------------------------- CHAMADA DE FUNCAO ----------------------------- */

function_call:      TK_IDENTIFICADOR '(' args ')'           {char buffer[6 + strlen($1.token_value)]; strcpy(buffer, "call "); strcat(buffer, $1.token_value); $$ = asd_new(buffer); if($3 != NULL){asd_add_child($$, $3);} free($1.token_value);};

args:               expr                                    {$$ = $1;}
                |   expr ',' args                           {$$ = $1; if($3 != NULL){asd_add_child($$, $3);}};

/* ----------------------------- COMANDO DE RETORNO ----------------------------- */

return_op:          TK_PR_RETURN expr                       {$$ = asd_new("return"); if($2 != NULL){asd_add_child($$, $2);}}; 

/* ----------------------------- CONTROLE DE FLUXO ----------------------------- */

flux_control:       TK_PR_IF '(' expr ')' command_block                           {$$ = asd_new("if");if($3 != NULL){asd_add_child($$, $3); if($5 != NULL){asd_add_child($$, $5);}}}
                |   TK_PR_IF '(' expr ')' command_block TK_PR_ELSE command_block  {$$ = asd_new("if");if($3 != NULL){asd_add_child($$, $3); if($5 != NULL){asd_add_child($$, $5); if($7 != NULL){asd_add_child($$, $7);}}}}
                |   TK_PR_WHILE '(' expr ')' command_block                        {$$ = asd_new("while");if($3 != NULL){asd_add_child($$, $3); if($5 != NULL){asd_add_child($$, $5);}}};

/* ----------------------------- EXPRESSOES ----------------------------- */

expr:               expr_or                                 {$$ = $1;}; 

expr_or:            expr_or TK_OC_OR expr_and               {$$ = asd_new("|");if($1 != NULL){asd_add_child($$, $1); if($3 != NULL){asd_add_child($$, $3);}}}
                |   expr_and                                {$$ = $1;};

expr_and:           expr_and TK_OC_AND expr_equality        {$$ = asd_new("&");if($1 != NULL){asd_add_child($$, $1); if($3 != NULL){asd_add_child($$, $3);}}}
                |   expr_equality                           {$$ = $1;};

expr_equality:      expr_equality TK_OC_EQ expr_relational  {$$ = asd_new("==");if($1 != NULL){asd_add_child($$, $1); if($3 != NULL){asd_add_child($$, $3);}}}
                |   expr_equality TK_OC_NE expr_relational  {$$ = asd_new("!=");if($1 != NULL){asd_add_child($$, $1); if($3 != NULL){asd_add_child($$, $3);}}}
                |   expr_relational                         {$$ = $1;};

expr_relational:    expr_relational '<' expr_additive       {$$ = asd_new("<"); if($1 != NULL){asd_add_child($$, $1); if($3 != NULL){asd_add_child($$, $3);}}}
                |   expr_relational '>' expr_additive       {$$ = asd_new(">");if($1 != NULL){asd_add_child($$, $1); if($3 != NULL){asd_add_child($$, $3);}}}
                |   expr_relational TK_OC_LE expr_additive  {$$ = asd_new("<=");if($1 != NULL){asd_add_child($$, $1); if($3 != NULL){asd_add_child($$, $3);}}}
                |   expr_relational TK_OC_GE expr_additive  {$$ = asd_new(">=");if($1 != NULL){asd_add_child($$, $1); if($3 != NULL){asd_add_child($$, $3);}}}
                |   expr_additive                           {$$ = $1;};

expr_additive:      expr_additive '+' expr_multiplicative   {$$ = asd_new("+"); if($1 != NULL){asd_add_child($$, $1); if($3 != NULL){asd_add_child($$, $3);}}}
                |   expr_additive '-' expr_multiplicative   {$$ = asd_new("-"); if($1 != NULL){asd_add_child($$, $1); if($3 != NULL){asd_add_child($$, $3);}}}
                |   expr_multiplicative                     {$$ = $1;};

expr_multiplicative:    expr_multiplicative '*' expr_unary  {$$ = asd_new("*"); if($1 != NULL){asd_add_child($$, $1); if($3 != NULL){asd_add_child($$, $3);}}}
                    |   expr_multiplicative '/' expr_unary  {$$ = asd_new("/"); if($1 != NULL){asd_add_child($$, $1); if($3 != NULL){asd_add_child($$, $3);}}}
                    |   expr_multiplicative '%' expr_unary  {$$ = asd_new("%"); if($1 != NULL){asd_add_child($$, $1); if($3 != NULL){asd_add_child($$, $3);}}}
                    |   expr_unary                          {$$ = $1;};

expr_unary:         '-' expr_unary                          {$$ = asd_new("-"); if($2 != NULL){asd_add_child($$, $2);}}
                |   '!' expr_unary                          {$$ = asd_new("!"); if($2 != NULL){asd_add_child($$, $2);}}
                |   primary_expr                            {$$ = $1;};

primary_expr:       oper                                    {$$ = $1;}
                |   '(' expr ')'                            {$$ = $2;};

/* ----------------------------- OPERANDOS ----------------------------- */

oper:               TK_IDENTIFICADOR                        {$$ = asd_new($1.token_value); free($1.token_value);}
                |   TK_LIT_FLOAT                            {$$ = asd_new($1.token_value); free($1.token_value);}
                |   TK_LIT_INT                              {$$ = asd_new($1.token_value); free($1.token_value);}
                |   function_call                           {$$ = $1;};

%%

void yyerror(char const *mensagem) {
    printf("Erro na linha %d: %s\n", get_line_number(), mensagem);
}
