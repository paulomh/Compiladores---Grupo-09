%x INDENT_STATE
%option yylineno
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "src/ast.h"
#include "src/tabela.h"
#include "parser.tab.h"
#define YY_USER_ACTION yylloc.first_line = yylloc.last_line = yylineno;
#define MAX 100
#undef YY_DECL
#define YY_DECL int lex_engine(void)

static char* copyString(const char* s) {
    char* str = malloc(strlen(s) + 1);
    strcpy(str, s);
    return str;
}

int lex_engine(void);
void yyerror(const char *s);
int yylex(void);

/*
 * regra <<EOF>> faz `return yylex()` que pode
 * causar recursão infinita.
 * 
 * <<EOF>> {
 *     if (eof_flag) {
 *         return 0;
 *     }
 * 
 *     eof_flag = 1;
 *     while (stack_peek(s) > 0) {
 *         stack_pop(s);
 *         dedent_line++;
 *     }
 * 
 *     // MUDANÇA CRÍTICA: Não chamar yylex() recursivamente
 *     if (dedent_line > 0) {
 *         // Deixa yylex() processar os DEDENTs na próxima chamada
 *         printf("[LEXER] -> EOF com %d DEDENTs pendentes\n", dedent_line);
 *         return 0; // Retorna 0 para indicar EOF, mas yylex() processará DEDENTs
 *     }
 * 
 *     printf("[LEXER] -> END_OF_FILE\n");
 *     return END_OF_FILE;
 * }
 */

typedef struct stack 
{
    int indent[MAX];
    int indent_top;
} stack;

stack *stack_init()
{
    stack *s = malloc(sizeof(stack));
    s->indent[0] = 0;
    s->indent_top = 0;

    return s;
}

int is_empty(stack *s)
{
    return s->indent_top == 0;
}

int is_full(stack *s)
{
    return s->indent_top == MAX - 1;
}

void stack_push(stack *s, int level)
{
    if(is_full(s))
        return;
    s->indent[++(s->indent_top)] = level;
}

int stack_pop(stack *s)
{
    if(is_empty(s))
        return -1;
    return s->indent[(s->indent_top)--];
}

int stack_peek(stack *s)
{
    return s->indent[s->indent_top];
}

stack *s;
int dedent_line = 0;
int eof_flag = 0, endF = 0, eof_newline_injected = 0;
int newline_count = 0; // Contador global de "enters"

int yylex(void) {
    if (dedent_line > 0) {
        yylineno = dedent_line; // Apenas para depuração, pode ser removido
        dedent_line--;
        printf("[LEXER] -> DEDENT\n");
        return DEDENT;
    }
    
    return lex_engine(); 
}

%}

%%
#[^\n]*           { printf("COMENTARIO SIMPLES\n"); /* Ignorar comentarios */ }
\"\"\"([^"]|\n)*\"\"\"   { printf("COMENTARIO COMPOSTO\n");}
'''([^']|\n)*'''   { printf("COMENTARIO COMPOSTO\n");}

[-\+]?[0-9]+ {  yylval.intValue = atoi(yytext); printf("[LEXER] -> INT\n"); return INT; }
[-\+]?[0-9]+\.[0-9]+ { yylval.floatValue = atof(yytext); return FLOAT; }
\"[^\"]*\"|\'[^\']*\' { yylval.strValue = copyString(yytext); return STRING; }

[a-zA-Z_][a-zA-Z0-9_]* { 
    if (strcmp(yytext, "if") == 0) { printf("[LEXER] Linha %d -> IF\n", yylineno); return IF; }
    else if (strcmp(yytext, "else") == 0) { printf("[LEXER] Linha %d -> ELSE\n", yylineno); return ELSE; }
    else if (strcmp(yytext, "while") == 0) return WHILE;
    else if (strcmp(yytext, "for") == 0) return FOR;
    else if (strcmp(yytext, "and") == 0) return AND;
    else if (strcmp(yytext, "or") == 0) return OR;
    else if (strcmp(yytext, "not") == 0) return NOT;
    else if (strcmp(yytext, "is") == 0) return IS;
    else if (strcmp(yytext, "in") == 0) return IN;
    else if (strcmp(yytext, "pass") == 0) return PASS;
    else if (strcmp(yytext, "def") == 0) return DEF;
    else if (strcmp(yytext, "return") == 0) return RETDEF;
    else {
        yylval.strValue = copyString(yytext); 
        printf("[LEXER] -> IDENTIFIER: %s\n", yytext);
        return IDENTIFIER;
    }
}

"=="            { return EQUALS; }
"!="            { return DIFFROM; }
">="            { return GTOREQUAL; }
"<="            { return LSOREQUAL; }
"+="            { return INCREMENT; }
"-="            { return DECREMENT; }
"*="            { return INCTIMES; }
"/="            { return DIVBY; }
"%="            { return MODBY; }
"**"            { return EXPONENTIAL; }
"//"            { return INTDIVIDE; }

"!"             {  printf("[LEXER] -> DIFFERENT\n");  return DIFFERENT; }
"="             {  printf("[LEXER] -> ASSIGNMENT\n"); return ASSIGNMENT; }
"+"             {  printf("[LEXER] -> PLUS\n");  return PLUS; }
"-"             {  printf("[LEXER] -> MINUS\n");  return MINUS; }
"*"             {  printf("[LEXER] -> TIMES\n");  return TIMES; }
"/"             {  printf("[LEXER] -> DIVIDE\n");  return DIVIDE; }
"%"             {  printf("[LEXER] -> MODULE\n");  return MODULE; }
">"             {  printf("[LEXER] -> GREATER\n");  return GREATER; }
"<"             {  printf("[LEXER] -> LESS\n");  return LESS; }
"("             {  printf("[LEXER] -> LPAREN\n");  return LPAREN; }
")"             {  printf("[LEXER] -> RPAREN\n");  return RPAREN; }
":"             {  printf("[LEXER] -> COLON\n");  return COLON; }
","             {  printf("[LEXER] -> COMMA\n");  return COMMA; }

[ \t\r]+        { /* Ignorar espaços em branco */ }

\n { 
    newline_count++; // Incrementa o contador de "enters"
    BEGIN(INDENT_STATE); 
    printf("[LEXER] -> NEWLINE (linha em branco, Total: %d)\n", newline_count); 
    return NEWLINE; 
}

<INDENT_STATE>[ \t]+/[^\n] {
    int actual_level = strlen(yytext);
    int previous_level = stack_peek(s);
    printf("Indent level check: actual=%d, previous=%d\n", actual_level, previous_level);
    BEGIN(INITIAL);

    if (actual_level > previous_level) {
        stack_push(s, actual_level);
        printf("[LEXER] -> INDENT\n");
        return INDENT;
    } 
    
    if (actual_level < previous_level) {
        while (stack_peek(s) > actual_level) {
            stack_pop(s);
            dedent_line++;
        }
        if (stack_peek(s) != actual_level) {
            yyerror("IndentationError: unindent does not match any outer indentation level");
            exit(1);
        }
        return yylex(); 
    }
    return yylex();
}

<INDENT_STATE>[ \t]*\n {
    newline_count++;
    printf("[LEXER] -> NEWLINE (linha em branco, Total: %d)\n", newline_count);
    return NEWLINE;
}

<INDENT_STATE>. {
    int actual_level = 0;
    int previous_level = stack_peek(s);
     printf("Indent level check (no spaces): actual=%d, previous=%d\n", actual_level, previous_level);
    
    yyless(0);
    BEGIN(INITIAL);

    if (previous_level > 0) {
         while (stack_peek(s) > 0) {
            stack_pop(s);
            dedent_line++;
        }
    }
    return yylex();
}

<<EOF>> {
    if (eof_flag) {
        return 0;
    }

    if (yytext[0] != '\n' && !eof_newline_injected) {
        eof_newline_injected = 1;
        printf("[LEXER] -> Inserindo NEWLINE antes do EOF\n");
        return NEWLINE;
    }

    if (stack_peek(s) > 0) {
        stack_pop(s);
        printf("[LEXER] -> DEDENT (EOF)\n");
        return DEDENT;
    }

    printf("[LEXER] -> END_OF_FILE\n");
    eof_flag = 1;
    return END_OF_FILE;
}

. { printf("Caractere invalido: %s\n", yytext); }
%%

int yywrap() { return 1; }