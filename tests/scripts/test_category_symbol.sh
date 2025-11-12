#!/bin/bash

# Script de Testes por Categoria: SIMBOLOS - Compilador Grupo 09
# Testa gerenciamento de simbolos, tipos e escopo

echo "=========================================="
echo "  TESTES POR CATEGORIA: SIMBOLOS"
echo "  Tabela de Simbolos, Tipos e Escopo"
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
    
    if [ $exit_code -ne 0 ] || echo "$output" | grep -q -E "(nao esta definido|undefined)" >/dev/null 2>&1; then
        echo "[OK] Erro detectado"
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

echo "Iniciando testes de simbolos..."
echo

run_test "tests/files/symbol_simple_insert.py" "Insercao simples"
run_test "tests/files/symbol_multiple_vars.py" "Multiplas variaveis"
run_test "tests/files/symbol_different_types.py" "Tipos diferentes"
run_test "tests/files/symbol_redeclaration.py" "Redeclaracao"
run_test "tests/files/symbol_function_def.py" "Definicao de funcao"
run_test "tests/files/symbol_scope.py" "Escopo"
run_test "tests/files/symbol_function_params.py" "Parametros de funcao"
run_test "tests/files/symbol_assignment_with_vars.py" "Atribuicao com variaveis"
run_test "tests/files/symbol_nested_functions.py" "Funcoes aninhadas"
run_error_test "tests/files/symbol_undefined_var.py" "Variavel indefinida"

echo
echo "=========================================="
echo "RELATORIO FINAL - SIMBOLOS"
echo "=========================================="
echo "Total: $TOTAL_TESTS | Aprovados: $PASSED_TESTS | Falhados: $FAILED_TESTS"

if [ $FAILED_TESTS -eq 0 ]; then
    echo "Resultado: Todos os testes de simbolos passaram com sucesso."
    exit 0
else
    echo "Resultado: Alguns testes de simbolos falharam."
    exit 1
fi
