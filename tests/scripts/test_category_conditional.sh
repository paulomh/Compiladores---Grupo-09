#!/bin/bash

# Script de Testes por Categoria: CONDICIONAIS - Compilador Grupo 09
# Testa especificamente arquivos de estruturas condicionais

echo "=========================================="
echo "  TESTES POR CATEGORIA: CONDICIONAIS"
echo "  Validacao de Estruturas Condicionais"
echo "=========================================="
echo

# Contadores de teste
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Funcao para testar arquivo
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

# Verificar se o compilador existe
if [ ! -f "./compilador" ]; then
    echo "[ERRO] Executavel './compilador' nao encontrado!"
    echo "Execute 'make' ou 'make clean && make' para compilar o projeto."
    exit 1
fi

echo "Iniciando testes de condicionais..."
echo

run_test "tests/files/conditional_basic.py" "Condicional basica"
run_test "tests/files/conditional_complex.py" "Condicional complexa"
run_test "tests/files/conditional_nested.py" "Condicional aninhada"

echo
echo "=========================================="
echo "RELATORIO FINAL - CONDICIONAIS"
echo "=========================================="
echo "Total: $TOTAL_TESTS | Aprovados: $PASSED_TESTS | Falhados: $FAILED_TESTS"

if [ $FAILED_TESTS -eq 0 ]; then
    echo "Resultado: Todos os testes de condicionais passaram com sucesso."
    exit 0
else
    echo "Resultado: Alguns testes de condicionais falharam."
    exit 1
fi
