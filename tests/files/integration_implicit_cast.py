# Teste de Integração - Atribuição com type casting implícito
# Esperado:
# 1. 'x' inserido como FLOAT
# 2. 'y' inserido como INT
# 3. AST tem operação '+' com tipos FLOAT e INT
# 4. Resultado é FLOAT (casting implícito)
x = 3.14
y = 2
z = x + y
