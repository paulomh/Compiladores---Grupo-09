#!/bin/bash

echo "=== Testando Tabela de Símbolos ==="

# Compilar o projeto
make clean
make

# Testar inserção de símbolos
echo -e "\nTeste 1: Inserção de símbolos"
./compilador < tests/files/test_symbol_table.py

# Testar erro de variável não declarada
echo -e "\nTeste 2: Erro de variável não declarada"
echo "w = nao_declarada + 1" | ./compilador

# Testar redeclaração de variável
echo -e "\nTeste 3: Redeclaração de variável"
echo "x = 10; x = 20" | ./compilador

# Testar função
echo -e "\nTeste 4: Declaração e uso de função"
cat tests/files/08_functions.py | ./compilador

# Testar escopo e tipos
echo -e "\nTeste 5: Escopo e tipos"
cat tests/files/test_escopo_tipos.py | ./compilador