#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h"

extern int yylineno;  // Declarar linha atual do lexer

NoAST *novoNoOp(char op, NoAST *esq, NoAST *dir)
{
    NoAST *no = malloc(sizeof(NoAST));
    no->op = op;
    no->esq = esq;
    no->dir = dir;
    no->linha = yylineno;  // Armazena a linha atual
    
    // Verifica se os nós são válidos antes de acessar seus tipos
    if (esq && dir) {
        no->tipo = (esq->tipo == dir->tipo) ? esq->tipo : T_ERRO;
        if (no->tipo == T_ERRO) {
            printf("Erro na linha %d: Tipos incompatíveis em operação entre %s e %s\n", 
                   yylineno, getTipoString(esq->tipo), getTipoString(dir->tipo));
        }
    } else if (esq) {
        no->tipo = esq->tipo;
    } else if (dir) {
        no->tipo = dir->tipo;
    } else {
        no->tipo = T_VAZIO;
    }

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

NoAST *novoNoAtrib(char* id, NoAST* expr)
{
    NoAST *no = malloc(sizeof(NoAST));
    no->tipo = expr->tipo;
    no->op = '=';
    strcpy(no->nome, id);
    no->esq = novoNoId(id, expr->tipo);
    no->dir = expr;
    return no;
}

const char* getTipoString(Tipo tipo) {
    switch(tipo) {
        case T_INT: return "inteiro";
        case T_FLOAT: return "float";
        case T_FUNC: return "função";
        case T_VOID: return "void";
        case T_VAZIO: return "vazio";
        case T_ERRO: return "erro";
        default: return "desconhecido";
    }
}

Tipo verificarTipoRetorno(NoAST *no) {
    if (!no) return T_VOID;
    
    // Se for um nó de retorno
    if (no->op == 'R') {
        if (no->esq) {
            return no->esq->tipo;
        }
        return T_VOID;
    }
    
    // Se for um nó de sequência (;)
    if (no->op == ';') {
        Tipo tipoEsq = verificarTipoRetorno(no->esq);
        Tipo tipoDir = verificarTipoRetorno(no->dir);
        
        // Se algum dos lados tem um retorno não void, esse é o tipo da função
        if (tipoEsq != T_VOID) return tipoEsq;
        if (tipoDir != T_VOID) return tipoDir;
        return T_VOID;
    }
    
    return T_VOID;
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