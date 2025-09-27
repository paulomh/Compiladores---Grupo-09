%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

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
%type <intValue> expr

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
    /* vazio */
    | statement_list { printf("\n[SUCESSO!]"); }
    ;

statement_list:
    statement
    | statement_list statement
    ;

statement:
    NEWLINE
    | simple_statement NEWLINE
    | compound_statement
    ;

simple_statement:
    expr { print_result($1); }
    | return_statement
    | assignment_statement
    ;

assignment_statement:
    IDENTIFIER ASSIGNMENT expr
    ;

compound_statement:
    if_statement
    | function_definition
    ;

// Um "bloco" de código indentado
suite:
    NEWLINE INDENT statement_list DEDENT
    ;

if_statement:
    IF expr COLON suite
    | IF expr COLON suite ELSE COLON suite
    ;

function_definition:
    DEF IDENTIFIER LPAREN parameter_list RPAREN COLON suite
    ;

parameter_list:
    /* vazio */
    | parameter
    | parameter_list COMMA parameter
    ;

parameter:
    IDENTIFIER
    | IDENTIFIER ASSIGNMENT expr
    ;

return_statement:
    RETDEF
    | RETDEF expr
    ;

function_call:
    IDENTIFIER LPAREN argument_list RPAREN
    ;

argument_list:
    
    | expr
    | argument_list COMMA expr
    ;


// Expressões aritméticas e lógicas
expr:
    expr OR expr      { $$ = $1 || $3; }
  | expr AND expr     { $$ = $1 && $3; }
  | NOT expr          { $$ = !$2; }
  | expr EQUALS expr  { $$ = $1 == $3; }
  | expr DIFFROM expr { $$ = $1 != $3; }
  | expr GREATER expr { $$ = $1 > $3; }
  | expr LESS expr    { $$ = $1 < $3; }
  | expr GTOREQUAL expr { $$ = $1 >= $3; }
  | expr LSOREQUAL expr { $$ = $1 <= $3; }
  | expr PLUS expr    { $$ = $1 + $3; }
  | expr MINUS expr   { $$ = $1 - $3; }
  | expr TIMES expr   { $$ = $1 * $3; }
  | expr DIVIDE expr  { $$ = $3 != 0 ? $1 / $3 : 0; }
  | expr MODULE expr  { $$ = $3 != 0 ? $1 % $3 : 0; }
  | expr INTDIVIDE expr { $$ = $3 != 0 ? $1 / $3 : 0; }
  | expr EXPONENTIAL expr { $$ = 1; for(int i = 0; i < $3; i++) $$ *= $1; }
  | LPAREN expr RPAREN { $$ = $2; }
  | INT               { $$ = $1; }
  | FLOAT             { $$ = (int)$1; }
  | IDENTIFIER        { $$ = 0; } // Placeholder para variáveis
  | MINUS expr %prec UMINUS { $$ = -$2; }
  | function_call
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