%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "src/ast.h"
#include "src/tabela.h"

typedef struct stack {
    int indent[100];
    int indent_top;
} stack;

extern stack *s;

extern stack *stack_init();

int yylex(void);
void yyerror(const char *s);

// Função para imprimir resultado da expressão
void print_result(int value) {
    printf("Resultado: %d\n", value);
}
%}

%union {
    int intValue;
    double floatValue;
    char* strValue;
    struct NoAST* no;
}

// Com valor semantico 
%token <intValue> INT
%token <floatValue> FLOAT
%token <strValue> IDENTIFIER
%token <strValue> STRING

// Palavras reservadas sem valor semântico 
%token IF ELSE WHILE FOR AND OR NOT IS IN PASS DEF RETDEF

// Operadores duplos sem valor semântico
%token EQUALS DIFFROM GTOREQUAL LSOREQUAL INCREMENT DECREMENT INCTIMES DIVBY MODBY EXPONENTIAL INTDIVIDE

// Operadores simples sem valor semântico 
%token DIFFERENT ASSIGNMENT PLUS MINUS TIMES DIVIDE MODULE GREATER LESS LPAREN RPAREN COLON SEMICOLON COMMA

// Indentação
%token INDENT DEDENT NEWLINE

// Declaração de tipos para regras gramaticais
%type <no> expr
%type <no> simple_statement
%type <no> assignment_statement
%type <no> statement
%type <no> statement_list
%type <no> compound_statement
%type <no> if_statement
%type <no> suite
%type <no> function_definition
%type <no> parameter_list
%type <no> parameter
%type <no> return_statement
%type <no> function_call
%type <no> argument_list

// Precedência dos operadores (menor para maior)
%left OR
%left AND
%left NOT
%left EQUALS DIFFROM GTOREQUAL LSOREQUAL GREATER LESS
%left PLUS MINUS
%left TIMES DIVIDE MODULE INTDIVIDE
%right EXPONENTIAL
%right UMINUS

%%

program:
    /* vazio */        { $$ = NULL; }
    | statement_list   { 
        $$ = $1;
        printf("\n[SUCESSO!] AST construída com sucesso\n");
        imprimirAST($$);  // Imprimir a árvore para debug
    }
    ;

statement_list:
    statement           { $$ = $1; }
    | statement_list statement {
        $$ = novoNoOp(';', $1, $2);  // Usa ; como operador de sequência
    }
    ;

statement:
    NEWLINE
    | simple_statement NEWLINE
    | compound_statement
    ;

simple_statement:
    expr               { $$ = $1; }
    | return_statement { $$ = $1; }
    | assignment_statement { $$ = $1; }
    ;

assignment_statement:
    IDENTIFIER ASSIGNMENT expr {
        $$ = novoNoOp('=', novoNoId($1, T_INT), $3);
    }
    ;

compound_statement:
    if_statement
    | function_definition
   ;

// Um "bloco" de código indentado
suite:
    NEWLINE INDENT statement_list DEDENT { $$ = $3; }
    ;

if_statement:
    IF expr COLON suite {
        $$ = novoNoOp('?', $2, $4);  // ? representa IF
    }
    | IF expr COLON suite ELSE COLON suite {
        NoAST* if_node = novoNoOp('?', $2, $4);
        $$ = novoNoOp(':', if_node, $7);  // : representa ELSE
    }
    ;

function_definition:
    DEF IDENTIFIER LPAREN parameter_list RPAREN COLON suite {
        NoAST* func_name = novoNoId($2, T_INT);
        NoAST* func_params = $4;
        NoAST* func_body = $7;
        $$ = novoNoOp('F', novoNoOp('P', func_name, func_params), func_body);
    }
    ;

parameter_list:
    /* vazio */        { $$ = NULL; }
    | parameter        { $$ = $1; }
    | parameter_list COMMA parameter {
        $$ = novoNoOp(',', $1, $3);
    }
    ;

parameter:
    IDENTIFIER {
        $$ = novoNoId($1, T_INT);
    }
    | IDENTIFIER ASSIGNMENT expr {
        $$ = novoNoOp('=', novoNoId($1, T_INT), $3);
    }
    ;

return_statement:
    RETDEF
    | RETDEF expr
    ;

function_call:
    IDENTIFIER LPAREN argument_list RPAREN {
        $$ = novoNoOp('C', novoNoId($1, T_INT), $3);  // C representa Call
    }
    ;

argument_list:
    /* vazio */        { $$ = NULL; }
    | expr             { $$ = $1; }
    | argument_list COMMA expr {
        $$ = novoNoOp(',', $1, $3);
    }
    ;


// Expressões aritméticas e lógicas
expr:
    expr OR expr        { $$ = novoNoOp('||', $1, $3); }
  | expr AND expr       { $$ = novoNoOp('&&', $1, $3); }
  | NOT expr            { $$ = novoNoOp('!', $2, NULL); }
  | expr EQUALS expr    { $$ = novoNoOp('=', $1, $3); }
  | expr DIFFROM expr   { $$ = novoNoOp('!=', $1, $3); }
  | expr GREATER expr   { $$ = novoNoOp('>', $1, $3); }
  | expr LESS expr      { $$ = novoNoOp('<', $1, $3); }
  | expr GTOREQUAL expr { $$ = novoNoOp('>=', $1, $3); }  // g para >=
  | expr LSOREQUAL expr { $$ = novoNoOp('<=', $1, $3); }  // l para <=
  | expr PLUS expr      { $$ = novoNoOp('+', $1, $3); }
  | expr MINUS expr     { $$ = novoNoOp('-', $1, $3); }
  | expr TIMES expr     { $$ = novoNoOp('*', $1, $3); }
  | expr DIVIDE expr    { $$ = novoNoOp('/', $1, $3); }
  | expr MODULE expr    { $$ = novoNoOp('%', $1, $3); }
  | expr EXPONENTIAL expr{ $$ = novoNoOp('^', $1, $3); }
  | LPAREN expr RPAREN  { $$ = $2; }
  | INT                 { $$ = novoNoNum($1); }
  | FLOAT               { $$ = novoNoNum((int)$1); }  // Temporário até implementar float
  | IDENTIFIER          { $$ = novoNoId($1, T_INT); }
  | MINUS expr %prec UMINUS { $$ = novoNoOp('-', novoNoNum(0), $2); }
  | function_call       { $$ = $1; }
  ;

%%

// Função para tratamento de erros
void yyerror(const char *s) {
    printf("Erro de sintaxe: %s\n", s);
}

// Função de inicialização
void init_compiler() {
    s = stack_init();
    printf("=== Analisador Sintático do Compilador ===\n");
    printf("Digite uma expressão aritmética (Ctrl+D para sair):\n\n");
}