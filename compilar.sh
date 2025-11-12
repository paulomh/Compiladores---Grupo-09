#!/bin/bash

echo "Compilando Compilador - Grupo 09"
echo "===================================="

# Limpar
echo "Limpando arquivos anteriores..."
rm -f *.o src/*.o compilador

# Compilar na ordem correta
echo "1. Gerando lexer..."
flex lexer/lexer.l

echo "2. Gerando parser..."
bison -d -v -o parser.tab.c parser/parser.y

echo "3. Compilando objetos..."
gcc -Wall -Wextra -std=c99 -c lex.yy.c -o lex.yy.o
gcc -Wall -Wextra -std=c99 -c parser.tab.c -o parser.tab.o
gcc -Wall -Wextra -std=c99 -c src/main.c -o src/main.o
gcc -Wall -Wextra -std=c99 -c src/ast.c -o src/ast.o
gcc -Wall -Wextra -std=c99 -c src/tabela.c -o src/tabela.o

echo "4. Linkando executável..."
gcc -Wall -Wextra -std=c99 -o compilador lex.yy.o parser.tab.o src/main.o src/ast.o src/tabela.o -lfl

if [ -f "compilador" ]; then
    echo "Compilacao bem-sucedida!"
else
    echo "Erro na compilacao"
    exit 1
fi
