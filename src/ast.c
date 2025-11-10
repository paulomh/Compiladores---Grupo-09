#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h"


static void indent(int d) {
    for (int i = 0; i < d; i++) fputs("  ", stdout);
}

static const char* tipo_str(Tipo t) {
    switch (t) {
        case T_INT:   return "T_INT";
        case T_FLOAT: return "T_FLOAT";
        case T_ERRO:  return "T_ERRO";
        case T_VOID:  return "T_VOID";
        case T_FUNC:  return "T_FUNC";
        default:      return "T_DESCONHECIDO";
    }
}

// Evita ler lixo em nome quando não for ID
static int tem_nome(const NoAST *n) {
    return n && n->nome[0] != '\0';
}


NoAST *novoNoOp(char op, NoAST *esq, NoAST *dir)
{
    NoAST *no = malloc(sizeof(NoAST));
    if (!no) { perror("malloc"); exit(1); }
    no->op   = op;
    no->esq  = esq;
    no->dir  = dir;
    no->val  = 0;
    no->nome[0] = '\0';
    no->tipo = (esq && dir && esq->tipo == dir->tipo) ? esq->tipo : T_ERRO;
    return no;
}

NoAST *novoNoNum(int val)
{
    NoAST *no = malloc(sizeof(NoAST));
    if (!no) { perror("malloc"); exit(1); }
    no->val  = val;
    no->op   = 0;
    no->esq  = NULL;
    no->dir  = NULL;
    no->nome[0] = '\0';
    no->tipo = T_INT;
    return no;
}

NoAST *novoNoId(char *nome, Tipo tipo)
{
    NoAST *no = malloc(sizeof(NoAST));
    if (!no) { perror("malloc"); exit(1); }
    no->op   = 0;
    no->esq  = NULL;
    no->dir  = NULL;
    no->val  = 0;
    no->nome[0] = '\0';
    if (nome) {
        strncpy(no->nome, nome, sizeof(no->nome) - 1);
        no->nome[sizeof(no->nome) - 1] = '\0';
    }
    no->tipo = tipo;
    return no;
}


void imprimirAST(NoAST *no)
{
    if (no == NULL) return;

    if (no->op) {
        // operador: imprime (esq op dir) ou (op dir) se unário à direita
        putchar('(');
        if (no->esq) imprimirAST(no->esq);
        printf(" %c ", no->op);
        if (no->dir) imprimirAST(no->dir);
        putchar(')');
    }
    else if (tem_nome(no)) {
        printf("%s", no->nome);
    }
    else {
        printf("%d", no->val);
    }
}


// Impressão rica: mostra a estrutura em árvore com tipos e valores
static void imprimirAST_node(const NoAST *no, int depth)
{
    if (!no) {
        indent(depth); puts("(null)");
        return;
    }

    indent(depth);
    if (no->op) {
        if (no->dir) {
            printf("BINOP '%c' : %s\n", no->op, tipo_str(no->tipo));
        } else {
            printf("UNOP '%c' : %s\n", no->op, tipo_str(no->tipo));
        }
    } else if (tem_nome(no)) {
        printf("ID \"%s\" : %s\n", no->nome, tipo_str(no->tipo));
    } else {
        printf("NUM %d : %s\n", no->val, tipo_str(no->tipo));
    }

    if (no->esq) imprimirAST_node(no->esq, depth + 1);
    if (no->dir) imprimirAST_node(no->dir, depth + 1);
}

void imprimirAST_formatada(const NoAST *raiz)
{
    imprimirAST_node(raiz, 0);
}

int tiposCompativeis(Tipo t1, Tipo t2) {
    return t1 == t2;
}

// Compat: exposição de string de tipo para o parser
const char* getTipoString(Tipo t) {
    return tipo_str(t);
}

// Nó de atribuição: nome = expr
NoAST *novoNoAtrib(char *nome, NoAST *expr)
{
    NoAST *no = malloc(sizeof(NoAST));
    if (!no) return NULL;
    no->op = '=';
    no->val = 0;
    no->nome[0] = '\0';
    if (nome) {
        // copia o identificador para o nó e libera a string do parser
        strncpy(no->nome, nome, sizeof(no->nome) - 1);
        no->nome[sizeof(no->nome) - 1] = '\0';
        free(nome);
    }
    no->esq = expr;   // expressão atribuída
    no->dir = NULL;
    no->tipo = expr ? expr->tipo : T_ERRO;
    return no;
}

// Verificação simples do tipo de retorno de função (stub)
Tipo verificarTipoRetorno(const NoAST *func_body)
{
    // Implementação mínima: se não há corpo, VOID; caso exista, assume o tipo do nó
    if (!func_body) return T_VOID;
    return func_body->tipo ? func_body->tipo : T_VOID;
}