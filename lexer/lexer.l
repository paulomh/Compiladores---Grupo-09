%x INDENT_STATE
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "parser.tab.h"
#define MAX 100
#undef YY_DECL
#define YY_DECL int lex_engine(void)

int lex_engine(void);
void yyerror(const char *s);
int yylex(void);

// Variável para rastrear o número da linha
int line_num = 1;


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
int eof_flag = 0, endF = 0;
int newline_count = 0; // Contador global de "enters"

// Inicializar a stack global
void init_lexer() {
    s = stack_init();
}

int yylex(void) {
    if (dedent_line > 0) {
        dedent_line--;
        printf("[LEXER] -> DEDENT\n");
        return DEDENT;
    }
    
    return lex_engine(); 
}

%}

%%
#[^\n]*           { line_num++; printf("COMENTARIO SIMPLES\n"); /* Ignorar comentarios */ }
\"\"\"([^"]|\n)*\"\"\"   { for(char* p = yytext; *p; ++p) if(*p=='\n') line_num++; printf("COMENTARIO COMPOSTO\n");}
'''([^']|\n)*'''   { for(char* p = yytext; *p; ++p) if(*p=='\n') line_num++; printf("COMENTARIO COMPOSTO\n");}

[-\+]?[0-9]+ {  yylval.intValue = atoi(yytext); printf("[LEXER] -> INT\n"); return INT; }
[-\+]?[0-9]+\.[0-9]+ { yylval.floatValue = atof(yytext); return FLOAT; }
\"[^\"]*\"|\'[^\']*\' { yylval.strValue = strdup(yytext); return STRING; }

"if"            {  printf("[LEXER] -> IF\n "); return IF; }
"else"          {  printf("[LEXER] -> ELSE\n "); return ELSE; }
"while"         { return WHILE; }
"for"           { return FOR; }
"and"           { return AND; }
"or"            { return OR; }
"not"           { return NOT; }
"is"            { return IS; }
"in"            { return IN; }
"pass"          { return PASS; }
"def"           { return DEF; }
"return"        { return RETDEF; }

[a-zA-Z_][a-zA-Z0-9_]* { yylval.strValue = strdup(yytext); return IDENTIFIER; }

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
    line_num++; // Incrementa o contador de linhas
    newline_count++; // Incrementa o contador de "enters"
    BEGIN(INDENT_STATE); 
    printf("[LEXER] -> NEWLINE (linha %d, Total: %d)\n", line_num, newline_count); 
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
            printf("Erro de indentação na linha %d: IndentationError: unindent does not match any outer indentation level\n", line_num);
            yyerror("IndentationError: unindent does not match any outer indentation level");
            exit(1);
        }
        return yylex(); 
    }
    return yylex();
}

<INDENT_STATE>[ \t]*\n {
    line_num++;
    newline_count++;
    printf("[LEXER] -> NEWLINE (linha %d, Total: %d)\n", line_num, newline_count);
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

    eof_flag = 1;
    while (stack_peek(s) > 0) {
        stack_pop(s);
        dedent_line++;
    }

    return yylex();
}


. { printf("Erro léxico na linha %d: caractere invalido: %s\n", line_num, yytext); }
%%

int yywrap() { return 1; }

int main(int argc, char *argv[]) {
    init_lexer();
    printf("=== Analisador Léxico do Compilador ===\n");
    
    if (argc > 1) {
        // Ler de arquivo
        FILE *file = fopen(argv[1], "r");
        if (file) {
            yyrestart(file);
            printf("Analisando arquivo: %s\n\n", argv[1]);
            yylex();
            fclose(file);
        } else {
            printf("Erro: Não foi possível abrir o arquivo %s\n", argv[1]);
            return 1;
        }
    } else {
        // Ler da entrada padrão
        printf("Digite código Python (Ctrl+D para sair):\n\n");
        yylex();
    }
    return 0;
}