#!/bin/bash

# Script de Testes de Arquivos - Compilador Grupo 09
# Executa testes com arquivos de código Python para validar funcionalidades completas

echo "=========================================="
echo "   TESTES DE ARQUIVOS - COMPILADOR GRUPO 09"
echo "   Validação de Funcionalidades Completas"
echo "=========================================="
echo

# Contadores de teste
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Função para executar um teste de arquivo (deve passar)
run_file_test() {
    local file_path="$1"
    local test_name="$2"
    local expected_behavior="$3"  # "success" ou "error"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    echo -n "Testando arquivo: $(basename "$file_path") -> "
    
    if [ ! -f "$file_path" ]; then
        echo "❌ FALHOU (Arquivo não encontrado)"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        return
    fi
    
    # Executar o compilador com o arquivo
    local output=$(./compilador "$file_path" 2>&1)
    local exit_code=$?
    
    if [ "$expected_behavior" = "success" ]; then
        # Teste deve passar
        if [ $exit_code -eq 0 ] && echo "$output" | grep -q "Análise concluída com sucesso" >/dev/null 2>&1; then
            echo "✅ PASSOU (Compilação bem-sucedida)"
            PASSED_TESTS=$((PASSED_TESTS + 1))
        else
            echo "❌ FALHOU (Deveria compilar mas falhou)"
            echo "   Saída: $(echo "$output" | tail -1)"
            FAILED_TESTS=$((FAILED_TESTS + 1))
        fi
    else
        # Teste deve falhar (arquivo de erro)
        if [ $exit_code -ne 0 ] || echo "$output" | grep -q -E "(Erro|erro|ERROR|syntax error)" >/dev/null 2>&1; then
            echo "✅ PASSOU (Erro detectado corretamente)"
            PASSED_TESTS=$((PASSED_TESTS + 1))
        else
            echo "❌ FALHOU (Deveria ter dado erro mas passou)"
            FAILED_TESTS=$((FAILED_TESTS + 1))
        fi
    fi
}

# Verificar se o compilador existe
if [ ! -f "./compilador" ]; then
    echo "ERRO: Executável './compilador' não encontrado!"
    echo "Execute 'make' ou 'make clean && make' para compilar o projeto."
    exit 1
fi

# Verificar se o diretório de testes existe
if [ ! -d "tests/files" ]; then
    echo "ERRO: Diretório 'tests/files' não encontrado!"
    echo "Os arquivos de teste devem estar no diretório 'tests/files/'."
    exit 1
fi

echo "Executável encontrado. Iniciando testes de arquivos..."
echo

echo "--- Teste 1: Estruturas Condicionais ---"
run_file_test "tests/files/01_conditional_basic.py" "Condicionais básicas" "success"
run_file_test "tests/files/02_conditional_nested.py" "Condicionais aninhadas" "success"
run_file_test "tests/files/03_conditional_complex.py" "Condicionais com expressões complexas" "success"
echo

echo "--- Teste 2: Expressões e Operadores ---"
run_file_test "tests/files/04_expressions_only.py" "Apenas expressões" "success"
echo

echo "--- Teste 3: Atribuições de Variáveis ---"
run_file_test "tests/files/05_assignments.py" "Atribuições simples" "success"
echo

echo "--- Teste 4: Comentários ---"
run_file_test "tests/files/06_comments.py" "Comentários simples e de bloco" "success"
echo

echo "--- Teste 5: Indentação Complexa ---"
run_file_test "tests/files/07_deep_indentation.py" "Indentação profunda" "success"
echo

echo "--- Teste 6: Definições de Função ---"
run_file_test "tests/files/08_functions.py" "Estruturas de função" "success"
echo

echo "--- Teste 7: Funcionalidades Mistas ---"
run_file_test "tests/files/09_mixed_complete.py" "Código completo misto" "success"
echo

echo "--- TESTES DE ERRO ---"
echo "--- Teste 8: Casos de Erro ---"
run_file_test "tests/files/error_01_bad_indentation.py" "Indentação incorreta" "error"
run_file_test "tests/files/error_02_syntax_error.py" "Erro de sintaxe" "error"
run_file_test "tests/files/error_03_unbalanced_parens.py" "Parênteses desbalanceados" "error"
run_file_test "tests/files/error_04_invalid_chars.py" "Caracteres inválidos" "error"
echo

echo "--- Teste 9: Arquivo Original ---"
run_file_test "tests/files/teste.py" "Arquivo de exemplo original" "success"
echo

echo "=========================================="
echo "       RELATÓRIO FINAL DOS TESTES"
echo "=========================================="
echo "Total de testes executados: $TOTAL_TESTS"
echo "Testes aprovados: $PASSED_TESTS"
echo "Testes falharam: $FAILED_TESTS"

if [ $FAILED_TESTS -eq 0 ]; then
    echo ""
    echo "🎉 TODOS OS TESTES DE ARQUIVO PASSARAM! 🎉"
    echo "O compilador está processando arquivos corretamente!"
    exit 0
else
    echo ""
    echo "⚠️  ALGUNS TESTES FALHARAM!"
    echo "Verifique os resultados acima e corrija os problemas."
    exit 1
fi
