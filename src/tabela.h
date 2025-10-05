#ifndef TABELA_H
#define TABELA_H

#include "ast.h"

typedef struct simbolo
{
    char nome[255];
    Tipo tipo;
    struct simbolo *prox;
} Simbolo;

void inserirSimbolo(char *nome, Tipo tipo);
Simbolo *buscarSimbolo(char *nome);
void imprimirTabela();

#endif