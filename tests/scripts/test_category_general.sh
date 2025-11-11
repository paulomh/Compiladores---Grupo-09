#!/bin/bash

# Script de Testes por Categoria: GERAIS - Compilador Grupo 09
# Testa funcionalidades básicas: atribuições, comentários, expressões, funções, indentação, etc.

echo "=========================================="
echo "  TESTES POR CATEGORIA: GERAIS"
echo "  Funcionalidades Básicas do Compilador"
echo "=========================================="
echo

# Contadores de teste
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Função para testar arquivo
run_test() {
    local file_path="$1"
    local test_name="$2"
    local expected_behavior="$3"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    echo -n "Testando: $(basename "$file_path") -> "
    
    if [ ! -f "$file_path" ]; then
        echo "[FALHA] Arquivo não encontrado"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        return
    fi
    
    local output=$(./compilador "$file_path" 2>&1)
    local exit_code=$?
    
    if [ "$expected_behavior" = "success" ]; then
        if [ $exit_code -eq 0 ] && echo "$output" | grep -q "Análise concluída com sucesso" >/dev/null 2>&1; then
            echo "[OK]"
            PASSED_TESTS=$((PASSED_TESTS + 1))
        else
            echo "[FALHA]"
            FAILED_TESTS=$((FAILED_TESTS + 1))
        fi
    else
        if [ $exit_code -ne 0 ] || echo "$output" | grep -q -E "(Erro|erro|ERROR)" >/dev/null 2>&1; then
            echo "[OK] Erro esperado"
            PASSED_TESTS=$((PASSED_TESTS + 1))
        else
            echo "[FALHA]"
            FAILED_TESTS=$((FAILED_TESTS + 1))
        fi
    fi
}

# Verificar se o compilador existe
if [ ! -f "./compilador" ]; then
    echo "[ERRO] Executável './compilador' não encontrado!"
    echo "Execute 'make' ou 'make clean && make' para compilar o projeto."
    exit 1
fi

echo "Iniciando testes gerais..."
echo

echo "--- Funcionalidades Básicas ---"
run_test "tests/files/assign_basic.py" "Atribuições" "success"
run_test "tests/files/comment_basic.py" "Comentários" "success"
run_test "tests/files/expr_basic.py" "Expressões" "success"
run_test "tests/files/func_basic.py" "Funções" "success"
run_test "tests/files/indent_deep.py" "Indentação" "success"
run_test "tests/files/mixed_complete.py" "Código misto" "success"

echo
echo "--- Testes Integrados ---"
run_test "tests/files/test_simple.py" "Teste simples" "success"
run_test "tests/files/test_ast_table.py" "AST com tabela" "success"
run_test "tests/files/test_symbol_table.py" "Tabela de símbolos" "success"
run_test "tests/files/test_escopo_tipos.py" "Escopo e tipos" "error"
run_test "tests/files/test_tipos_retorno.py" "Tipos de retorno" "error"

echo
echo "=========================================="
echo "RELATÓRIO FINAL - GERAIS"
echo "=========================================="
echo "Total: $TOTAL_TESTS | Aprovados: $PASSED_TESTS | Falhados: $FAILED_TESTS"

if [ $FAILED_TESTS -eq 0 ]; then
    echo "Resultado: Todos os testes gerais passaram com sucesso."
    exit 0
else
    echo "Resultado: Alguns testes gerais falharam."
    exit 1
fi
