# Teste de tipos de retorno e erros de linha

def funcao_int():
    x = 10
    return x  # deve retornar tipo int

def funcao_sem_retorno():
    x = 20
    y = 30
    # sem return, deve ser void

def funcao_erro_tipo(a):
    if a > 10:
        return 42  # retorna int
    else:
        return 3.14  # erro: retorna float em função que deveria retornar int

# Teste de atribuição com tipos incompatíveis
x = 10  # int
y = 3.14  # float
z = x + y  # erro: tipos incompatíveis em operação

# Teste de variável não declarada em diferentes linhas
a = b + 1  # erro: b não declarada