# Teste de AST - Variável (ID) em expressão
# Esperado: Nó ID com nome 'x' em lugar de número
# x + 5 deve gerar: (+ (ID "x") (5))
# Tipo esperado: INT (se x foi declarada como INT)
x + 5
