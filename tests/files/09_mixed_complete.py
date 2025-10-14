# Teste misto: combinando todas as funcionalidades
# Comentário inicial
x = 5
y = 10

"""
Bloco de teste complexo
"""

if x < y:
    # Condição verdadeira
    resultado = x + y
    
    if resultado > 10:
        final = resultado * 2
    else:
        final = resultado / 2
else:
    # Condição falsa  
    resultado = y - x
    final = resultado ** 2

# Resultado final
final
