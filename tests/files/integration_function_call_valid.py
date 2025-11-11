# Teste de Integração - Chamada de função com argumentos corretos
# Esperado:
# 1. 'soma' inserido como FUNÇÃO com parâmetros INT
# 2. Chamada soma(5, 3) valida tipos dos argumentos
# 3. AST valida que argumentos correspondem aos parâmetros
def soma(a, b):
    return a + b

resultado = soma(5, 3)
