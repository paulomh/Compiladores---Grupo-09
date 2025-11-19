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
