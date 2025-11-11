#!/bin/bash

# Script de Testes por Categoria: AST - Compilador Grupo 09
# Testa especificamente arquivos da categoria AST

echo "=========================================="
echo "  TESTES POR CATEGORIA: AST"
echo "  Validação da Árvore Sintática (AST)"
echo "=========================================="
echo

# Contadores de teste
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Função para testar construção de AST
run_ast_test() {
    local file_path="$1"
    local test_name="$2"
    local expected_pattern="$3"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    echo -n "Testando: $(basename "$file_path") -> "
    
    if [ ! -f "$file_path" ]; then
        echo "[FALHA] Arquivo não encontrado"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        return
    fi
    
    local output=$(./compilador "$file_path" 2>&1)
    local exit_code=$?
    
    if [ $exit_code -ne 0 ]; then
        echo "[FALHA] Erro na compilação"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        return
    fi
    
    if echo "$output" | grep -q "Análise concluída com sucesso" >/dev/null 2>&1; then
        if [ -z "$expected_pattern" ] || echo "$output" | grep -q -E "$expected_pattern" >/dev/null 2>&1; then
            echo "[OK]"
            PASSED_TESTS=$((PASSED_TESTS + 1))
        else
            echo "[FALHA] Padrão não encontrado: $expected_pattern"
            FAILED_TESTS=$((FAILED_TESTS + 1))
        fi
    else
        echo "[FALHA] AST não foi exibida"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
}

# Verificar se o compilador existe
if [ ! -f "./compilador" ]; then
    echo "[ERRO] Executável './compilador' não encontrado!"
    echo "Execute 'make' ou 'make clean && make' para compilar o projeto."
    exit 1
fi

echo "Iniciando testes de AST..."
echo

run_ast_test "tests/files/ast_assignment.py" "Atribuição" "="
run_ast_test "tests/files/ast_binop.py" "Operação binária" "BINOP.*\+"
run_ast_test "tests/files/ast_comparison.py" "Comparação" "BINOP.*'e'"
run_ast_test "tests/files/ast_complex_nested.py" "Expressão complexa" "BINOP"
run_ast_test "tests/files/ast_logical_ops.py" "Operadores lógicos" "BINOP"
run_ast_test "tests/files/ast_parentheses.py" "Parênteses" "BINOP.*\\*"
run_ast_test "tests/files/ast_precedence.py" "Precedência" "BINOP.*\\*"
run_ast_test "tests/files/ast_unary_minus.py" "Unário menos" "UNOP"
run_ast_test "tests/files/ast_unary_not.py" "Unário NOT" "UNOP"
run_ast_test "tests/files/ast_variable.py" "Variável" "ID"

echo
echo "=========================================="
echo "RELATÓRIO FINAL - AST"
echo "=========================================="
echo "Total: $TOTAL_TESTS | Aprovados: $PASSED_TESTS | Falhados: $FAILED_TESTS"

if [ $FAILED_TESTS -eq 0 ]; then
    echo "Resultado: Todos os testes AST passaram com sucesso."
    exit 0
else
    echo "Resultado: Alguns testes AST falharam."
    exit 1
fi
