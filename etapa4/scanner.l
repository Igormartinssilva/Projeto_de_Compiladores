/* 	Igor Martins Silva - 00333069
 	Carlos Eduardo Menin - 00332900
*/

%{
#include <stdio.h>
#include <string.h>
#include "parser.tab.h"
#include "../include/valLex.h"

int get_line_number();

void set_yylval(int token_type, char* value){
  yylval.valor_lexico = create(get_line_number(), token_type, strdup(value));
}

%}

%option yylineno
%option noyywrap

%%
[ \t\n]+ { }

"//"[^\n]* { }

"int" { return TK_PR_INT; }
"float" { return TK_PR_FLOAT; }
"if" { return TK_PR_IF; }
"else" { return TK_PR_ELSE; }
"while" { return TK_PR_WHILE; }
"return" { return TK_PR_RETURN; }

[!*/%+\-<>{}()=,;]   { return (int)yytext[0]; }

"<=" { return TK_OC_LE; }
">=" { return TK_OC_GE; }
"==" { return TK_OC_EQ; }
"!=" { return TK_OC_NE; }
"&" { return TK_OC_AND; }
"|" { return TK_OC_OR; }

[a-z_][a-z0-9_]*   { set_yylval(TT_ID, yytext); return TK_IDENTIFICADOR; }

[0-9]+ { set_yylval(TT_LIT, yytext);  return TK_LIT_INT; }
[0-9]*\.[0-9]+ { set_yylval(TT_LIT, yytext);  return TK_LIT_FLOAT; }

. { return TK_ERRO; }

%%

int get_line_number(void){
    return yylineno;
}
