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

// Criar instrução binária
Instrucao *novaInstrucaoBinop(const char *dest, const char *arg1, char op, const char *arg2)
{
    Instrucao *instr = malloc(sizeof(Instrucao));
    if (!instr)
    {
        perror("malloc");
        exit(1);
    }
    instr->tipo = INSTR_BINOP;
    strncpy(instr->resultado, dest, sizeof(instr->resultado) - 1);
    strncpy(instr->arg1, arg1, sizeof(instr->arg1) - 1);
    strncpy(instr->arg2, arg2, sizeof(instr->arg2) - 1);
    instr->op = op;
    instr->label = 0;
    instr->prox = NULL;
    return instr;
}

// Criar instrução unária
Instrucao *novaInstrucaoUnop(const char *dest, char op, const char *arg)
{
    Instrucao *instr = malloc(sizeof(Instrucao));
    if (!instr)
    {
        perror("malloc");
        exit(1);
    }
    instr->tipo = INSTR_UNOP;
    strncpy(instr->resultado, dest, sizeof(instr->resultado) - 1);
    strncpy(instr->arg1, arg, sizeof(instr->arg1) - 1);
    instr->arg2[0] = '\0';
    instr->op = op;
    instr->label = 0;
    instr->prox = NULL;
    return instr;
}

// Criar instrução de label
Instrucao *novaInstrucaoLabel(int label)
{
    Instrucao *instr = malloc(sizeof(Instrucao));
    if (!instr)
    {
        perror("malloc");
        exit(1);
    }
    instr->tipo = INSTR_LABEL;
    instr->resultado[0] = '\0';
    instr->arg1[0] = '\0';
    instr->arg2[0] = '\0';
    instr->op = 0;
    instr->label = label;
    instr->prox = NULL;
    return instr;
}

// Criar instrução goto
Instrucao *novaInstrucaoGoto(int label)
{
    Instrucao *instr = malloc(sizeof(Instrucao));
    if (!instr)
    {
        perror("malloc");
        exit(1);
    }
    instr->tipo = INSTR_GOTO;
    instr->resultado[0] = '\0';
    instr->arg1[0] = '\0';
    instr->arg2[0] = '\0';
    instr->op = 0;
    instr->label = label;
    instr->prox = NULL;
    return instr;
}

// Criar instrução if_false
Instrucao *novaInstrucaoIfFalse(const char *cond, int label)
{
    Instrucao *instr = malloc(sizeof(Instrucao));
    if (!instr)
    {
        perror("malloc");
        exit(1);
    }
    instr->tipo = INSTR_IF_FALSE;
    instr->resultado[0] = '\0';
    strncpy(instr->arg1, cond, sizeof(instr->arg1) - 1);
    instr->arg2[0] = '\0';
    instr->op = 0;
    instr->label = label;
    instr->prox = NULL;
    return instr;
}

// Criar instrução if_true
Instrucao *novaInstrucaoIfTrue(const char *cond, int label)
{
    Instrucao *instr = malloc(sizeof(Instrucao));
    if (!instr)
    {
        perror("malloc");
        exit(1);
    }
    instr->tipo = INSTR_IF_TRUE;
    instr->resultado[0] = '\0';
    strncpy(instr->arg1, cond, sizeof(instr->arg1) - 1);
    instr->arg2[0] = '\0';
    instr->op = 0;
    instr->label = label;
    instr->prox = NULL;
    return instr;
}

// Criar instrução return
Instrucao *novaInstrucaoReturn(const char *valor)
{
    Instrucao *instr = malloc(sizeof(Instrucao));
    if (!instr)
    {
        perror("malloc");
        exit(1);
    }
    instr->tipo = INSTR_RETURN;
    instr->resultado[0] = '\0';
    if (valor)
    {
        strncpy(instr->arg1, valor, sizeof(instr->arg1) - 1);
    }
    else
    {
        instr->arg1[0] = '\0';
    }
    instr->arg2[0] = '\0';
    instr->op = 0;
    instr->label = 0;
    instr->prox = NULL;
    return instr;
}

// Criar instrução func_begin
Instrucao *novaInstrucaoFuncBegin(const char *nome)
{
    Instrucao *instr = malloc(sizeof(Instrucao));
    if (!instr)
    {
        perror("malloc");
        exit(1);
    }
    instr->tipo = INSTR_FUNC_BEGIN;
    strncpy(instr->resultado, nome, sizeof(instr->resultado) - 1);
    instr->arg1[0] = '\0';
    instr->arg2[0] = '\0';
    instr->op = 0;
    instr->label = 0;
    instr->prox = NULL;
    return instr;
}

// Criar instrução func_end
Instrucao *novaInstrucaoFuncEnd(const char *nome)
{
    Instrucao *instr = malloc(sizeof(Instrucao));
    if (!instr)
    {
        perror("malloc");
        exit(1);
    }
    instr->tipo = INSTR_FUNC_END;
    strncpy(instr->resultado, nome, sizeof(instr->resultado) - 1);
    instr->arg1[0] = '\0';
    instr->arg2[0] = '\0';
    instr->op = 0;
    instr->label = 0;
    instr->prox = NULL;
    return instr;
}

// Função auxiliar para gerar código de uma expressão
// Retorna o nome do temporário/variável que contém o resultado (cópia estática)
static char *gerarCodigoExpr(NoAST *no, ListaInstrucoes *lista)
{
    static char resultado_estatico[32];

    if (!no)
        return NULL;

    // Número: retorna string com o valor
    if (no->op == 0 && no->nome[0] == '\0')
    {
        snprintf(resultado_estatico, sizeof(resultado_estatico), "%d", no->val);
        return resultado_estatico;
    }

    // Identificador: retorna o nome da variável
    if (no->op == 0 && no->nome[0] != '\0')
    {
        strncpy(resultado_estatico, no->nome, sizeof(resultado_estatico) - 1);
        resultado_estatico[sizeof(resultado_estatico) - 1] = '\0';
        return resultado_estatico;
    }

    // Operação binária
    if (no->op && no->esq && no->dir)
    {
        char *esq_temp = gerarCodigoExpr(no->esq, lista);
        char esq_copia[32];
        strncpy(esq_copia, esq_temp, sizeof(esq_copia) - 1);
        esq_copia[sizeof(esq_copia) - 1] = '\0';

        char *dir_temp = gerarCodigoExpr(no->dir, lista);
        char dir_copia[32];
        strncpy(dir_copia, dir_temp, sizeof(dir_copia) - 1);
        dir_copia[sizeof(dir_copia) - 1] = '\0';

        char *resultado = novoTemp(lista);
        strncpy(resultado_estatico, resultado, sizeof(resultado_estatico) - 1);
        resultado_estatico[sizeof(resultado_estatico) - 1] = '\0';

        // Mapear operadores especiais para caracteres únicos normalizados
        // Estes caracteres serão transcritos 1:1 para C pelo gerador final
        char op_char = no->op;
        switch (no->op)
        {
        case 'e':
            op_char = 'E';
            break; // E = == (igualdade)
        case 'd':
            op_char = 'D';
            break; // D = != (diferença)
        case 'g':
            op_char = 'G';
            break; // G = >= (greater or equal)
        case 'l':
            op_char = 'L';
            break; // L = <= (less or equal)
        case '^':
            op_char = 'P';
            break; // P = ** (potência/pow)
        case '|':
            op_char = '|';
            break; // | = || (OR lógico)
        case '&':
            op_char = '&';
            break; // & = && (AND lógico)
        }

        Instrucao *instr = novaInstrucaoBinop(resultado_estatico, esq_copia, op_char, dir_copia);
        adicionarInstrucao(lista, instr);
        return resultado_estatico;
    }

    // Operação unária
    if (no->op && no->dir)
    {
        char *arg_temp = gerarCodigoExpr(no->dir, lista);
        if (!arg_temp)
            return NULL;

        char arg_copia[32];
        strncpy(arg_copia, arg_temp, sizeof(arg_copia) - 1);
        arg_copia[sizeof(arg_copia) - 1] = '\0';

        char *resultado = novoTemp(lista);
        strncpy(resultado_estatico, resultado, sizeof(resultado_estatico) - 1);
        resultado_estatico[sizeof(resultado_estatico) - 1] = '\0';

        Instrucao *instr = novaInstrucaoUnop(resultado_estatico, no->op, arg_copia);
        adicionarInstrucao(lista, instr);
        return resultado_estatico;
    }

    // Operação unária à esquerda (menos unário com subtração de 0)
    if (no->op && no->esq && !no->dir)
    {
        char *arg_temp = gerarCodigoExpr(no->esq, lista);
        if (!arg_temp)
            return NULL;

        char arg_copia[32];
        strncpy(arg_copia, arg_temp, sizeof(arg_copia) - 1);
        arg_copia[sizeof(arg_copia) - 1] = '\0';

        char *resultado = novoTemp(lista);
        strncpy(resultado_estatico, resultado, sizeof(resultado_estatico) - 1);
        resultado_estatico[sizeof(resultado_estatico) - 1] = '\0';

        Instrucao *instr = novaInstrucaoUnop(resultado_estatico, no->op, arg_copia);
        adicionarInstrucao(lista, instr);
        return resultado_estatico;
    }

    return NULL;
}

// Gerar código intermediário a partir da AST
void gerarCodigoIntermediario(NoAST *raiz, ListaInstrucoes *lista)
{
    if (!raiz || !lista)
        return;

    // Sequência de comandos (;)
    if (raiz->op == ';')
    {
        gerarCodigoIntermediario(raiz->esq, lista);
        gerarCodigoIntermediario(raiz->dir, lista);
        return;
    }

    // Atribuição (=)
    if (raiz->op == '=' && raiz->nome[0] != '\0')
    {
        char *expr_temp = gerarCodigoExpr(raiz->esq, lista);
        if (expr_temp)
        {
            Instrucao *instr = novaInstrucaoAssign(raiz->nome, expr_temp);
            adicionarInstrucao(lista, instr);
        }
        return;
    }

    // IF (?)
    if (raiz->op == '?')
    {
        char *cond_temp = gerarCodigoExpr(raiz->esq, lista);
        int label_false = novoLabel(lista);
        int label_end = novoLabel(lista);

        // if_false cond goto label_false
        adicionarInstrucao(lista, novaInstrucaoIfFalse(cond_temp, label_false));

        // Código do then
        gerarCodigoIntermediario(raiz->dir, lista);

        // goto label_end
        adicionarInstrucao(lista, novaInstrucaoGoto(label_end));

        // label_false:
        adicionarInstrucao(lista, novaInstrucaoLabel(label_false));

        // label_end:
        adicionarInstrucao(lista, novaInstrucaoLabel(label_end));
        return;
    }

    // IF-ELSE (:)
    if (raiz->op == ':' && raiz->esq && raiz->esq->op == '?')
    {
        NoAST *if_node = raiz->esq;
        char *cond_temp = gerarCodigoExpr(if_node->esq, lista);
        int label_else = novoLabel(lista);
        int label_end = novoLabel(lista);

        // if_false cond goto label_else
        adicionarInstrucao(lista, novaInstrucaoIfFalse(cond_temp, label_else));

        // Código do then
        gerarCodigoIntermediario(if_node->dir, lista);

        // goto label_end
        adicionarInstrucao(lista, novaInstrucaoGoto(label_end));

        // label_else:
        adicionarInstrucao(lista, novaInstrucaoLabel(label_else));

        // Código do else
        gerarCodigoIntermediario(raiz->dir, lista);

        // label_end:
        adicionarInstrucao(lista, novaInstrucaoLabel(label_end));
        return;
    }

    // Função (F)
    if (raiz->op == 'F')
    {
        // Pega o nome da função do nó esquerdo
        if (raiz->esq && raiz->esq->op == 'P' && raiz->esq->esq)
        {
            const char *func_name = raiz->esq->esq->nome;
            adicionarInstrucao(lista, novaInstrucaoFuncBegin(func_name));

            // Gerar código do corpo da função
            gerarCodigoIntermediario(raiz->dir, lista);

            adicionarInstrucao(lista, novaInstrucaoFuncEnd(func_name));
        }
        return;
    }

    // Return (R)
    if (raiz->op == 'R')
    {
        if (raiz->esq)
        {
            char *ret_temp = gerarCodigoExpr(raiz->esq, lista);
            adicionarInstrucao(lista, novaInstrucaoReturn(ret_temp));
        }
        else
        {
            adicionarInstrucao(lista, novaInstrucaoReturn(NULL));
        }
        return;
    }

    // Expressão solta (avaliar para efeito colateral)
    if (raiz->op || raiz->nome[0] != '\0' || raiz->val)
    {
        gerarCodigoExpr(raiz, lista);
    }
}

// Imprimir código intermediário
void imprimirCodigoIntermediario(ListaInstrucoes *lista)
{
    if (!lista)
        return;

    printf("\n=== CODIGO INTERMEDIARIO (3 ENDERECOS) ===\n");

    Instrucao *atual = lista->inicio;
    while (atual)
    {
        switch (atual->tipo)
        {
        case INSTR_ASSIGN:
            printf("%s = %s\n", atual->resultado, atual->arg1);
            break;

        case INSTR_BINOP:
            printf("%s = %s %c %s\n", atual->resultado, atual->arg1, atual->op, atual->arg2);
            break;

        case INSTR_UNOP:
            printf("%s = %c %s\n", atual->resultado, atual->op, atual->arg1);
            break;

        case INSTR_LABEL:
            printf("L%d:\n", atual->label);
            break;

        case INSTR_GOTO:
            printf("goto L%d\n", atual->label);
            break;

        case INSTR_IF_FALSE:
            printf("if_false %s goto L%d\n", atual->arg1, atual->label);
            break;

        case INSTR_IF_TRUE:
            printf("if_true %s goto L%d\n", atual->arg1, atual->label);
            break;

        case INSTR_RETURN:
            if (atual->arg1[0] != '\0')
            {
                printf("return %s\n", atual->arg1);
            }
            else
            {
                printf("return\n");
            }
            break;

        case INSTR_FUNC_BEGIN:
            printf("\nfunc_begin %s\n", atual->resultado);
            break;

        case INSTR_FUNC_END:
            printf("func_end %s\n", atual->resultado);
            break;

        default:
            printf("(instrucao desconhecida)\n");
        }
        atual = atual->prox;
    }

    printf("==========================================\n");
}
