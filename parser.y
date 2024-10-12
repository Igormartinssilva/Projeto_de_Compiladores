%{
    #include <stdio.h>
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



programa: lista_de_funcoes | /* vazio */;

lista_de_funcoes: lista_de_funcoes funcao | funcao;

funcao: cabecalho corpo;

cabecalho: TK_IDENTIFICADOR '=' lista_de_parametros '>' tipos;

/*
A lista de parâmetros é composta por 
zero ou mais parâmetros de
entrada, separados por TK_OC_OR "|"
*/
lista_de_parametros:  lista_de_parametros TK_OC_OR parametros  | parametros | /*vazio*/  ;
/*
Cada parâmetro é definido pelo seu nome 
seguido do caractere
menor ’<’, seguido do caractere menos ’-’, seguido
do tipo.
*/
parametros: TK_IDENTIFICADOR '<' '-' tipos  ;

tipos: TK_PR_INT | TK_PR_FLOAT;

/*
teste para o corpo, falta implementar
*/
corpo: bloco_de_comandos ;

/*
Um bloco de comandos é definido entre chaves,
e consiste em uma sequência, possivelmente va-
zia, de comandos simples cada um terminado por
ponto-e-vírgula.
*/
bloco_de_comandos: '{' seq_comandos '}' ;

/* 
um bloco de comandos é consi-
derado como um comando único simples, recursi-
vamente, e pode ser utilizado em qualquer cons-
trução que aceite um comando simples.
*/

seq_comandos: /*vazio*/ | seq_comandos comandos_simples  | comandos_simples ';' ;

/*
Os comandos simples da linguagem podem ser:
declaração de variável, atribuição, construções de
fluxo de controle, operação de retorno, um bloco
de comandos, e chamadas de função.
*/

comandos_simples: declaracao_var | atribuicao  | const_flux  | op_ret  | bloco_de_comandos  | cham_func ;

/* 
    Declaração de Variável: Consiste no tipo da va-
riável seguido de uma lista composta de pelo me-
nos um nome de variável (identificador) separa-
das por vírgula. Os tipos podem ser int e float.
    Uma variável pode ser opcionalmente inicializada
caso sua declaração seja seguida do operador com-
posto TK_OC_LE e de um literal.
*/
tipo_lit: TK_LIT_FLOAT | TK_LIT_INT ;
declaracao_var: tipos var | ',' declaracao_var;
var: TK_IDENTIFICADOR | TK_IDENTIFICADOR TK_OC_LE tipo_lit ;


atribuicao: ;

const_flux: ;

op_ret: ;

cham_func: ;
%%



void yyerror (char const *mensagem)
{
    fprintf(stderr, "%s\n", mensagem);
}