#!/bin/bash

# Script Principal de Testes - Compilador Grupo 09
# Executa todos os tipos de testes disponíveis

echo "=========================================="
echo "  SUITE COMPLETA DE TESTES - GRUPO 09"
echo "=========================================="
echo

# Verificar se o compilador existe
if [ ! -f "./compilador" ]; then
    echo "❌ ERRO: Executável './compilador' não encontrado!"
    echo "Execute 'make' ou 'make clean && make' para compilar o projeto."
    exit 1
fi

echo "🚀 Executando Suite Completa de Testes..."
echo

# Executar testes inline
echo "📝 EXECUTANDO TESTES INLINE (Expressões)..."
echo "============================================"
if [ -f "tests/scripts/testes.sh" ]; then
    ./tests/scripts/testes.sh
    inline_result=$?
else
    echo "❌ Script de testes inline não encontrado!"
    inline_result=1
fi

echo
echo "📁 EXECUTANDO TESTES DE ARQUIVOS (Funcionalidades)..."
echo "===================================================="
if [ -f "tests/scripts/testes_arquivos.sh" ]; then
    ./tests/scripts/testes_arquivos.sh
    files_result=$?
else
    echo "❌ Script de testes de arquivos não encontrado!"
    files_result=1
fi

echo
echo "📚 EXECUTANDO TESTES DA TABELA DE SÍMBOLOS/ESCOPO/TIPOS..."
echo "=========================================================="
if [ -f "tests/scripts/test_symbol_table.sh" ]; then
    ./tests/scripts/test_symbol_table.sh
    symbols_result=$?
else
    echo "❌ Script de testes da tabela de símbolos não encontrado!"
    symbols_result=1
fi

echo
echo "=========================================="
echo "       RELATÓRIO FINAL GERAL"
echo "=========================================="

if [ $inline_result -eq 0 ] && [ $files_result -eq 0 ] && [ $symbols_result -eq 0 ]; then
    echo "🎉 TODOS OS TESTES PASSARAM! 🎉"
    echo "✅ Testes inline: SUCESSO"
    echo "✅ Testes de arquivos: SUCESSO"
    echo "✅ Testes de símbolos/escopo/tipos: SUCESSO"
    echo ""
    echo "O compilador está funcionando perfeitamente!"
    exit 0
else
    echo "⚠️  ALGUNS TESTES FALHARAM!"
    if [ $inline_result -ne 0 ]; then
        echo "❌ Testes inline: FALHOU"
    else
        echo "✅ Testes inline: SUCESSO"
    fi
    
    if [ $files_result -ne 0 ]; then
        echo "❌ Testes de arquivos: FALHOU"
    else
        echo "✅ Testes de arquivos: SUCESSO"
    fi
    if [ $symbols_result -ne 0 ]; then
        echo "❌ Testes de símbolos/escopo/tipos: FALHOU"
    else
        echo "✅ Testes de símbolos/escopo/tipos: SUCESSO"
    fi
    echo ""
    echo "Verifique os relatórios acima para detalhes."
    exit 1
fi
