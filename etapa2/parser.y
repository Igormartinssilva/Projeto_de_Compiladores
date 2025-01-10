// Igor Martins Silva - 00333069
// Carlos Eduardo Menin - 00332900


%{
    #include <stdio.h>
    int get_line_number();
    int yylex(void);
    void yyerror (char const *mensagem);
%}

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
%token TK_IDENTIFICADOR
%token TK_LIT_INT
%token TK_LIT_FLOAT
%token TK_ERRO

%%

program:            function_list
                |   /* vazio */;

function_list:      function_list function
                |   function;

function:           header body;

/* Header */

header:             TK_IDENTIFICADOR '=' parameter_list '>' return_types;

return_types:       TK_PR_INT
                |   TK_PR_FLOAT ;

parameter_list:     /* empty */ 
                |   mult_parameters ;

mult_parameters:    mult_parameters TK_OC_OR parameters
                |   parameters ;

parameters:         TK_IDENTIFICADOR '<' '-' return_types ;

/* Body */

body:               command_block;

command_block:      '{' command_seq '}' ;

command_seq:        /* empty */
                |   command_seq command ;

command:            simple_command ';' ;

simple_command:     var_declaration
                |   assignment
                |   flux_control
                |   return_op
                |   command_block
                |   function_call ;

var_lit:            TK_LIT_FLOAT 
                |   TK_LIT_INT ;

var_declaration:    return_types var_list;

var_list:           var 
                |   var ',' var_list;

var:                TK_IDENTIFICADOR
                |   TK_IDENTIFICADOR TK_OC_LE var_lit ;

assignment:         TK_IDENTIFICADOR '=' expr ;

function_call:      TK_IDENTIFICADOR '(' args ')'
                |   TK_IDENTIFICADOR '(' ')';

args:               expr
                |   args ',' expr;

return_op:          TK_PR_RETURN expr;

flux_control:       TK_PR_IF '(' expr ')' command_block
                |   TK_PR_IF '(' expr ')' command_block TK_PR_ELSE command_block
                |   TK_PR_WHILE '(' expr ')' command_block;

expr:               expr_or;  

expr_or:            expr_or TK_OC_OR expr_and
                |   expr_and;

expr_and:           expr_and TK_OC_AND expr_equality
                |   expr_equality;

expr_equality:      expr_equality TK_OC_EQ expr_relational
                |   expr_equality TK_OC_NE expr_relational
                |   expr_relational;

expr_relational:    expr_relational '<' expr_additive
                |   expr_relational '>' expr_additive
                |   expr_relational TK_OC_LE expr_additive
                |   expr_relational TK_OC_GE expr_additive
                |   expr_additive;

expr_additive:      expr_additive '+' expr_multiplicative
                |   expr_additive '-' expr_multiplicative
                |   expr_multiplicative;

expr_multiplicative:    expr_multiplicative '*' expr_unary
                    |   expr_multiplicative '/' expr_unary
                    |   expr_multiplicative '%' expr_unary
                    |   expr_unary;

expr_unary:         '-' expr_unary
                |   '!' expr_unary
                |   primary_expr;

primary_expr:       oper
                |   '(' expr ')';

oper:               TK_IDENTIFICADOR 
                |   TK_LIT_FLOAT
                |   TK_LIT_INT 
                |   function_call ;

%%

void yyerror(char const *mensagem) {
    printf("Erro na linha %d: %s\n", get_line_number(), mensagem);
}
