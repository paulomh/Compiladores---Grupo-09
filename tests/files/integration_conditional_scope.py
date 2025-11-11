# Teste de Integração - Declaração condicional (variável em if)
# Esperado:
# 1. 'x' inserido com escopo global (pré-declaração)
# 2. Dentro do if, 'x' ainda é escopo global
# 3. AST valida que 'x' existe quando referenciada
if 5 > 3:
    x = 10
else:
    x = 20

resultado = x
