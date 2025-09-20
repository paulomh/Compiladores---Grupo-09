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
%token DIFFERENT ASSIGNMENT PLUS MINUS TIMES DIVIDE MODULE GREATER LESS LPAREN RPAREN COLON SEMICOLON

// Indentação
%token INDENT DEDENT NEWLINE

%token COMMA

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
  | statement_list { printf("\n[SUCESSO!]"); }
 ;

// Cada statement deve terminar com ponto e vírgula
stmt:
    expr SEMICOLON { print_result($1); }
  | RETDEF expr SEMICOLON {
        printf("Retorno da função: %d\n", $2);
        $$ = $2; // Retorna o valor da expressão
    }
  | error SEMICOLON { yyerrok; }
  ;

statement_list:
    statement
    | statement_list statement
    ;
statement:
    simple_statement NEWLINE
    | compound_statement
    | function_definition
    ;

simple_statement:
    expr { print_result($1); }
    ;

compound_statement:
    if_statement
 ;

// Um "bloco" de código indentado
suite:
    NEWLINE INDENT statement_list DEDENT
    ;

# A nova regra 'if', mais limpa
if_statement:
    IF expr COLON suite
    | IF expr COLON suite ELSE COLON suite
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
  | IDENTIFIER LPAREN argument_list RPAREN {
        printf("Chamada de função: %s\n", $1);
        free($1); // Libera a memória alocada para o IDENTIFIER
        $$ = 0;   // Placeholder para o valor retornado
    }
  ;

argument_list:
    /* vazio */ {
        printf("Sem argumentos\n");
        $$ = 0; // Retorna 0 como valor padrão
    }
  | expr {
        printf("Um argumento\n");
        $$ = 1; // Retorna 1 para indicar um argumento
    }
  | argument_list COMMA expr {
        printf("Mais argumentos\n");
        $$ = $1 + 1; // Incrementa o contador de argumentos
    }
  ;

function_definition:
    DEF IDENTIFIER LPAREN parameter_list RPAREN COLON suite {
        printf("Definição de função: %s com %d parâmetro(s)\n", $2, $4);
        free($2); // Libera a memória alocada para o IDENTIFIER
    }
    ;

parameter_list:
    /* vazio */ {
        printf("Sem parâmetros\n");
        $$ = 0; // Retorna 0 como valor padrão
    }
  | IDENTIFIER {
        printf("Um parâmetro: %s\n", $1);
        free($1); // Libera a memória alocada para o IDENTIFIER
        $$ = 1; // Retorna 1 para indicar um parâmetro
    }
  | parameter_list COMMA IDENTIFIER {
        printf("Mais parâmetros: %s\n", $3);
        free($3); // Libera a memória alocada para o IDENTIFIER
        $$ = $1 + 1; // Incrementa o contador de parâmetros
    }
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

int main() {
    init_compiler();
    yyparse();
    printf("\nTotal de linhas (NEWLINE): %d\n", newline_count); // Exibe o total de "enters"
    return 0;
}