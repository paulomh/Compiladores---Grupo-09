# Teste de Integração - AST com tipo propagado da tabela de símbolos
# Esperado:
# 1. 'x' em tabela com tipo INT
# 2. Nó ID 'x' em AST herda tipo INT do símbolo
# 3. Operação '+' com ambos INT resulta em INT
# 4. Toda a expressão tem tipo INT
x = 20
y = x + 10
