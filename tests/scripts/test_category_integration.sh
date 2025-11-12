#!/bin/bash

# Script de Testes por Categoria: INTEGRACAO - Compilador Grupo 09
# Testa integracao de AST com Tabela de Simbolos

echo "=========================================="
echo "  TESTES POR CATEGORIA: INTEGRACAO"
echo "  AST com Tabela de Simbolos"
echo "=========================================="
echo

# Contadores de teste
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Funcao para testar sucesso
run_test() {
    local file_path="$1"
    local test_name="$2"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    echo -n "Testando: $(basename "$file_path") -> "
    
    if [ ! -f "$file_path" ]; then
        echo "[FALHA] Arquivo nao encontrado"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        return
    fi
    
    local output=$(./compilador "$file_path" 2>&1)
    local exit_code=$?
    
    if [ $exit_code -eq 0 ] && echo "$output" | grep -q "Analise concluida com sucesso" >/dev/null 2>&1; then
        echo "[OK]"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        echo "[FALHA]"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
}

# Funcao para testar erro
run_error_test() {
    local file_path="$1"
    local test_name="$2"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    echo -n "Testando: $(basename "$file_path") -> "
    
    if [ ! -f "$file_path" ]; then
        echo "[FALHA] Arquivo nao encontrado"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        return
    fi
    
    local output=$(./compilador "$file_path" 2>&1)
    local exit_code=$?
    
    if [ $exit_code -ne 0 ] || echo "$output" | grep -q -E "(nao esta definido|undefined|Erro)" >/dev/null 2>&1; then
        echo "[OK] Erro esperado"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        echo "[FALHA]"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
}

# Verificar se o compilador existe
if [ ! -f "./compilador" ]; then
    echo "[ERRO] Executavel './compilador' nao encontrado!"
    echo "Execute 'make' ou 'make clean && make' para compilar o projeto."
    exit 1
fi

echo "Iniciando testes de integracao..."
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
run_test "tests/files/integration_conditional_scope.py" "Variavel em condicional"

echo
echo "=========================================="
echo "RELATORIO FINAL - INTEGRACAO"
echo "=========================================="
echo "Total: $TOTAL_TESTS | Aprovados: $PASSED_TESTS | Falhados: $FAILED_TESTS"

if [ $FAILED_TESTS -eq 0 ]; then
    echo "Resultado: Todos os testes de integracao passaram com sucesso."
    exit 0
else
    echo "Resultado: Alguns testes de integracao falharam."
    exit 1
fi
