%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "src/ast.h"
#include "src/tabela.h"

extern int yylineno;

typedef struct stack {
    int indent[100];
    int indent_top;
} stack;

extern stack *s;

extern stack *stack_init();

int yylex(void);
void yyerror(const char *s);

// Variáveis do lexer para rastreamento de erros
extern char *yytext;
extern int yychar;

// Função para imprimir resultado da expressão
void print_result(int value) {
    printf("Resultado: %d\n", value);
}
%}

// Habilita o rastreamento de localização (define yylloc)
%locations

%union {
    int intValue;
    float floatValue;
    char* strValue;
    NoAST* no;
    Tipo tipo;
}

// Com valor semantico 
%token <intValue> INT
%token <floatValue> FLOAT
%token <strValue> IDENTIFIER

// Tokens com valor semântico
%token <strValue> STRING

// Palavras reservadas sem valor semântico 
%token IF ELSE WHILE FOR AND OR NOT IS IN PASS DEF RETDEF

// Operadores duplos sem valor semântico
%token EQUALS DIFFROM GTOREQUAL LSOREQUAL INCREMENT DECREMENT INCTIMES DIVBY MODBY EXPONENTIAL INTDIVIDE

// Operadores simples sem valor semântico 
%token DIFFERENT ASSIGNMENT PLUS MINUS TIMES DIVIDE MODULE GREATER LESS LPAREN RPAREN COLON SEMICOLON COMMA

// Indentação
%token INDENT DEDENT NEWLINE
%token END_OF_FILE

// Tipos das regras gramaticais
%type <no> program
%type <no> statement_list
%type <no> statement
%type <no> if_statement
%type <no> suite
%type <no> function_definition
%type <no> parameter_list
%type <no> parameter
%type <no> expr
%type <no> simple_statement
%type <no> assignment_statement
%type <no> return_statement
%type <no> function_call
%type <no> argument_list
%type <no> compound_statement

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
        imprimirAST_formatada($$);  // Imprimir a árvore formatada para debug
    }
    | statement_list END_OF_FILE {
        $$ = $1;
        printf("\n[SUCESSO!] AST construída com sucesso (com EOF)\n");
        imprimirAST_formatada($$);
    }
    ;

statement_list:
    statement           { $$ = $1; }
    | statement_list statement {
        $$ = novoNoOp(';', $1, $2);  // Usa ; como operador de sequência
    }
    ;

statement:
    NEWLINE { $$ = NULL; }
    | simple_statement NEWLINE { $$ = $1; }
    | compound_statement { $$ = $1; }
    ;

simple_statement:
    expr               { $$ = $1; }
    | return_statement { $$ = $1; }
    | assignment_statement { $$ = $1; }
    ;

assignment_statement:
    IDENTIFIER ASSIGNMENT expr {
        Simbolo *s = buscarSimbolo($1);
        if (s == NULL) {
            inserirSimbolo($1, $3->tipo); // Usa o tipo da expressão
            $$ = novoNoAtrib($1, $3);
        } else {
            if (s->tipo != $3->tipo && s->tipo != T_ERRO && $3->tipo != T_ERRO) {
                printf("Erro na linha %d: Tipos incompatíveis na atribuição. Variável '%s' é do tipo %s mas recebeu valor do tipo %s\n", 
                       yylineno, $1, getTipoString(s->tipo), getTipoString($3->tipo));
                $$ = novoNoAtrib($1, $3);
                $$->tipo = T_ERRO;
            } else {
                $$ = novoNoAtrib($1, $3);
            }
        }
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
        inserirFuncao($2, T_VOID);  // Por padrão, funções retornam void
        NoAST* func_name = novoNoId($2, T_FUNC);
        NoAST* func_params = $4;
        NoAST* func_body = $7;
        
        // Verificar tipo de retorno na função
        Tipo tipoRetorno = verificarTipoRetorno(func_body);
        if (tipoRetorno != T_VOID) {
            Simbolo *s = buscarSimbolo($2);
            if (s) {
                s->info.funcao.tipoRetorno = tipoRetorno;
            }
        }
        
        $$ = novoNoOp('F', novoNoOp('P', func_name, func_params), func_body);
        finalizarEscopo(); // Fecha o escopo da função
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
        adicionarParametro($<strValue>-1, $1, T_INT); // Adiciona o parâmetro à função atual
    }
    | IDENTIFIER ASSIGNMENT expr {
        $$ = novoNoOp('=', novoNoId($1, T_INT), $3);
        adicionarParametro($<strValue>-3, $1, T_INT); // Adiciona o parâmetro com valor padrão
    }
    ;

return_statement:
    RETDEF            { $$ = novoNoOp('R', NULL, NULL); } // R para return vazio
    | RETDEF expr     { $$ = novoNoOp('R', $2, NULL); }   // R para return com expressão
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
    expr OR expr        { $$ = novoNoOp('|', $1, $3); }  // | para OR
  | expr AND expr       { $$ = novoNoOp('&', $1, $3); }  // & para AND
  | NOT expr            { $$ = novoNoOp('!', $2, NULL); }
  | expr EQUALS expr    { $$ = novoNoOp('e', $1, $3); }  // e para ==
  | expr DIFFROM expr   { $$ = novoNoOp('d', $1, $3); }  // d para !=
  | expr GREATER expr   { $$ = novoNoOp('>', $1, $3); }
  | expr LESS expr      { $$ = novoNoOp('<', $1, $3); }
  | expr GTOREQUAL expr { $$ = novoNoOp('g', $1, $3); }  // g para >=
  | expr LSOREQUAL expr { $$ = novoNoOp('l', $1, $3); }  // l para <=
  | expr PLUS expr      { 
        // Verificar compatibilidade de tipos
        if ($1->tipo != $3->tipo) {
            yyerror("Tipos incompatíveis na operação");
        }
        $$ = novoNoOp('+', $1, $3);
    }
  | expr MINUS expr     { $$ = novoNoOp('-', $1, $3); }
  | expr TIMES expr     { $$ = novoNoOp('*', $1, $3); }
  | expr DIVIDE expr    { $$ = novoNoOp('/', $1, $3); }
  | expr MODULE expr    { $$ = novoNoOp('%', $1, $3); }
  | expr EXPONENTIAL expr{ $$ = novoNoOp('^', $1, $3); }
  | LPAREN expr RPAREN  { $$ = $2; }
  | INT                 { $$ = novoNoNum($1); }
  | FLOAT               { $$ = novoNoNum((int)$1); }  // Temporário até implementar float
  | IDENTIFIER          { 
        Simbolo *s = buscarSimbolo($1);
        if (s == NULL) {
            yyerror("Variável não declarada");
        }
        $$ = novoNoId($1, s ? s->tipo : T_ERRO);
    }
  | MINUS expr %prec UMINUS { $$ = novoNoOp('-', novoNoNum(0), $2); }
  | function_call       { $$ = $1; }
  ;

%%

// Função para tratamento de erros
void yyerror(const char *s) {
    const char *token_text = (yytext && yytext[0]) ? yytext : "EOF";
    int report_line = yylineno;
    
    // Ajuste para newlines
    if (yychar == NEWLINE && yytext && yytext[0] == '\n') {
        if (report_line > 1) report_line -= 1;
    }
    
    fprintf(stderr, "Erro de sintaxe na linha %d: %s (perto de '%s')\n", report_line, s, token_text);
}

// Função de inicialização
void init_compiler() {
    s = stack_init();
    printf("=== Analisador Sintático do Compilador ===\n");
    printf("Digite uma expressão aritmética (Ctrl+D para sair):\n\n");
}