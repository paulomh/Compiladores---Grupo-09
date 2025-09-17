#!/bin/bash

# Script de Testes - Compilador Grupo 09
# Executa todos os testes do analisador de expressões aritméticas

echo "=========================================="
echo "    TESTES DO COMPILADOR - GRUPO 09"
echo "    Analisador de Expressões Aritméticas"
echo "=========================================="
echo

# Compilar o projeto
echo "1. Compilando o projeto..."
./compilar.sh
if [ $? -ne 0 ]; then
    echo "ERRO: Falha na compilação"
    exit 1
fi
echo "Compilação concluída com sucesso"
echo

# Executar testes individuais
echo "2. Executando testes individuais..."
echo

echo "--- Teste 1: Operações Básicas ---"
echo "3 + 4" | ./compilador
echo "7 - 2" | ./compilador
echo "5 * 6" | ./compilador
echo "8 / 2" | ./compilador
echo

echo "--- Teste 2: Precedência de Operadores ---"
echo "2 + 3 * 4" | ./compilador
echo "(2 + 3) * 4" | ./compilador
echo "10 - 2 * 3" | ./compilador
echo "(10 - 2) * 3" | ./compilador
echo

echo "--- Teste 3: Números Negativos ---"
echo "-5" | ./compilador
echo "-3 + 7" | ./compilador
echo "5 + (-3)" | ./compilador
echo "(-2) * 3" | ./compilador
echo

echo "--- Teste 4: Parênteses Complexos ---"
echo "((2 + 3) * 4) - 1" | ./compilador
echo "2 * (3 + (4 - 1))" | ./compilador
echo "(10 / 2) + (3 * 2)" | ./compilador
echo

echo "--- Teste 5: Divisão ---"
echo "12 / 3" | ./compilador
echo "15 / 4" | ./compilador
echo "0 / 5" | ./compilador
echo "5 / 0" | ./compilador
echo

echo "--- Teste 6: Expressões Longas ---"
echo "1 + 2 + 3 + 4" | ./compilador
echo "2 * 3 * 4" | ./compilador
echo "10 - 2 - 3 - 1" | ./compilador
echo "20 / 2 / 2" | ./compilador
echo

echo "--- Teste 7: Casos Especiais ---"
echo "0" | ./compilador
echo "1" | ./compilador
echo "-1" | ./compilador
echo "(5)" | ./compilador
echo "((10))" | ./compilador
echo

echo "--- Teste 8: Expressões com Espaços ---"
echo "  3   +   4  " | ./compilador
echo "( 2 + 3 ) * 4" | ./compilador
echo "  10  /  2  " | ./compilador
echo

echo "=========================================="
echo "    TODOS OS TESTES CONCLUÍDOS"
echo "=========================================="
