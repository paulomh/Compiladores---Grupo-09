%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yylex(void);
void yyerror(const char *s);
extern int line_num;
extern char *yytext;
extern int yychar;

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
%token DIFFERENT ASSIGNMENT PLUS MINUS TIMES DIVIDE MODULE GREATER LESS LPAREN RPAREN COLON SEMICOLON

// Declaração de tipos para regras gramaticais
%type <intValue> expr
%type <intValue> stmt

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

// Regras de alto nível: programa composto por múltiplos statements terminados por ';'
program:
    /* vazio */
  | program stmt
  ;

// Cada statement deve terminar com ponto e vírgula
stmt:
    expr SEMICOLON { print_result($1); }
  | error SEMICOLON { yyerrok; }
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
  ;


%%

// Função para tratamento de erros
void yyerror(const char *s) {
    const char *token_text = (yytext && yytext[0]) ? yytext : "EOF";
    int report_line = line_num;
    if (yychar == SEMICOLON && yytext && yytext[0] == '\n') {
        if (report_line > 1) report_line -= 1;
    }
    fprintf(stderr, "Erro de sintaxe na linha %d: %s (perto de '%s')\n", report_line, s, token_text);
}

// Função de inicialização
void init_compiler() {
    printf("=== Analisador Sintático do Compilador ===\n");
    printf("Digite uma expressão aritmética (Ctrl+D para sair):\n\n");
}