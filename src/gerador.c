#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "gerador.h"
#include "ast.h"

// Criar uma nova lista de instruções
ListaInstrucoes *criarListaInstrucoes()
{
    ListaInstrucoes *lista = malloc(sizeof(ListaInstrucoes));
    if (!lista)
    {
        perror("malloc");
        exit(1);
    }
    lista->inicio = NULL;
    lista->fim = NULL;
    lista->contador_temp = 0;
    lista->contador_label = 0;
    return lista;
}

// Liberar memória da lista de instruções
void liberarListaInstrucoes(ListaInstrucoes *lista)
{
    if (!lista)
        return;

    Instrucao *atual = lista->inicio;
    while (atual)
    {
        Instrucao *prox = atual->prox;
        free(atual);
        atual = prox;
    }
    free(lista);
}

// Gerar nome de variável temporária
char *novoTemp(ListaInstrucoes *lista)
{
    static char temp[32];
    snprintf(temp, sizeof(temp), "t%d", lista->contador_temp++);
    return temp;
}

// Gerar novo label
int novoLabel(ListaInstrucoes *lista)
{
    return lista->contador_label++;
}

// Adicionar instrução à lista
void adicionarInstrucao(ListaInstrucoes *lista, Instrucao *instr)
{
    if (!lista || !instr)
        return;

    instr->prox = NULL;
    if (lista->fim)
    {
        lista->fim->prox = instr;
        lista->fim = instr;
    }
    else
    {
        lista->inicio = lista->fim = instr;
    }
}

// Criar instrução de atribuição
Instrucao *novaInstrucaoAssign(const char *dest, const char *fonte)
{
    Instrucao *instr = malloc(sizeof(Instrucao));
    if (!instr)
    {
        perror("malloc");
        exit(1);
    }
    instr->tipo = INSTR_ASSIGN;
    strncpy(instr->resultado, dest, sizeof(instr->resultado) - 1);
    strncpy(instr->arg1, fonte, sizeof(instr->arg1) - 1);
    instr->arg2[0] = '\0';
    instr->op = 0;
    instr->label = 0;
    instr->prox = NULL;
    return instr;
}