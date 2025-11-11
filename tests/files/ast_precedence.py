# Teste de AST - Precedência de operadores
# Esperado: Multiplicação é filho esquerdo da adição
# 2 + 3 * 4 deve gerar: (+ (2) (* (3) (4)))
# Tipo esperado: INT
2 + 3 * 4
