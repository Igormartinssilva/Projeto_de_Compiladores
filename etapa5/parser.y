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
  #include "../include/iloc.h"
  #include "../include/tabela.h"
  #include "../include/types.h"
  #include "../include/funcParser.h"
}

%union{
	struct valLex *valor_lexico;
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

program:            push function_list pop  
{
    $$ = $2;
    if($$ != NULL) 
        $$->code = $2->code;
    arvore = $$;   
}
                    |   /* vazio */             
{
    $$ = NULL;
    arvore = $$;
};

function_list:      function function_list  
{   
    $$ = $1;
    if($2 != NULL){
        asd_add_child($$, $2);
        if($1->code != NULL)
            $$->code = merge_code(UNIT_CODE, $1->code, $2->code);
    }
}
|                   function                
{
    $$ = $1;
};

function:           push header body pop    
{   
    $$ = $2;
    if($3 != NULL){
        asd_add_child($$, $3);
        $$->code = $3->code;
    }
};

/* ----------------------------- Cabeçalho da função ----------------------------- */

header:             TK_IDENTIFICADOR '=' parameter_list '>' return_types    
{
    handle_declaration(stack->next, get_line_number(), $1->token_value, FUNC, var_type,  $1);
    $$ = asd_create_with_type($1->token_value, var_type);
    free($1->token_value);
};

return_types:           TK_PR_INT           
{
    $$ = NULL;
    var_type = T_INT;
}
|   TK_PR_FLOAT         
{
    $$ = NULL;
    var_type = T_FLOAT;
};

parameter_list:         /* empty */         
{
    $$ = NULL;
}    
|                       mult_parameters     
{
    $$ = NULL;
};

mult_parameters:        mult_parameters TK_OC_OR parameters
|                       parameters;

parameters:             TK_IDENTIFICADOR '<' '-' return_types   
{
    $$ = NULL;
    handle_declaration(stack, get_line_number(), $1->token_value, VAR, var_type, $1);
    free($1->token_value);
};

/* -----------------------------Corpo da função ----------------------------- */

/* ----------------------------- Comandos ----------------------------- */

body:                   command_block           
{
    $$ = $1;
};

command_block:          '{' command_seq '}'     
{
    $$ = $2;
    if($$ != NULL) 
        $$->code = $2->code; 
};

command_seq:            /* empty */             
{
    $$ = NULL;
}
|                       command command_seq     
{
    if($1 != NULL){
        $$ = $1;//
        if($2 != NULL){
            asd_add_child(list_of_commands($$),$2);
            $$->code = merge_code(UNIT_CODE, $1->code, $2->code);
        }
    }
    else{
        $$ = $2;
    }
};

command:                simple_command ';'      
{
    $$ = $1;
};

simple_command:         var_declaration         
{
    if($1!=NULL)
        $$ = $1;    
}
|                       assignment              
{
    if($1!=NULL)
        $$ = $1;
}
|                       flux_control            
{
    if($1!=NULL)
        $$ = $1;
}
|                       return_op               
{
    if($1!=NULL)
        $$ = $1;
}
|                       push command_block pop  
{
    if($2!=NULL)
        $$ = $2;
}
|                       function_call           
{
    if($1!=NULL)
        $$ = $1;
};

/* ----------------------------- Declaração de variável ----------------------------- */

var_lit:                TK_LIT_FLOAT    
{
    $$ = asd_create_with_type($1->token_value, T_FLOAT);
    $$ = gen_lit_code($$);
    free($1->token_value);
}
|                       TK_LIT_INT      
{
    $$ = asd_create_with_type($1->token_value, T_INT);
    $$ = gen_lit_code($$);
    free($1->token_value);
};

var_declaration:        return_types var_list   
{
    $$ = $2;
};

var_list:               var                     
{
    if($1 != NULL)
        $$ = $1;
}
|                       var ',' var_list        
{
    if($1 != NULL)
    {
        $$ = $1;
        if($3 != NULL){
            asd_add_child($$, $3);
            $$->code = merge_code(UNIT_CODE, $1->code, $3->code);
        }
    }else
        $$=$3;
};

var:                    TK_IDENTIFICADOR                        
{   
    $$ = NULL;
    handle_declaration(stack, get_line_number(), $1->token_value, VAR, var_type, $1);
    free($1->token_value);
};
|                       TK_IDENTIFICADOR TK_OC_LE var_lit       
{
    struct entry *entry = handle_declaration(stack, get_line_number(), $1->token_value, VAR, var_type, $1);
    $$ = asd_create_with_children_and_type("<=", asd_new($1->token_value), $3, var_type);
    $$ = gen_assign_code($$, entry, $3);
    free($1->token_value);
};


/* ----------------------------- Atribuição ----------------------------- */

assignment:             TK_IDENTIFICADOR '=' expr               
{
    struct entry *entry = handle_use(stack, $1->token_value, VAR, get_line_number());
    $$ = asd_create_with_child_and_type("=", $3, entry->type);
    $$ = gen_assign_code($$, entry, $3);
    free($1->token_value);
};   

/* ----------------------------- Chamada de função ----------------------------- */

function_call:          TK_IDENTIFICADOR '(' args ')'           
{   
    char buffer[6 + strlen($1->token_value)];
    strcpy(buffer, "call "); 
    strcat(buffer, $1->token_value);
    handle_use(stack, $1->token_value, FUNC, get_line_number());
    $$ = asd_create_with_child(buffer, $3);
    $$->code = $3->code;
    free($1->token_value);
};

args:                   expr                                    
{
    $$ = $1;
}
|                       expr ',' args                           
{
    $$ = $1;
    asd_add_child($$, $3);
    $$->code = merge_code(UNIT_CODE, $1->code, $3->code);
};

/* ----------------------------- Comando de retorno ----------------------------- */

return_op:              TK_PR_RETURN expr                       
{
    $$ = asd_create_with_child("return", $2);
    $$->code = $2->code;
}; 

/* ----------------------------- Controle de fluxo ----------------------------- */

flux_control:           TK_PR_IF '(' expr ')' push command_block pop                    
{
    $$ = asd_create_control_node("if", $3, $6, NULL);
    $$ = gen_and_merge_if_code($$, $3, $6);
}
|                       TK_PR_IF '(' expr ')' push command_block pop TK_PR_ELSE push command_block pop  
{
    $$ = asd_create_control_node("if", $3, $6, $10);
    $$ = gen_and_merge_if_else_code($$, $3, $6, $10);
}
|                       TK_PR_WHILE '(' expr ')' push command_block pop                 
{
    $$ = asd_create_control_node("while", $3, $6, NULL);
    $$ = gen_and_merge_while_code($$, $3, $6);
};

/* ----------------------------- Expressoes ----------------------------- */

expr:                   expr_or                                 
{
    $$ = $1;
}; 

expr_or:                expr_or TK_OC_OR expr_and               
{
    $$ = asd_create_with_children_and_type("|", $1, $3,get_type($1->type, $3->type));
    $$ = gen_and_merge_expr_code($$,"or",$1,$3);
}
|                       expr_and                                
{
    $$ = $1;
};

expr_and:               expr_and TK_OC_AND expr_equality        
{
    $$ = asd_create_with_children_and_type("&", $1, $3,get_type($1->type, $3->type));
    $$ = gen_and_merge_expr_code($$,"and",$1,$3);
}
|                       expr_equality                           
{
    $$ = $1;
};

expr_equality:          expr_equality TK_OC_EQ expr_relational  
{
    $$ = asd_create_with_children_and_type("==", $1, $3,get_type($1->type, $3->type));
    $$ = gen_and_merge_expr_code($$,"cmp_EQ",$1,$3);
}
|                       expr_equality TK_OC_NE expr_relational  
{
    $$ = asd_create_with_children_and_type("!=", $1, $3,get_type($1->type, $3->type));
    $$ = gen_and_merge_expr_code($$,"cmp_NE",$1,$3);
}                                                            
|                       expr_relational                         
{
    $$ = $1;
};

expr_relational:        expr_relational '<' expr_additive       
{
    $$ = asd_create_with_children_and_type("<", $1, $3,get_type($1->type, $3->type));
    $$ = gen_and_merge_expr_code($$,"cmp_LT",$1,$3);
}                                                            
|                       expr_relational '>' expr_additive       
{
    $$ = asd_create_with_children_and_type(">", $1, $3,get_type($1->type, $3->type));
    $$ = gen_and_merge_expr_code($$,"cmp_GT",$1,$3);
}                                                            
|                       expr_relational TK_OC_LE expr_additive  
{
    $$ = asd_create_with_children_and_type("<=", $1, $3,get_type($1->type, $3->type));
    $$ = gen_and_merge_expr_code($$,"cmp_LE",$1,$3);
}                                                            
|                       expr_relational TK_OC_GE expr_additive  
{
    $$ = asd_create_with_children_and_type(">=", $1, $3,get_type($1->type, $3->type));
    $$ = gen_and_merge_expr_code($$,"cmp_GE",$1,$3);
}                                                            
|                       expr_additive                           
{
    $$ = $1;
};

expr_additive:          expr_additive '+' expr_multiplicative   
{
    $$ = asd_create_with_children_and_type("+", $1, $3,get_type($1->type, $3->type));
    $$ = gen_and_merge_expr_code($$,"add",$1,$3);
}                                                            
|                       expr_additive '-' expr_multiplicative   
{
    $$ = asd_create_with_children_and_type("-", $1, $3,get_type($1->type, $3->type));
    $$ = gen_and_merge_expr_code($$,"sub",$1,$3);
}                                                            
|                       expr_multiplicative                     
{
    $$ = $1;
};

expr_multiplicative:    expr_multiplicative '*' expr_unary  
{
    $$ = asd_create_with_children_and_type("*", $1, $3,get_type($1->type, $3->type));
    $$ = gen_and_merge_expr_code($$,"mult",$1,$3);
}                                                            
|                       expr_multiplicative '/' expr_unary  
{
    $$ = asd_create_with_children_and_type("/", $1, $3,get_type($1->type, $3->type));
    $$ = gen_and_merge_expr_code($$,"div",$1,$3);
}                   
|                       expr_multiplicative '%' expr_unary  
{
    $$ = asd_create_with_children_and_type("%", $1, $3,get_type($1->type, $3->type));
}                                         
|                       expr_unary
{
    $$ = $1;
};

expr_unary:         '-' expr_unary                          
{
    $$ = asd_create_with_child_and_type("-", $2, $2->type);
    $$ = gen_and_merge_unary_code($$,"multI",$2,"-1");
}
|                   '!' expr_unary                          
{
    $$ = asd_create_with_child_and_type("!", $2, $2->type);
    $$ = gen_and_merge_neg_code($$, $2);

}
|                   primary_expr                            
{
    $$ = $1;
};

primary_expr:       oper                                    
{
    $$ = $1;
}
|                   '(' expr ')'                            
{
    $$ = $2;
};

/* ----------------------------- Operandos ----------------------------- */

oper:               TK_IDENTIFICADOR                        
{
    struct entry *entry = handle_use(stack, $1->token_value, VAR, get_line_number());
    $$ = asd_create_with_type($1->token_value, entry->type);
    $$ = gen_oper_code($$,entry);
    free($1->token_value);    
}
|                   TK_LIT_FLOAT                            
{
    $$ = asd_create_with_type($1->token_value,T_FLOAT);
    $$ = gen_lit_code($$);
    free($1->token_value);
}
|                   TK_LIT_INT                              
{
    $$ = asd_create_with_type($1->token_value,T_INT);
    $$ = gen_lit_code($$);
    free($1->token_value);
}
|                   function_call                           
{
    $$ = $1;
};

push:   {   
            struct table *table = new_table();
            push_table(&stack, table);
            $$ = NULL;
        };
pop:    {
            pop_table(stack);
            $$ = NULL;
        };

%%
void yyerror(char const *mensagem) {
    printf("Erro na linha %d: %s\n", get_line_number(), mensagem);
}






