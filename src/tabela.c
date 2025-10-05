#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h"
#include "tabela.h"

#define MAX 211

Simbolo *tabela[MAX];

unsigned hash(char *s)
{
    unsigned h = 0;
    while (*s)
        h = (h << 4) + *s++;
    return h % MAX;
}

void inserirSimbolo(char *nome, Tipo tipo)
{
    unsigned i = hash(nome);
    Simbolo *s = malloc(sizeof(Simbolo));
    strcpy(s->nome, nome);
    s->tipo = tipo;
    s->prox = tabela[i];
    tabela[i] = s;
}

Simbolo *buscarSimbolo(char *nome)
{
    unsigned i = hash(nome);
    for (Simbolo *s = tabela[i]; s; s = s->prox)
    {
        if (strcmp(s->nome, nome) == 0)
            return s;
    }
    return NULL;
}

void imprimirTabela()
{
    for (int i = 0; i < MAX; i++)
    {
        for (Simbolo *s = tabela[i]; s; s = s->prox)
        {
            printf("Nome: %s, Tipo: %s\n", s->nome, s->tipo == T_INT ? "int" : "float");
        }
    }
}