# Teste de escopo e tipos
x = 10  # variável global

def funcao_escopo(a, b=20):
    x = 5  # variável local
    y = a + b  # uso de parâmetros
    return y

# Teste de redeclaração
z = 30
z = 40  # redeclaração no mesmo escopo

# Teste de tipos
w = 3.14  # float
resultado = w + x  # erro de tipos

# Teste de função com parâmetros
def calcula(x, y=10):
    if x > y:
        return x * 2
    else:
        return y / 2

# Teste de variável não declarada
valor = nao_existe + 1