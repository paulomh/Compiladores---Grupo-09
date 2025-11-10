#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h"
#include "tabela.h"

#define MAX 211
#define MAX_ESCOPO 100

Simbolo *tabela[MAX];
int pilhaEscopo[MAX_ESCOPO];
int topoEscopo = 0;

unsigned hash(char *s)
{
    unsigned h = 0;
    while (*s)
        h = (h << 4) + *s++;
    return h % MAX;
}

void iniciarEscopo() {
    /* Evitar comportamento indefinido ao usar topoEscopo++ e topoEscopo
       na mesma expressão. Primeiro armazena o valor atual, depois incrementa. */
    pilhaEscopo[topoEscopo] = topoEscopo;
    topoEscopo++;
}

void finalizarEscopo() {
    if (topoEscopo > 0) {
        // Remove símbolos do escopo atual
        for (int i = 0; i < MAX; i++) {
            Simbolo **s = &tabela[i];
            while (*s) {
                if ((*s)->escopo == topoEscopo - 1) {
                    Simbolo *temp = *s;
                    *s = (*s)->prox;
                    free(temp);
                } else {
                    s = &((*s)->prox);
                }
            }
        }
        topoEscopo--;
    }
}

int escopoAtual() {
    return topoEscopo > 0 ? pilhaEscopo[topoEscopo - 1] : 0;
}

int verificarRedeclaracao(char *nome) {
    unsigned i = hash(nome);
    for (Simbolo *s = tabela[i]; s; s = s->prox) {
        if (strcmp(s->nome, nome) == 0 && s->escopo == escopoAtual()) {
            return 1; // Já existe no escopo atual
        }
    }
    return 0; // Não existe no escopo atual
}

void inserirSimbolo(char *nome, Tipo tipo) {
    if (verificarRedeclaracao(nome)) {
        printf("Erro: Variável '%s' já declarada no escopo atual\n", nome);
        return;
    }

    unsigned i = hash(nome);
    Simbolo *s = malloc(sizeof(Simbolo));
    strcpy(s->nome, nome);
    s->tipo = tipo;
    s->escopo = escopoAtual();
    s->prox = tabela[i];
    tabela[i] = s;
}

void inserirFuncao(char *nome, Tipo tipoRetorno) {
    if (verificarRedeclaracao(nome)) {
        printf("Erro: Função '%s' já declarada no escopo atual\n", nome);
        return;
    }

    unsigned i = hash(nome);
    Simbolo *s = malloc(sizeof(Simbolo));
    strcpy(s->nome, nome);
    s->tipo = T_FUNC;
    s->escopo = escopoAtual();
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
        printf("Erro: Função '%s' não encontrada\n", nomeFuncao);
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
    // Busca do escopo mais interno para o mais externo
    for (int e = topoEscopo - 1; e >= 0; e--) {
        Simbolo *s = buscarSimboloEscopo(nome, pilhaEscopo[e]);
        if (s) return s;
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