# Teste de Integração - Escopo com shadowing
# Esperado:
# 1. 'x' global inserido como INT com escopo 0
# 2. 'x' local inserido como INT com escopo 1 (dentro de funcao)
# 3. Dentro de funcao, 'x' se refere à variável local (escopo 1)
# 4. Fora de funcao, 'x' se refere à global (escopo 0)
x = 100

def funcao():
    x = 50
    return x

resultado = funcao()
y = x
