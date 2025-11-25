#ifndef GERADOR_H
#define GERADOR_H

#include "ast.h"

// Tipos de instrução de três endereços
typedef enum {
    INSTR_ASSIGN,       // x = y
    INSTR_COPY,         // x = y
    INSTR_BINOP,        // x = y op z
    INSTR_UNOP,         // x = op y
    INSTR_LABEL,        // L:
    INSTR_GOTO,         // goto L
    INSTR_IF_FALSE,     // if_false x goto L
    INSTR_IF_TRUE,      // if_true x goto L
    INSTR_PARAM,        // param x
    INSTR_CALL,         // x = call f, n
    INSTR_RETURN,       // return x
    INSTR_FUNC_BEGIN,   // func_begin f
    INSTR_FUNC_END,      // func_end f
    INSTR_PRINT, // print x
    INSTR_SCAN // x = call input
} TipoInstrucao;

// Instrução de três endereços
typedef struct instrucao {
    TipoInstrucao tipo;
    char resultado[255];    // destino
    char arg1[255];         // primeiro operando
    char arg2[255];         // segundo operando
    char op;                // operador (para BINOP/UNOP)
    int label;              // número do label (para LABEL, GOTO, IF)
    struct instrucao *prox;
} Instrucao;

// Lista de instruções
typedef struct {
    Instrucao *inicio;
    Instrucao *fim;
    int contador_temp;      // contador para variáveis temporárias
    int contador_label;     // contador para labels
} ListaInstrucoes;

// Funções principais
ListaInstrucoes* criarListaInstrucoes();
void liberarListaInstrucoes(ListaInstrucoes *lista);
void gerarCodigoIntermediario(NoAST *raiz, ListaInstrucoes *lista);
void imprimirCodigoIntermediario(ListaInstrucoes *lista);

// Funções auxiliares para criar instruções
void adicionarInstrucao(ListaInstrucoes *lista, Instrucao *instr);
Instrucao* novaInstrucaoAssign(const char *dest, const char *fonte);
Instrucao* novaInstrucaoBinop(const char *dest, const char *arg1, char op, const char *arg2);
Instrucao* novaInstrucaoUnop(const char *dest, char op, const char *arg);
Instrucao* novaInstrucaoLabel(int label);
Instrucao* novaInstrucaoGoto(int label);
Instrucao* novaInstrucaoIfFalse(const char *cond, int label);
Instrucao* novaInstrucaoIfTrue(const char *cond, int label);
Instrucao* novaInstrucaoReturn(const char *valor);
Instrucao* novaInstrucaoFuncBegin(const char *nome);
Instrucao* novaInstrucaoFuncEnd(const char *nome);
Instrucao *novaInstrucaoParam(const char *nome);

// Geração de nomes temporários e labels
char* novoTemp(ListaInstrucoes *lista);
int novoLabel(ListaInstrucoes *lista);

#endif
