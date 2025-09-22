%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "parser.tab.h"
int line_num = 1;
%}

%%
[#].*[\n]            { line_num++; /* Ignorar comentarios */ }
('''(.|[\n])*'''|"""(.|[\n])*""")   { for(char* p = yytext; *p; ++p) if(*p=='\n') line_num++; }

"if"            { return IF; }
"else"          { return ELSE; }
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

[-\+]?[0-9]+ { yylval.intValue = atoi(yytext); return INT; }
[-\+]?[0-9]+\.[0-9]+ { yylval.floatValue = atof(yytext); return FLOAT; }
[a-zA-Z_][a-zA-Z0-9_]* { yylval.strValue = strdup(yytext); return IDENTIFIER; }
\"[^\"]*\"|\'[^\']*\' { yylval.strValue = strdup(yytext); return STRING; }

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

"!"             { return DIFFERENT; }
"="             { return ASSIGNMENT; }
"+"             { return PLUS; }
"-"             { return MINUS; }
"*"             { return TIMES; }
"/"             { return DIVIDE; }
"%"             { return MODULE; }
">"             { return GREATER; }
"<"             { return LESS; }
"("             { return LPAREN; }
")"             { return RPAREN; }
":"             { return COLON; }
";"             { return SEMICOLON; }
[ \t]+          { /* Ignorar espaços e tabs */ }
\n              { line_num++; return SEMICOLON; }
. { printf("Erro léxico na linha %d: caractere invalido: %s\n", line_num, yytext); }
%%

int yywrap() { return 1; }