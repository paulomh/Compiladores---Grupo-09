# Teste de Tabela de Símbolos - Escopo: Variável local vs global
# Esperado: 'x' global com tipo INT
# 'x' local dentro da função em escopo diferente
x = 10

def funcao():
    x = 5
    return x

resultado = funcao()
