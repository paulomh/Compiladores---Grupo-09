#!/bin/bash

# Script de Testes por Categoria: Bitcode (intermediario) + C (final)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# o script está em tests/scripts; subir dois niveis para chegar à raiz do projeto
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$ROOT_DIR" || exit 1


echo "=========================================="
echo "  TESTES POR CATEGORIA: GERACAO DE CODIGO"
echo "  Bitcode (intermediario) + C (final)"
echo "=========================================="
echo
echo "Iniciando execucao de testes de geracao de codigo..."
echo

# Verificar se o compilador existe
if [ ! -f "./compilador" ]; then
    echo "[ERRO] Executavel './compilador' nao encontrado!"
    echo "Execute 'make' ou 'make clean && make' para compilar o projeto."
    exit 1
fi

# Bitcode
run_bitcode_tests() {
    local TOTAL_TESTS=0 PASSED_TESTS=0 FAILED_TESTS=0
    mkdir -p tests/bitcode

    : # compilador verificado no inicio do script

    for test_file in tests/files/*.py; do
        if [ ! -f "$test_file" ]; then
            continue
        fi
        TOTAL_TESTS=$((TOTAL_TESTS + 1))
        printf "Testando: %s -> " "$(basename "$test_file")"

        local basename_no_ext
        basename_no_ext=$(basename "$test_file" .py)
        local output_file="tests/bitcode/${basename_no_ext}.bt"
        local is_error_test=0
        if [[ "$basename_no_ext" == error_* ]]; then is_error_test=1; fi

        local output
        output=$(./compilador "$test_file" 2>&1) || true
        local exit_code=$?

        if [ $exit_code -eq 0 ]; then
            local bitcode
            bitcode=$(echo "$output" | sed -n '/=== CODIGO INTERMEDIARIO/,/^====================/p' || true)
            if [ -z "$bitcode" ]; then
                if [ $is_error_test -eq 1 ]; then
                    echo "[OK] (erro esperado)"; PASSED_TESTS=$((PASSED_TESTS+1));
                else
                    echo "[FALHA] Secao de codigo intermediario nao encontrada"; FAILED_TESTS=$((FAILED_TESTS+1));
                fi
            else
                echo "$bitcode" > "$output_file"
                local line_count
                line_count=$(wc -l < "$output_file" || echo 0)
                if [ "$line_count" -gt 2 ]; then
                    echo "[OK]"; PASSED_TESTS=$((PASSED_TESTS+1));
                else
                    echo "[FALHA] Codigo intermediario vazio"; FAILED_TESTS=$((FAILED_TESTS+1));
                fi
            fi
        else
            if [ $is_error_test -eq 1 ]; then
                echo "[OK] (erro esperado)"; PASSED_TESTS=$((PASSED_TESTS+1));
            else
                echo "[FALHA] Erro na geracao"; FAILED_TESTS=$((FAILED_TESTS+1));
            fi
        fi
    done

    echo
    echo "RELATORIO - BITCODE"
    echo "=========================================="
    echo "Total: $TOTAL_TESTS | Aprovados: $PASSED_TESTS | Falhados: $FAILED_TESTS"
    if [ $FAILED_TESTS -eq 0 ]; then
        echo "Resultado: Todos os testes de bitcode passaram com sucesso."
        return 0
    else
        echo "Resultado: Alguns testes de bitcode falharam."
        return 1
    fi
}

# C
run_c_tests() {
    local TOTAL_TESTS=0 PASSED_TESTS=0 FAILED_TESTS=0
    mkdir -p tests/c

    : # compilador verificado no inicio do script

    for test_file in tests/files/*.py; do
        if [ ! -f "$test_file" ]; then
            continue
        fi
        TOTAL_TESTS=$((TOTAL_TESTS + 1))
        printf "Testando: %s -> " "$(basename "$test_file")"

        local basename_no_ext
        basename_no_ext=$(basename "$test_file" .py)
        local output_file="tests/c/${basename_no_ext}.c"
        local is_error_test=0
        if [[ "$basename_no_ext" == error_* ]]; then is_error_test=1; fi

        local output
        output=$(./compilador "$test_file" 2>&1) || true
        local exit_code=$?

        # copiar arquivo .c gerado pelo compilador, se existir
        if [ -f "${test_file}.c" ]; then cp "${test_file}.c" "$output_file"; rm -f "${test_file}.c"; fi
        if [ -f "${basename_no_ext}.c" ]; then cp "${basename_no_ext}.c" "$output_file"; rm -f "${basename_no_ext}.c"; fi

        if [ $exit_code -eq 0 ]; then
            if [ -f "$output_file" ] && [ -s "$output_file" ]; then
                if grep -qE "int|void|char|float|double|\{" "$output_file"; then
                    echo "[OK]"; PASSED_TESTS=$((PASSED_TESTS+1));
                else
                    echo "[FALHA] Código C inválido ou vazio"; FAILED_TESTS=$((FAILED_TESTS+1));
                fi
            else
                if [ $is_error_test -eq 1 ]; then
                    echo "[OK] (erro esperado)"; PASSED_TESTS=$((PASSED_TESTS+1));
                else
                    echo "[FALHA] Arquivo C não gerado"; FAILED_TESTS=$((FAILED_TESTS+1));
                fi
            fi
        else
            if [ $is_error_test -eq 1 ]; then
                echo "[OK] (erro esperado)"; PASSED_TESTS=$((PASSED_TESTS+1));
            else
                echo "[FALHA] Erro na compilação"; FAILED_TESTS=$((FAILED_TESTS+1));
            fi
        fi
    done

    echo
    echo "RELATORIO - C"
    echo "=========================================="
    echo "Total: $TOTAL_TESTS | Aprovados: $PASSED_TESTS | Falhados: $FAILED_TESTS"
    if [ $FAILED_TESTS -eq 0 ]; then
        echo "Resultado: Todos os testes de geração C passaram com sucesso."
        return 0
    else
        echo "Resultado: Alguns testes de geração C falharam."
        return 1
    fi
}

echo "-> Executando testes de Bitcode (intermediário)..."
run_bitcode_tests
RC_BITCODE=$?

echo
echo "-> Executando testes de Código C (final)..."
run_c_tests
RC_C=$?

echo
echo "=========================================="
echo "RELATORIO FINAL - GERACAO DE CODIGO"
echo "=========================================="
if [ $RC_BITCODE -eq 0 ]; then
    echo "[OK] Bitcode: SUCESSO"
else
    echo "[FALHA] Bitcode: FALHOU (code=$RC_BITCODE)"
fi
if [ $RC_C -eq 0 ]; then
    echo "[OK] Geracao C: SUCESSO"
else
    echo "[FALHA] Geracao C: FALHOU (code=$RC_C)"
fi
if [ $RC_BITCODE -eq 0 ] && [ $RC_C -eq 0 ]; then
    echo "Resultado: Todos os testes passaram com sucesso."
    exit 0
else
    echo "Resultado: Um ou mais testes falharam."
    exit 1
fi