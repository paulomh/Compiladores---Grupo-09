#!/bin/bash

# Script Principal de Testes por Categoria - Compilador Grupo 09
# Executa todos os testes organizados por categoria

echo "=========================================="
echo "  TESTES POR CATEGORIA - GRUPO 09"
echo "=========================================="
echo

if [ ! -f "./compilador" ]; then
    echo "[ERRO] Executável './compilador' não encontrado!"
    echo "Execute 'make' ou 'make clean && make' para compilar o projeto."
    exit 1
fi

echo "Iniciando execução de testes por categoria..."
echo

echo "CATEGORIA 1: TESTES DE AST"
echo "===================================================="
if [ -f "tests/scripts/test_category_ast.sh" ]; then
    bash tests/scripts/test_category_ast.sh
    ast_result=$?
else
    echo "[ERRO] Script de AST não encontrado!"
    ast_result=1
fi

echo
echo "CATEGORIA 2: TESTES DE CONDICIONAIS"
echo "===================================================="
if [ -f "tests/scripts/test_category_conditional.sh" ]; then
    bash tests/scripts/test_category_conditional.sh
    conditional_result=$?
else
    echo "[ERRO] Script de condicionais não encontrado!"
    conditional_result=1
fi

echo
echo "CATEGORIA 3: TESTES DE ERROS"
echo "===================================================="
if [ -f "tests/scripts/test_category_error.sh" ]; then
    bash tests/scripts/test_category_error.sh
    error_result=$?
else
    echo "[ERRO] Script de erros não encontrado!"
    error_result=1
fi

echo
echo "CATEGORIA 4: TESTES GERAIS"
echo "===================================================="
if [ -f "tests/scripts/test_category_general.sh" ]; then
    bash tests/scripts/test_category_general.sh
    general_result=$?
else
    echo "[ERRO] Script geral não encontrado!"
    general_result=1
fi

echo
echo "CATEGORIA 5: TESTES DE SÍMBOLOS"
echo "===================================================="
if [ -f "tests/scripts/test_category_symbol.sh" ]; then
    bash tests/scripts/test_category_symbol.sh
    symbols_result=$?
else
    echo "[ERRO] Script de símbolos não encontrado!"
    symbols_result=1
fi

echo
echo "CATEGORIA 6: TESTES DE INTEGRAÇÃO"
echo "===================================================="
if [ -f "tests/scripts/test_category_integration.sh" ]; then
    bash tests/scripts/test_category_integration.sh
    integration_result=$?
else
    echo "[ERRO] Script de integração não encontrado!"
    integration_result=1
fi

echo
echo "=========================================="
echo "RELATÓRIO FINAL POR CATEGORIA"
echo "=========================================="

if [ $ast_result -eq 0 ]; then
    echo "[OK] AST: SUCESSO"
else
    echo "[FALHA] AST: FALHOU"
fi

if [ $conditional_result -eq 0 ]; then
    echo "[OK] CONDICIONAIS: SUCESSO"
else
    echo "[FALHA] CONDICIONAIS: FALHOU"
fi

if [ $error_result -eq 0 ]; then
    echo "[OK] ERROS: SUCESSO"
else
    echo "[FALHA] ERROS: FALHOU"
fi

if [ $general_result -eq 0 ]; then
    echo "[OK] GERAIS: SUCESSO"
else
    echo "[FALHA] GERAIS: FALHOU"
fi

if [ $symbols_result -eq 0 ]; then
    echo "[OK] SÍMBOLOS: SUCESSO"
else
    echo "[FALHA] SÍMBOLOS: FALHOU"
fi

if [ $integration_result -eq 0 ]; then
    echo "[OK] INTEGRAÇÃO: SUCESSO"
else
    echo "[FALHA] INTEGRAÇÃO: FALHOU"
fi

echo "=========================================="

if [ $ast_result -eq 0 ] && [ $conditional_result -eq 0 ] && [ $error_result -eq 0 ] && [ $general_result -eq 0 ] && [ $symbols_result -eq 0 ] && [ $integration_result -eq 0 ]; then
    echo "Resultado: Todos os testes passaram com sucesso."
    exit 0
else
    echo "Resultado: Alguns testes falharam."
    exit 1
fi
