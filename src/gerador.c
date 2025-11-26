#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "gerador.h"
#include "ast.h"
#define MAX 255
#define SAFE_STRCPY(dest, src)                          \
    do                                                  \
    {                                                   \
        if ((src))                                      \
        {                                               \
            strncpy((dest), (src), sizeof((dest)) - 1); \
            (dest)[sizeof((dest)) - 1] = '\0';          \
        }                                               \
        else                                            \
        {                                               \
            (dest)[0] = '\0';                           \
        }                                               \
    } while (0)

static char *gerarCodigoExpr(NoAST *no, ListaInstrucoes *lista);

static Instrucao *alocarInstrucao(TipoInstrucao tipo)
{
    Instrucao *instrucao = malloc(sizeof(Instrucao));

    if (!instrucao)
    {
        perror("Erro fatal: Falha ao alocar instrucao");
        exit(1);
    }

    memset(instrucao, 0, sizeof(Instrucao));
    instrucao->tipo = tipo;
    return instrucao;
}

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
    static char buffers[4][MAX];
    static int idx = 0;

    idx = (idx + 1) % 4;

    snprintf(buffers[idx], MAX, "t%d", lista->contador_temp++);
    return buffers[idx];
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
    Instrucao *instr = alocarInstrucao(INSTR_ASSIGN);
    SAFE_STRCPY(instr->resultado, dest);
    SAFE_STRCPY(instr->arg1, fonte);
    return instr;
}

// Criar instrução binária
Instrucao *novaInstrucaoBinop(const char *dest, const char *arg1, char op, const char *arg2)
{
    Instrucao *instr = alocarInstrucao(INSTR_BINOP);
    SAFE_STRCPY(instr->resultado, dest);
    SAFE_STRCPY(instr->arg1, arg1);
    SAFE_STRCPY(instr->arg2, arg2);
    instr->op = op;
    return instr;
}

// Criar instrução unária
Instrucao *novaInstrucaoUnop(const char *dest, char op, const char *arg)
{
    Instrucao *instr = alocarInstrucao(INSTR_UNOP);
    SAFE_STRCPY(instr->resultado, dest);
    SAFE_STRCPY(instr->arg1, arg);
    instr->op = op;
    return instr;
}

// Criar instrução de label
Instrucao *novaInstrucaoLabel(int label)
{
    Instrucao *instr = alocarInstrucao(INSTR_LABEL);
    instr->label = label;
    return instr;
}

// Criar instrução goto
Instrucao *novaInstrucaoGoto(int label)
{
    Instrucao *instr = alocarInstrucao(INSTR_GOTO);
    instr->label = label;
    return instr;
}

// Criar instrução if_false
Instrucao *novaInstrucaoIfFalse(const char *cond, int label)
{
    Instrucao *instr = alocarInstrucao(INSTR_IF_FALSE);
    SAFE_STRCPY(instr->arg1, cond);
    instr->label = label;
    return instr;
}

// Criar instrução if_true
Instrucao *novaInstrucaoIfTrue(const char *cond, int label)
{
    Instrucao *instr = alocarInstrucao(INSTR_IF_TRUE);
    SAFE_STRCPY(instr->arg1, cond);
    instr->label = label;
    return instr;
}

// Criar instrução return
Instrucao *novaInstrucaoReturn(const char *valor)
{
    Instrucao *instr = alocarInstrucao(INSTR_RETURN);
    if (valor)
    {
        SAFE_STRCPY(instr->arg1, valor);
    }
    return instr;
}

// Criar instrução func_begin
Instrucao *novaInstrucaoFuncBegin(const char *nome)
{
    Instrucao *instr = alocarInstrucao(INSTR_FUNC_BEGIN);
    SAFE_STRCPY(instr->resultado, nome);
    return instr;
}

// Criar instrução func_end
Instrucao *novaInstrucaoFuncEnd(const char *nome)
{
    Instrucao *instr = alocarInstrucao(INSTR_FUNC_END);
    SAFE_STRCPY(instr->resultado, nome);
    return instr;
}

Instrucao *novaInstrucaoParam(const char *nome)
{
    Instrucao *instr = alocarInstrucao(INSTR_PARAM);
    SAFE_STRCPY(instr->arg1, nome); // "param nome"
    return instr;
}

Instrucao *novaInstrucaoPrint(const char *var)
{
    Instrucao *instr = alocarInstrucao(INSTR_PRINT);
    if(var)
        SAFE_STRCPY(instr->arg1, var);
    return instr;
}

Instrucao *novaInstrucaoScan(const char *dest)
{
    Instrucao *instr = alocarInstrucao(INSTR_SCAN);
    SAFE_STRCPY(instr->resultado, dest);
    return instr;
}

Instrucao *novaInstrucaoArrInit(const char *dest, const char *vals) {
    Instrucao *instr = alocarInstrucao(INSTR_ARR_INIT);
    SAFE_STRCPY(instr->resultado, dest);
    SAFE_STRCPY(instr->arg1, vals);
    return instr;
}
Instrucao *novaInstrucaoArrGet(const char *dest, const char *array, const char *index) {
    Instrucao *instr = alocarInstrucao(INSTR_ARR_GET);
    SAFE_STRCPY(instr->resultado, dest);
    SAFE_STRCPY(instr->arg1, array);
    SAFE_STRCPY(instr->arg2, index);
    return instr;
}
Instrucao *novaInstrucaoArrSet(const char *array, const char *index, const char *val) {
    Instrucao *instr = alocarInstrucao(INSTR_ARR_SET);
    SAFE_STRCPY(instr->resultado, array);
    SAFE_STRCPY(instr->arg1, index);
    SAFE_STRCPY(instr->arg2, val);
    return instr;
}

// Função auxiliar recursiva para extrair parâmetros de uma função
static void processarParametros(NoAST *no, ListaInstrucoes *lista)
{
    if (!no)
        return;

    if (no->op == ',')
    {
        processarParametros(no->esq, lista);
        processarParametros(no->dir, lista);
        return;
    }

    if (no->op == '=')
    {
        if (no->esq && no->esq->nome[0] != '\0')
        {
            adicionarInstrucao(lista, novaInstrucaoParam(no->esq->nome));
        }
        return;
    }

    if (no->nome[0] != '\0')
    {
        adicionarInstrucao(lista, novaInstrucaoParam(no->nome));
        return;
    }
}

// Função auxiliar recursiva para montar string de argumentos (ex: "t0, t1, 15")
static void montarStringArgumentos(NoAST *no, ListaInstrucoes *lista, char *buffer, int *pos)
{
    if (!no) 
        return;

    if (no->op == ',')
    {
        montarStringArgumentos(no->esq, lista, buffer, pos);
        
        // Adiciona a vírgula separadora
        if (*pos < MAX - 2) {
            buffer[(*pos)++] = ',';
            buffer[(*pos)++] = ' ';
            buffer[*pos] = '\0';
        }

        montarStringArgumentos(no->dir, lista, buffer, pos);
        return;
    }

    char *res_temp = gerarCodigoExpr(no, lista);
    
    // Copia o resultado para o buffer acumulador
    if (res_temp) {
        int len = strlen(res_temp);
        if (*pos + len < MAX - 1) {
            strcpy(buffer + *pos, res_temp);
            *pos += len;
            buffer[*pos] = '\0';
        }
    }
}

// Função auxiliar para gerar código de uma expressão
// Retorna o nome do temporário/variável que contém o resultado (cópia estática)
static char *gerarCodigoExpr(NoAST *no, ListaInstrucoes *lista)
{
    static char buffers[8][MAX];
    static int idx = 0;

    if (!no)
        return NULL;

    idx = (idx + 1) % 8;
    char *resultado_atual = buffers[idx];

    // Número: retorna string com o valor
    if (no->op == 0 && no->nome[0] == '\0')
    {
        snprintf(resultado_atual, MAX, "%d", no->val);
        return resultado_atual;
    }

    // String
    if (no->tipo == T_STRING) 
    {
        snprintf(resultado_atual, MAX, "%s", no->nome);
        return resultado_atual;
    }

    // Identificador: retorna o nome da variável
    if (no->op == 0 && no->nome[0] != '\0')
    {
        snprintf(resultado_atual, MAX, "%s", no->nome);
        return resultado_atual;
    }

    if(no->op == 'C')
    {
        char *nome_func = no->esq->nome;

        if(strcmp(nome_func, "input") == 0)
        {
            char *temp_dest = novoTemp(lista);
            snprintf(resultado_atual, MAX, "%s", temp_dest);
            adicionarInstrucao(lista, novaInstrucaoScan(temp_dest));
            return resultado_atual;
        }

        if(no->esq && strcmp(nome_func, "print") == 0)
        {
            NoAST *arg = no->dir;

            if(arg)
            {
                char *res_temp = gerarCodigoExpr(arg, lista);
                char arg_copia[MAX];

                if(res_temp)
                    SAFE_STRCPY(arg_copia, res_temp);
                else
                    strcpy(arg_copia, "0");
                
                adicionarInstrucao(lista, novaInstrucaoPrint(arg_copia));
            } 
            else
            {
                adicionarInstrucao(lista, novaInstrucaoPrint(""));
            } 
            return NULL;
        }

        char args_buffer[MAX] = ""; 
        int pos = 0;

        if (no->dir) {
            montarStringArgumentos(no->dir, lista, args_buffer, &pos);
        }

        char *temp_dest = novoTemp(lista);
        snprintf(resultado_atual, MAX, "%s", temp_dest);

        Instrucao *instr = alocarInstrucao(INSTR_CALL);
        SAFE_STRCPY(instr->resultado, temp_dest);
        SAFE_STRCPY(instr->arg1, nome_func);
        strncpy(instr->arg2, args_buffer, sizeof(instr->arg2) - 1);
        instr->arg2[sizeof(instr->arg2) - 1] = '\0';
        
        adicionarInstrucao(lista, instr);
        return resultado_atual;
    }

    // 1. Inicialização Literal: [1, 2, 3] (Op '{')
    if (no->op == '{')
    {
        char args_buffer[MAX] = ""; 
        int pos = 0;
        if (no->esq) montarStringArgumentos(no->esq, lista, args_buffer, &pos);
        
        char *temp_dest = novoTemp(lista);
        snprintf(resultado_atual, MAX, "%s", temp_dest);
        
        adicionarInstrucao(lista, novaInstrucaoArrInit(temp_dest, args_buffer));
        return resultado_atual;
    }

    // 2. Acesso: v[i] (Op '[')
    if (no->op == '[') 
    {
        char *nome_vetor = no->esq->nome;
        char *idx_temp = gerarCodigoExpr(no->dir, lista);
        char idx_clean[MAX];
        
        if(idx_temp) SAFE_STRCPY(idx_clean, idx_temp);
        else strcpy(idx_clean, "0");

        char *temp_dest = novoTemp(lista);
        snprintf(resultado_atual, MAX, "%s", temp_dest);
        
        adicionarInstrucao(lista, novaInstrucaoArrGet(temp_dest, nome_vetor, idx_clean));
        return resultado_atual;
    }

    // Operação binária
    if (no->op && no->esq && no->dir)
    {
        char esq_temp[MAX];
        char *ptr_esq = gerarCodigoExpr(no->esq, lista);
        if (ptr_esq)
            SAFE_STRCPY(esq_temp, ptr_esq);
        else
            esq_temp[0] = '\0';

        char dir_temp[MAX];
        char *ptr_dir = gerarCodigoExpr(no->dir, lista);
        if (ptr_dir)
            SAFE_STRCPY(dir_temp, ptr_dir);
        else
            dir_temp[0] = '\0';

        char *temp_dest = novoTemp(lista);
        snprintf(resultado_atual, MAX, "%s", temp_dest);

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

        adicionarInstrucao(lista, novaInstrucaoBinop(temp_dest, esq_temp, op_char, dir_temp));
        return resultado_atual;
    }

    // Operação unária
    if (no->op && (no->dir || no->esq))
    {
        NoAST *target = no->dir ? no->dir : no->esq;

        char arg_temp[MAX];
        char *ptr_arg = gerarCodigoExpr(target, lista);
        if (ptr_arg)
            SAFE_STRCPY(arg_temp, ptr_arg);
        else
            arg_temp[0] = '\0';

        char *temp_dest = novoTemp(lista);
        snprintf(resultado_atual, MAX, "%s", temp_dest);

        adicionarInstrucao(lista, novaInstrucaoUnop(temp_dest, no->op, arg_temp));
        return resultado_atual;
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
            adicionarInstrucao(lista, novaInstrucaoAssign(raiz->nome, expr_temp));
        }
        return;
    }

    // IF (?)
    if (raiz->op == '?')
    {
        char cond_copia[MAX];
        char *cond_temp = gerarCodigoExpr(raiz->esq, lista);
        if (cond_temp)
            SAFE_STRCPY(cond_copia, cond_temp);
        else
            cond_copia[0] = '\0';

        int label_false = novoLabel(lista);

        // if_false cond goto L_FALSE
        adicionarInstrucao(lista, novaInstrucaoIfFalse(cond_copia, label_false));

        // Then
        gerarCodigoIntermediario(raiz->dir, lista);

        // L_FALSE:
        adicionarInstrucao(lista, novaInstrucaoLabel(label_false));
        return;
    }

    // IF-ELSE (:)
    if (raiz->op == ':' && raiz->esq && raiz->esq->op == '?')
    {
        NoAST *if_node = raiz->esq;

        char cond_copia[MAX];
        char *cond_temp = gerarCodigoExpr(if_node->esq, lista);
        if (cond_temp)
            SAFE_STRCPY(cond_copia, cond_temp);
        else
            cond_copia[0] = '\0';

        int label_else = novoLabel(lista);
        int label_end = novoLabel(lista);

        // if_false cond goto L_ELSE
        adicionarInstrucao(lista, novaInstrucaoIfFalse(cond_copia, label_else));

        // Then
        gerarCodigoIntermediario(if_node->dir, lista);

        // goto L_END
        adicionarInstrucao(lista, novaInstrucaoGoto(label_end));

        // L_ELSE:
        adicionarInstrucao(lista, novaInstrucaoLabel(label_else));

        // Else
        gerarCodigoIntermediario(raiz->dir, lista);

        // L_END:
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

            if (raiz->esq->dir)
            {
                processarParametros(raiz->esq->dir, lista);
            }

            // Gerar código do corpo da função
            gerarCodigoIntermediario(raiz->dir, lista);

            adicionarInstrucao(lista, novaInstrucaoFuncEnd(func_name));
        }
        return;
    }

    if (raiz->op == 'W')
    {
        int label_inicio = novoLabel(lista);
        int label_fim = novoLabel(lista);

        adicionarInstrucao(lista, novaInstrucaoLabel(label_inicio));

        char *cond_temp = gerarCodigoExpr(raiz->esq, lista);
        char cond_copia[MAX];
        
        if (cond_temp) 
            SAFE_STRCPY(cond_copia, cond_temp);
        else 
            strcpy(cond_copia, "0");

        adicionarInstrucao(lista, novaInstrucaoIfFalse(cond_copia, label_fim));
        gerarCodigoIntermediario(raiz->dir, lista);
        adicionarInstrucao(lista, novaInstrucaoGoto(label_inicio));
        adicionarInstrucao(lista, novaInstrucaoLabel(label_fim));
        return;
    }

    // Atribuição em Vetor (S)
    if(raiz->op == 'S')
    {
        NoAST *acesso = raiz->esq; // Nó '['
        NoAST *valor = raiz->dir;
        
        char *nome_vetor = acesso->esq->nome;
        char *idx = gerarCodigoExpr(acesso->dir, lista);
        char *val = gerarCodigoExpr(valor, lista);
        
        char idx_c[MAX], val_c[MAX];
        if(idx) 
            SAFE_STRCPY(idx_c, idx); 
        else 
            strcpy(idx_c, "0");

        if(val) 
            SAFE_STRCPY(val_c, val); 
        else 
            strcpy(val_c, "0");

        adicionarInstrucao(lista, novaInstrucaoArrSet(nome_vetor, idx_c, val_c));
        return;
    }

    // Return (R)
    if (raiz->op == 'R')
    {
        if (raiz->esq)
        {
            char *ret_temp = gerarCodigoExpr(raiz->esq, lista);
            char ret_copia[MAX];
            if (ret_temp)
                SAFE_STRCPY(ret_copia, ret_temp);
            else
                ret_copia[0] = '\0';

            adicionarInstrucao(lista, novaInstrucaoReturn(ret_copia));
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
            printf("    %s = %s\n", atual->resultado, atual->arg1);
            break;
        case INSTR_BINOP:
            printf("    %s = %s %c %s\n", atual->resultado, atual->arg1, atual->op, atual->arg2);
            break;
        case INSTR_UNOP:
            printf("    %s = %c %s\n", atual->resultado, atual->op, atual->arg1);
            break;
        case INSTR_LABEL:
            printf("L%d:\n", atual->label);
            break;
        case INSTR_GOTO:
            printf("    goto L%d\n", atual->label);
            break;
        case INSTR_ARR_INIT: 
            printf("    %s[] = {%s}\n", atual->resultado, atual->arg1); 
            break;
        case INSTR_ARR_GET:  
            printf("    %s = %s[%s]\n", atual->resultado, atual->arg1, atual->arg2); 
            break;
        case INSTR_ARR_SET:  
            printf("    %s[%s] = %s\n", atual->resultado, atual->arg1, atual->arg2); 
            break;
        case INSTR_IF_FALSE:
            printf("    if_false %s goto L%d\n", atual->arg1, atual->label);
            break;
        case INSTR_IF_TRUE:
            printf("    if_true %s goto L%d\n", atual->arg1, atual->label);
            break;
        case INSTR_RETURN:
            printf("    return %s\n", atual->arg1[0] ? atual->arg1 : "");
            break;
        case INSTR_PARAM:
            printf("    param %s\n", atual->arg1);
            break;
        case INSTR_CALL:
            printf("    %s = call %s\n", atual->resultado, atual->arg1);
            break;
        case INSTR_FUNC_BEGIN:
            printf("\nfunc_begin %s\n", atual->resultado);
            break;
        case INSTR_FUNC_END:
            printf("func_end %s\n", atual->resultado);
            break;
        case INSTR_PRINT:
            printf("    print %s\n", atual->arg1);
            break;
        case INSTR_SCAN:
            printf("    %s = call input\n", atual->resultado);
            break;
        default:
            printf("    (instrucao desconhecida)\n");
        }
        atual = atual->prox;
    }
    printf("==========================================\n");
}