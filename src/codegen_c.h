#ifndef CODEGEN_C_H
#define CODEGEN_C_H

#include "gerador.h"
#include <stdio.h>

// Estrutura para gerenciar geração de código C
typedef struct {
    char *filename;
    FILE *arquivo;
    int indent_level;
    int label_counter;
    // Controle de nomes já declarados para evitar redeclarações
    char **declared_vars;
    int declared_count;
    int declared_size;
    char **ptr_vars;
    int ptr_count;
    int ptr_size;
    char **str_vars;
    int str_count;
    int str_size;
} CodeGenC;

// Funções principais
CodeGenC* criarCodeGenC(const char *filename);
void liberarCodeGenC(CodeGenC *codegen);
void gerarCodigoC(ListaInstrucoes *codigo_intermediario, CodeGenC *codegen);

// Funções auxiliares
void imprimirIndentC(CodeGenC *codegen);
void imprimirInstrucaoC(Instrucao *instr, CodeGenC *codegen);

#endif
