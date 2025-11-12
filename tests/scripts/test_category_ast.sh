#!/bin/bash

# Script de Testes por Categoria: AST - Compilador Grupo 09
# Testa especificamente arquivos da categoria AST

echo "=========================================="
echo "  TESTES POR CATEGORIA: AST"
echo "  Validacao da Arvore Sintatica (AST)"
echo "=========================================="
echo

# Contadores de teste
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Funcao para testar construcao de AST
run_ast_test() {
    local file_path="$1"
    local test_name="$2"
    local expected_pattern="$3"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    echo -n "Testando: $(basename "$file_path") -> "
    
    if [ ! -f "$file_path" ]; then
        echo "[FALHA] Arquivo nao encontrado"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        return
    fi
    
    local output=$(./compilador "$file_path" 2>&1)
    local exit_code=$?
    
    if [ $exit_code -ne 0 ]; then
        echo "[FALHA] Erro na compilacao"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        return
    fi

    if echo "$output" | grep -q "Analise concluida com sucesso" >/dev/null 2>&1; then
        if [ -z "$expected_pattern" ] || echo "$output" | grep -q -E "$expected_pattern" >/dev/null 2>&1; then
            echo "[OK]"
            PASSED_TESTS=$((PASSED_TESTS + 1))
        else
            echo "[FALHA] Padrao nao encontrado: $expected_pattern"
            FAILED_TESTS=$((FAILED_TESTS + 1))
        fi
    else
        echo "[FALHA] AST nao foi exibida"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
}

# Verificar se o compilador existe
if [ ! -f "./compilador" ]; then
    echo "[ERRO] Executavel './compilador' nao encontrado!"
    echo "Execute 'make' ou 'make clean && make' para compilar o projeto."
    exit 1
fi

echo "Iniciando testes de AST..."
echo

run_ast_test "tests/files/ast_assignment.py" "Atribuicao" "="
run_ast_test "tests/files/ast_binop.py" "Operacao binaria" "BINOP.*\+"
run_ast_test "tests/files/ast_comparison.py" "Comparacao" "BINOP.*'e'"
run_ast_test "tests/files/ast_complex_nested.py" "Expressao complexa" "BINOP"
run_ast_test "tests/files/ast_logical_ops.py" "Operadores logicos" "BINOP"
run_ast_test "tests/files/ast_parentheses.py" "Parenteses" "BINOP.*\\*"
run_ast_test "tests/files/ast_precedence.py" "Precedencia" "BINOP.*\\*"
run_ast_test "tests/files/ast_unary_minus.py" "Unario menos" "UNOP"
run_ast_test "tests/files/ast_unary_not.py" "Unario NOT" "UNOP"
run_ast_test "tests/files/ast_variable.py" "Variavel" "ID"

echo
echo "=========================================="
echo "RELATORIO FINAL - AST"
echo "=========================================="
echo "Total: $TOTAL_TESTS | Aprovados: $PASSED_TESTS | Falhados: $FAILED_TESTS"

if [ $FAILED_TESTS -eq 0 ]; then
    echo "Resultado: Todos os testes AST passaram com sucesso."
    exit 0
else
    echo "Resultado: Alguns testes AST falharam."
    exit 1
fi
