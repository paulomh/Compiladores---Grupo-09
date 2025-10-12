#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h"

NoAST *novoNoOp(char op, NoAST *esq, NoAST *dir)
{
    NoAST *no = malloc(sizeof(NoAST));
    no->op = op;
    no->esq = esq;
    no->dir = dir;
    no->tipo = (esq->tipo == dir->tipo) ? esq->tipo : T_ERRO;

    return no;
}

NoAST *novoNoNum(int val)
{
    NoAST *no = malloc(sizeof(NoAST));
    no->val = val;
    no->op = 0;
    no->tipo = T_INT;
    no->esq = no->dir = NULL;

    return no;
}

NoAST *novoNoId(char *nome, Tipo tipo)
{
    NoAST *no = malloc(sizeof(NoAST));
    strcpy(no->nome, nome);
    no->op = 0;
    no->tipo = tipo;
    no->esq = no->dir = NULL;

    return no;
}

void imprimirAST(NoAST *no)
{
    if (no == NULL)
        return;
    if (no->op)
    {
        printf("(");
        imprimirAST(no->esq);
        printf(" %c ", no->op);
        imprimirAST(no->dir);
        printf(")");
    }
    else if (strlen(no->nome) > 0)
    {
        printf("%s", no->nome);
    }
    else
    {
        printf("%d", no->val);
    }
}

int tiposCompativeis(Tipo t1, Tipo t2) {
    return t1 == t2;
}