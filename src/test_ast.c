#include <stdio.h>
#include "ast.h"


int main() {
    // Cria nós simples para testar a AST
    NoAST *x = novoNoId("x", T_INT);
    NoAST *y = novoNoId("y", T_INT);
    NoAST *dois = novoNoNum(2);

    // Cria (x + (2 * y))
    NoAST *mul = novoNoOp('*', dois, y);
    NoAST *soma = novoNoOp('+', x, mul);

    // Teste 1: impressão compacta (infixa)
    printf("=== AST Compacta ===\n");
    imprimirAST(soma);
    printf("\n\n");

    // Teste 2: impressão formatada (árvore)
    printf("=== AST Formatada ===\n");
    imprimirAST_formatada(soma);

    return 0;
}
