# Teste de Tabela de Símbolos - Função aninhada
# Esperado: 'externa' com escopo global
# Esperado: 'interna' com escopo dentro de 'externa'
# Esperado: Parâmetros de cada função no escopo apropriado
def externa(x):
    def interna(y):
        return x + y
    return interna(5)
