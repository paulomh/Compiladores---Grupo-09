#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h"
#include "tabela.h"

#define MAX 211
#define MAX_ESCOPO 100

Simbolo *tabela[MAX];
int escopoAtualID = 0;

unsigned hash(char *s)
{
    unsigned h = 0;
    while (*s)
        h = (h << 4) + *s++;
    return h % MAX;
}

void iniciarEscopo() {
    escopoAtualID++;
}

void finalizarEscopo() {
    if (escopoAtualID > 0) {
        for (int i = 0; i < MAX; i++) {
            Simbolo **s = &tabela[i];
            while (*s) {
                if ((*s)->escopo == escopoAtualID) { 
                    Simbolo *temp = *s;
                    *s = (*s)->prox;
                    free(temp);
                } else {
                    s = &((*s)->prox);
                }
            }
        }
        escopoAtualID--;
    }
}

int escopoAtual() {
    return escopoAtualID;
}

int verificarRedeclaracao(char *nome) {
    unsigned i = hash(nome);
    for (Simbolo *s = tabela[i]; s; s = s->prox) {
        if (strcmp(s->nome, nome) == 0 && s->escopo == escopoAtualID) {
            return 1; // Já existe no escopo atual
        }
    }
    return 0; // Não existe no escopo atual
}

void inserirSimbolo(char *nome, Tipo tipo) {
    if (verificarRedeclaracao(nome)) {
        printf("Erro Semantico: '%s' ja declarado no escopo atual (nivel %d)\n", nome, escopoAtualID);
        return;
    }

    unsigned i = hash(nome);
    Simbolo *s = malloc(sizeof(Simbolo));
    strcpy(s->nome, nome);
    s->tipo = tipo;
    s->escopo = escopoAtualID;
    s->prox = tabela[i];
    tabela[i] = s;
}

void inserirFuncao(char *nome, Tipo tipoRetorno) {
    if (verificarRedeclaracao(nome)) {
        printf("Erro Semantico: Funcao '%s' ja declarada.\n", nome);
        return;
    }

    unsigned i = hash(nome);
    Simbolo *s = malloc(sizeof(Simbolo));
    strcpy(s->nome, nome);
    s->tipo = T_FUNC;
    s->escopo = escopoAtualID;
    s->info.funcao.tipoRetorno = tipoRetorno;
    s->info.funcao.params = NULL;
    s->info.funcao.numParams = 0;
    s->prox = tabela[i];
    tabela[i] = s;
    
    // Inicia um novo escopo para os parâmetros e corpo da função
    iniciarEscopo();
}

void adicionarParametro(char *nomeFuncao, char *nomeParam, Tipo tipo) {
    Simbolo *func = buscarSimbolo(nomeFuncao);

    if (!func || func->tipo != T_FUNC) {
        printf("Erro Interno: Tentando adicionar param a '%s' inexistente.\n", nomeFuncao);
        return;
    }

    Parametro *param = malloc(sizeof(Parametro));
    strcpy(param->nome, nomeParam);
    param->tipo = tipo;
    param->prox = func->info.funcao.params;
    func->info.funcao.params = param;
    func->info.funcao.numParams++;

    // Adiciona o parâmetro como variável no escopo da função
    inserirSimbolo(nomeParam, tipo);
}

Simbolo *buscarSimboloEscopo(char *nome, int escopo) {
    unsigned i = hash(nome);
    for (Simbolo *s = tabela[i]; s; s = s->prox) {
        if (strcmp(s->nome, nome) == 0 && s->escopo == escopo)
            return s;
    }
    return NULL;
}

Simbolo *buscarSimbolo(char *nome) {
    unsigned i = hash(nome);
    Simbolo *s = tabela[i];

    while (s != NULL) {
        if (strcmp(s->nome, nome) == 0) {
            return s;
        }
        s = s->prox;
    }
    
    return NULL;
}

void imprimirTabela() {
    printf("\n=== Tabela de Símbolos ===\n");
    for (int i = 0; i < MAX; i++) {
        for (Simbolo *s = tabela[i]; s; s = s->prox) {
            printf("Nome: %s | ", s->nome);
            printf("Tipo: ");
            switch(s->tipo) {
                case T_INT: printf("int"); break;
                case T_FLOAT: printf("float"); break;
                case T_FUNC: 
                    printf("função -> retorno: ");
                    switch(s->info.funcao.tipoRetorno) {
                        case T_INT: printf("int"); break;
                        case T_FLOAT: printf("float"); break;
                        default: printf("void"); break;
                    }
                    printf(" | params: %d", s->info.funcao.numParams);
                    break;
                default: printf("desconhecido"); break;
            }
            printf(" | Escopo: %d\n", s->escopo);
        }
    }
    printf("========================\n");
}