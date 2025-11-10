#!/bin/bash

# Script de Testes Automatizado - Compilador Grupo 09
# Executa todos os testes do analisador de expressões aritméticas com verificação automática

echo "=========================================="
echo "    TESTES DO COMPILADOR - GRUPO 09"
echo "    Analisador de Expressões Aritméticas"
echo "=========================================="
echo

# Contadores de teste
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Função para executar um teste de sucesso
run_test() {
    local expression="$1"
    local expected="$2"
    local test_name="$3"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    echo -n "Testando: $expression -> "
    
    # Executar o compilador e capturar apenas a linha do resultado
    local result=$(echo "$expression" | ./compilador 2>/dev/null | grep "Resultado:" | sed 's/Resultado: //' | tr -d '\n')
    
    if [ "$result" = "$expected" ]; then
        echo "✅ PASSOU (Resultado: $result)"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        echo "❌ FALHOU (Esperado: $expected, Obtido: $result)"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
}

# Função para executar um teste de erro (deve falhar)
run_error_test() {
    local expression="$1"
    local test_name="$2"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    echo -n "Testando erro: $expression -> "
    
    # Executar o compilador e verificar se há erro
    local output=$(echo "$expression" | ./compilador 2>&1)
    local exit_code=$?
    
    # Verificar se houve erro (exit code != 0 ou mensagem de erro)
    if [ $exit_code -ne 0 ] || echo "$output" | grep -q -E "(Erro|erro|ERROR|Invalid|Caractere invalido|syntax error)" >/dev/null 2>&1; then
        # Checar se há indicação de linha (yylineno)
        if echo "$output" | grep -q -E "(linha|line)[[:space:]]*[0-9]+" >/dev/null 2>&1; then
            echo "✅ PASSOU (Erro com indicação de linha)"
            PASSED_TESTS=$((PASSED_TESTS + 1))
        else
            echo "❌ FALHOU (Erro sem indicação de linha)"
            FAILED_TESTS=$((FAILED_TESTS + 1))
        fi
    else
        echo "❌ FALHOU (Deveria ter dado erro, mas passou)"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
}

# Verificar se o compilador existe
if [ ! -f "./compilador" ]; then
    echo "ERRO: Executável './compilador' não encontrado!"
    echo "Execute 'make' ou 'make clean && make' para compilar o projeto."
    exit 1
fi

echo "Executável encontrado. Iniciando testes automatizados..."
echo

echo "--- Teste 1: Operações Básicas ---"
run_test "3 + 4" "7" "Adição básica"
run_test "7 - 2" "5" "Subtração básica"
run_test "5 * 6" "30" "Multiplicação básica"
run_test "8 / 2" "4" "Divisão básica"
echo

echo "--- Teste 2: Precedência de Operadores ---"
run_test "2 + 3 * 4" "14" "Precedência multiplicação"
run_test "(2 + 3) * 4" "20" "Parênteses alteram precedência"
run_test "10 - 2 * 3" "4" "Precedência multiplicação com subtração"
run_test "(10 - 2) * 3" "24" "Parênteses com subtração"
echo

echo "--- Teste 3: Números Negativos ---"
run_test "-5" "-5" "Número negativo simples"
run_test "-3 + 7" "4" "Número negativo em adição"
run_test "5 + (-3)" "2" "Número negativo entre parênteses"
run_test "(-2) * 3" "-6" "Número negativo em multiplicação"
echo

echo "--- Teste 4: Parênteses Complexos ---"
run_test "((2 + 3) * 4) - 1" "19" "Parênteses aninhados"
run_test "2 * (3 + (4 - 1))" "12" "Parênteses múltiplos aninhados"
run_test "(10 / 2) + (3 * 2)" "11" "Múltiplos grupos de parênteses"
echo

echo "--- Teste 5: Divisão ---"
run_test "12 / 3" "4" "Divisão exata"
run_test "15 / 4" "3" "Divisão inteira"
run_test "0 / 5" "0" "Zero dividido por número"
run_test "5 / 0" "0" "Divisão por zero (tratamento)"
echo

echo "--- Teste 6: Expressões Longas ---"
run_test "1 + 2 + 3 + 4" "10" "Múltiplas adições"
run_test "2 * 3 * 4" "24" "Múltiplas multiplicações"
run_test "10 - 2 - 3 - 1" "4" "Múltiplas subtrações"
run_test "20 / 2 / 2" "5" "Múltiplas divisões"
echo

echo "--- Teste 7: Casos Especiais ---"
run_test "0" "0" "Zero isolado"
run_test "1" "1" "Um isolado"
run_test "-1" "-1" "Menos um"
run_test "(5)" "5" "Número entre parênteses"
run_test "((10))" "10" "Parênteses duplos"
echo

echo "--- Teste 8: Expressões com Espaços ---"
run_test "  3   +   4  " "7" "Expressão com muitos espaços"
run_test "( 2 + 3 ) * 4" "20" "Parênteses com espaços"
run_test "  10  /  2  " "5" "Divisão com espaços"
echo

echo "--- Teste 9: Operadores Lógicos ---"
run_test "1 and 1" "1" "AND com valores verdadeiros"
run_test "1 and 0" "0" "AND com um valor falso"
run_test "0 and 0" "0" "AND com valores falsos"
run_test "1 or 0" "1" "OR com um valor verdadeiro"
run_test "0 or 0" "0" "OR com valores falsos"
run_test "not 0" "1" "NOT com valor falso"
run_test "not 1" "0" "NOT com valor verdadeiro"
run_test "1 and 2 or 0" "1" "Combinação AND e OR"
echo

echo "--- Teste 10: Operadores de Comparação ---"
run_test "5 == 5" "1" "Igualdade verdadeira"
run_test "5 == 3" "0" "Igualdade falsa"
run_test "5 != 3" "1" "Diferença verdadeira"
run_test "5 != 5" "0" "Diferença falsa"
run_test "5 > 3" "1" "Maior que verdadeiro"
run_test "3 > 5" "0" "Maior que falso"
run_test "5 < 3" "0" "Menor que falso"
run_test "3 < 5" "1" "Menor que verdadeiro"
run_test "5 >= 5" "1" "Maior ou igual verdadeiro"
run_test "5 >= 3" "1" "Maior ou igual verdadeiro (maior)"
run_test "3 >= 5" "0" "Maior ou igual falso"
run_test "5 <= 5" "1" "Menor ou igual verdadeiro"
run_test "3 <= 5" "1" "Menor ou igual verdadeiro (menor)"
run_test "5 <= 3" "0" "Menor ou igual falso"
echo

echo "--- Teste 11: Operadores Avançados ---"
run_test "2 ** 3" "8" "Exponencial básico"
run_test "3 ** 2" "9" "Exponencial básico 2"
run_test "2 ** 0" "1" "Exponencial com expoente zero"
run_test "10 % 3" "1" "Módulo básico"
run_test "15 % 4" "3" "Módulo básico 2"
run_test "10 % 2" "0" "Módulo com resto zero"
run_test "15 // 4" "3" "Divisão inteira"
run_test "10 // 3" "3" "Divisão inteira 2"
run_test "8 // 2" "4" "Divisão inteira exata"
echo

echo "--- Teste 12: Números Decimais ---"
run_test "3.5 + 2.5" "5" "Soma de decimais (truncamento para int)"
run_test "10.8 - 5.3" "5" "Subtração de decimais (truncamento para int)"
run_test "2.5 * 4.0" "8" "Multiplicação de decimais (truncamento para int)"
run_test "15.6 / 3.0" "5" "Divisão de decimais (truncamento para int)"
run_test "3.14 + 1" "4" "Decimal com inteiro (truncamento para int)"
echo

echo "--- Teste 13: Precedência Complexa ---"
run_test "2 + 3 * 4 == 14" "1" "Precedência aritmética vs comparação"
run_test "5 > 3 and 2 < 4" "1" "Precedência comparação vs lógica"
run_test "not 5 == 3" "1" "Precedência NOT vs igualdade"
run_test "2 ** 3 * 2" "16" "Precedência exponencial vs multiplicação"
run_test "10 % 3 + 2" "3" "Precedência módulo vs adição"
echo

echo "--- Teste 14: Expressões Complexas ---"
run_test "(5 > 3) and (2 + 2 == 4)" "1" "Expressão lógica complexa"
run_test "not (5 < 3 or 2 > 4)" "1" "NOT com OR entre parênteses"
run_test "2 ** (3 + 1) / 4" "4" "Exponencial com parênteses"
run_test "((10 % 3) * 2) + 1" "3" "Módulo com parênteses aninhados"
echo

echo "--- Teste 15: Casos Extremos ---"
run_test "0 ** 0" "1" "Zero elevado a zero"
run_test "1 ** 100" "1" "Um elevado a qualquer potência"
run_test "(-2) ** 2" "4" "Número negativo elevado a par"
run_test "(-3) ** 3" "-27" "Número negativo elevado a ímpar"
run_test "100 % 1" "0" "Módulo por um"
echo

echo "--- Teste 16: Identificadores (Variáveis) ---"
run_test "x" "0" "Variável simples (placeholder)"
run_test "x + 5" "5" "Variável em expressão"
run_test "variavel_longa" "0" "Variável com underscore"
run_test "var123" "0" "Variável com números"
echo

echo "--- TESTES DE ERRO ---"
echo "--- Teste 17: Sintaxe Inválida ---"
run_error_test "3 +" "Operador sem segundo operando"
run_error_test "+ 3" "Operador sem primeiro operando"
run_error_test "3 * * 4" "Operadores consecutivos"
run_error_test "5 = = 3" "Operador de igualdade malformado"
run_error_test "((3 + 4)" "Parênteses desbalanceados (falta fechar)"
run_error_test "(3 + 4))" "Parênteses desbalanceados (excesso)"
run_error_test "3 + (4 * (2 + 1)" "Parênteses aninhados desbalanceados"
echo

echo "--- Teste 18: Caracteres Inválidos ---"
run_error_test "3 @ 4" "Caractere inválido @"
run_test "5 # comentário" "5" "Comentário válido (ignorado pelo lexer)"
run_error_test "2 $ 3" "Caractere inválido $"
run_error_test "a & b" "Caractere inválido &"
run_error_test "x | y" "Caractere inválido |"
echo

echo "--- Teste 19: Números Inválidos ---"
run_error_test "3.14.15" "Múltiplos pontos decimais"
run_error_test "..5" "Número começando com ponto duplo"
run_error_test "5." "Número terminando com ponto (sem decimais)"
run_error_test "3e5" "Notação científica (não suportada)"
echo

echo "--- Teste 20: Operadores Inválidos ---"
run_error_test "3 +++ 4" "Múltiplos operadores +"
run_test "5 --- 2" "3" "Múltiplos operadores - (válido: 5-(-(-2)))"
run_error_test "a === b" "Operador de igualdade triplo"
run_error_test "x <> y" "Operador de diferença inválido"
echo

echo "--- Teste 21: Comentários e Strings ---"
run_test "10 # isto é um comentário" "10" "Comentário no final da linha"
run_test "# comentário no início
15" "15" "Comentário em linha separada"
echo

echo "--- Teste 22: Casos Limites Adicionais ---"
run_test "0 and 1" "0" "Zero em operação lógica"
run_test "5 or 0" "1" "Operação OR com zero"
run_test "not not 1" "1" "Dupla negação"
run_test "2 ** 2 ** 3" "256" "Exponenciação aninhada (associatividade direita)"
run_test "100 // 7 % 3" "2" "Combinação divisão inteira e módulo"
echo

echo "--- Teste 23: Expressões Muito Complexas ---"
run_test "((5 > 3) and (2 + 2 == 4)) or (not (10 < 5))" "1" "Expressão lógica super complexa"
run_test "2 ** 3 + 4 * 5 - 6 / 2" "25" "Múltiplas operações com precedência"
run_test "(10 % 3) ** (5 - 3) + 7" "8" "Operações avançadas aninhadas"
echo

echo "=========================================="
echo "         RELATÓRIO FINAL DOS TESTES"
echo "=========================================="
echo "Total de testes executados: $TOTAL_TESTS"
echo "Testes aprovados: $PASSED_TESTS"
echo "Testes falharam: $FAILED_TESTS"

if [ $FAILED_TESTS -eq 0 ]; then
    echo ""
    echo "🎉 TODOS OS TESTES PASSARAM! 🎉"
    echo "O compilador está funcionando corretamente!"
    exit 0
else
    echo ""
    echo "⚠️  ALGUNS TESTES FALHARAM!"
    echo "Verifique os resultados acima e corrija os problemas."
    exit 1
fi