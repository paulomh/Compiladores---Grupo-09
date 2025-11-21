#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include "codegen_c.h"

// Criar gerador de código C
CodeGenC* criarCodeGenC(const char *filename) {
    CodeGenC *codegen = malloc(sizeof(CodeGenC));
    if (!codegen) {
        perror("malloc");
        exit(1);
    }
    
    codegen->arquivo = fopen(filename, "w");
    if (!codegen->arquivo) {
        perror("Erro ao abrir arquivo para escrita");
        free(codegen);
        exit(1);
    }
    
    codegen->indent_level = 0;
    codegen->label_counter = 0;
    // Inicializar conjunto de nomes declarados
    codegen->declared_vars = malloc(sizeof(char*) * 16);
    if (!codegen->declared_vars) {
        perror("malloc");
        exit(1);
    }
    codegen->declared_count = 0;
    codegen->declared_size = 16;
    
    return codegen;
}

// Liberar gerador de código C
void liberarCodeGenC(CodeGenC *codegen) {
    if (!codegen) return;
    
    if (codegen->arquivo) {
        fclose(codegen->arquivo);
    }
    if (codegen->declared_vars) {
        for (int i = 0; i < codegen->declared_count; i++) free(codegen->declared_vars[i]);
        free(codegen->declared_vars);
    }
    free(codegen);
}

// Verificar se é um número
static int eh_numero(const char *str) {
    if (!str || !*str) return 0;
    if (*str == '-') str++;
    while (*str) {
        if (!isdigit(*str)) return 0;
        str++;
    }
    return 1;
}

// Limpar nome de variável (remover caracteres especiais)
static void limpar_nome_var(char *dest, const char *src, size_t max) {
    if (!src) return;
    
    int j = 0;
    for (int i = 0; src[i] && j < max - 1; i++) {
        if (isalnum(src[i]) || src[i] == '_') {
            dest[j++] = src[i];
        }
    }
    dest[j] = '\0';
}

// Helpers para controle de declaração de variáveis
static int is_declared(CodeGenC *codegen, const char *name) {
    if (!codegen || !name) return 0;
    for (int i = 0; i < codegen->declared_count; i++) {
        if (strcmp(codegen->declared_vars[i], name) == 0) return 1;
    }
    return 0;
}

static void add_declared(CodeGenC *codegen, const char *name) {
    if (!codegen || !name) return;
    if (codegen->declared_count >= codegen->declared_size) {
        int newsize = codegen->declared_size * 2;
        char **tmp = realloc(codegen->declared_vars, sizeof(char*) * newsize);
        if (!tmp) {
            perror("realloc");
            return;
        }
        codegen->declared_vars = tmp;
        codegen->declared_size = newsize;
    }
    codegen->declared_vars[codegen->declared_count++] = strdup(name);
}

// Gerar código C a partir do código intermediário
void gerarCodigoC(ListaInstrucoes *codigo_intermediario, CodeGenC *codegen) {
    if (!codigo_intermediario || !codegen || !codegen->arquivo) return;
    
    // Cabeçalho do arquivo C
    fprintf(codegen->arquivo, "#include <stdio.h>\n");
    fprintf(codegen->arquivo, "#include <stdlib.h>\n");
    fprintf(codegen->arquivo, "#include <math.h>\n\n");
    
    // Função main
    fprintf(codegen->arquivo, "int main() {\n");
    codegen->indent_level = 1;
    
    // Gerar instruções
    Instrucao *instr = codigo_intermediario->inicio;
    while (instr) {
        imprimirInstrucaoC(codigo_intermediario, instr, codegen);
        instr = instr->prox;
    }
    
    // Fecha função main
    codegen->indent_level = 0;
    fprintf(codegen->arquivo, "    return 0;\n");
    fprintf(codegen->arquivo, "}\n");
    
    printf("\n[INFO] Código C gerado em: %s\n", codegen->arquivo ? "arquivo" : "desconhecido");
}
