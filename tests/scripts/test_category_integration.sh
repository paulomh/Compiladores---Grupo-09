#!/bin/bash

# Script de Testes por Categoria: INTEGRAÇÃO - Compilador Grupo 09
# Testa integração de AST com Tabela de Símbolos

echo "=========================================="
echo "  TESTES POR CATEGORIA: INTEGRAÇÃO"
echo "  AST com Tabela de Símbolos"
echo "=========================================="
echo

# Contadores de teste
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Função para testar sucesso
run_test() {
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
    
    if [ $exit_code -eq 0 ] && echo "$output" | grep -q "Análise concluída com sucesso" >/dev/null 2>&1; then
        echo "[OK]"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        echo "[FALHA]"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
}

# Função para testar erro
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
    
    if [ $exit_code -ne 0 ] || echo "$output" | grep -q -E "(não está definido|undefined|Erro)" >/dev/null 2>&1; then
        echo "[OK] Erro esperado"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        echo "[FALHA]"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
}

# Verificar se o compilador existe
if [ ! -f "./compilador" ]; then
    echo "[ERRO] Executável './compilador' não encontrado!"
    echo "Execute 'make' ou 'make clean && make' para compilar o projeto."
    exit 1
fi

echo "Iniciando testes de integração..."
echo

run_test "tests/files/integration_var_in_expr.py" "Variável em expressão"
run_error_test "tests/files/integration_undefined_in_expr.py" "Variável indefinida"
run_test "tests/files/integration_compatible_types.py" "Tipos compatíveis"
run_test "tests/files/integration_type_mismatch.py" "Tipos incompatíveis"
run_test "tests/files/integration_function_call_valid.py" "Chamada de função válida"
run_test "tests/files/integration_function_call_invalid_args.py" "Argumentos incorretos"
run_test "tests/files/integration_implicit_cast.py" "Implicit cast"
run_test "tests/files/integration_shadowing.py" "Variable shadowing"
run_test "tests/files/integration_type_propagation.py" "Type propagation"
run_test "tests/files/integration_conditional_scope.py" "Variável em condicional"

echo
echo "=========================================="
echo "RELATÓRIO FINAL - INTEGRAÇÃO"
echo "=========================================="
echo "Total: $TOTAL_TESTS | Aprovados: $PASSED_TESTS | Falhados: $FAILED_TESTS"

if [ $FAILED_TESTS -eq 0 ]; then
    echo "Resultado: Todos os testes de integração passaram com sucesso."
    exit 0
else
    echo "Resultado: Alguns testes de integração falharam."
    exit 1
fi
