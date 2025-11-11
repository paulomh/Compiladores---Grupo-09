#!/bin/bash

# Script de Testes por Categoria: ERROS - Compilador Grupo 09
# Testa especificamente casos que devem gerar erros

echo "=========================================="
echo "  TESTES POR CATEGORIA: ERROS"
echo "  Validação de Detecção de Erros"
echo "=========================================="
echo

# Contadores de teste
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Função para testar arquivo com erro esperado
run_error_test() {
    local file_path="$1"
    local test_name="$2"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    echo -n "Testando: $(basename "$file_path") -> "
    
    if [ ! -f "$file_path" ]; then
        echo "[FALHA] Arquivo não encontrado"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        return
    fi
    
    local output=$(./compilador "$file_path" 2>&1)
    local exit_code=$?
    
    if [ $exit_code -ne 0 ] || echo "$output" | grep -q -E "(Erro|erro|ERROR|syntax error)" >/dev/null 2>&1; then
        if echo "$output" | grep -q -E "(linha|line)[[:space:]]*[0-9]+" >/dev/null 2>&1; then
            echo "[OK] Erro com indicação de linha"
            PASSED_TESTS=$((PASSED_TESTS + 1))
        else
            echo "[FALHA] Erro sem indicação de linha"
            FAILED_TESTS=$((FAILED_TESTS + 1))
        fi
    else
        echo "[FALHA] Deveria ter erro"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
}

# Verificar se o compilador existe
if [ ! -f "./compilador" ]; then
    echo "[ERRO] Executável './compilador' não encontrado!"
    echo "Execute 'make' ou 'make clean && make' para compilar o projeto."
    exit 1
fi

echo "Iniciando testes de erros..."
echo

run_error_test "tests/files/error_bad_indentation.py" "Indentação incorreta"
run_error_test "tests/files/error_invalid_chars.py" "Caracteres inválidos"
run_error_test "tests/files/error_syntax_error.py" "Erro de sintaxe"
run_error_test "tests/files/error_unbalanced_parens.py" "Parênteses desbalanceados"

echo
echo "=========================================="
echo "RELATÓRIO FINAL - ERROS"
echo "=========================================="
echo "Total: $TOTAL_TESTS | Aprovados: $PASSED_TESTS | Falhados: $FAILED_TESTS"

if [ $FAILED_TESTS -eq 0 ]; then
    echo "Resultado: Todos os testes de erros passaram com sucesso."
    exit 0
else
    echo "Resultado: Alguns testes de erros falharam."
    exit 1
fi
