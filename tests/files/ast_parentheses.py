# Teste de AST - Parênteses mudam precedência
# Esperado: Adição é filho esquerdo da multiplicação
# (2 + 3) * 4 deve gerar: (* (+ (2) (3)) (4))
# Tipo esperado: INT
(2 + 3) * 4
