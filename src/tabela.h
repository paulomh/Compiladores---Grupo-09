#ifndef TABELA_H
#define TABELA_H

#include "ast.h"

typedef struct parametro {
    char nome[255];
    Tipo tipo;
    struct parametro *prox;
} Parametro;

typedef struct funcao {
    Parametro *params;
    Tipo tipoRetorno;
    int numParams;
} Funcao;

typedef struct simbolo {
    char nome[255];
    Tipo tipo;
    int escopo;
    union {
        Funcao funcao;
        int valor;
    } info;
    struct simbolo *prox;
} Simbolo;

// Funções de gerenciamento de escopo
void iniciarEscopo();
void finalizarEscopo();
int escopoAtual();

// Funções da tabela de símbolos
void inserirSimbolo(char *nome, Tipo tipo);
void inserirFuncao(char *nome, Tipo tipoRetorno);
void adicionarParametro(char *nomeFuncao, char *nomeParam, Tipo tipo);
Simbolo *buscarSimbolo(char *nome);
Simbolo *buscarSimboloEscopo(char *nome, int escopo);
int verificarRedeclaracao(char *nome);
void imprimirTabela();

#endif