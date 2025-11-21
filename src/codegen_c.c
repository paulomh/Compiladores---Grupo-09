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

// Imprimir indentação
void imprimirIndentC(CodeGenC *codegen) {
    if (!codegen || !codegen->arquivo) return;
    
    for (int i = 0; i < codegen->indent_level; i++) {
        fprintf(codegen->arquivo, "    ");
    }
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

// Imprimir instrução em C
void imprimirInstrucaoC(ListaInstrucoes *lista, Instrucao *instr, CodeGenC *codegen) {
    if (!codegen || !codegen->arquivo || !instr) return;
    
    char var_temp[255];
    char arg1_clean[255];
    char arg2_clean[255];
    
    switch (instr->tipo) {
        case INSTR_ASSIGN: {
            // var = valor  ->  int var = valor;  (apenas na primeira vez)
            // Não sanitizar números; sanitizar identificadores
            const char *raw_result = instr->resultado;
            char result_clean[255];
            limpar_nome_var(result_clean, raw_result, sizeof(result_clean));

            // Preparar valor (preserva números negativos)
            if (eh_numero(instr->arg1)) {
                strncpy(arg1_clean, instr->arg1, sizeof(arg1_clean) - 1);
                arg1_clean[sizeof(arg1_clean) - 1] = '\0';
            } else {
                limpar_nome_var(arg1_clean, instr->arg1, sizeof(arg1_clean));
            }

            imprimirIndentC(codegen);
            if (!is_declared(codegen, result_clean)) {
                fprintf(codegen->arquivo, "int %s = %s;\n", result_clean, arg1_clean);
                add_declared(codegen, result_clean);
            } else {
                fprintf(codegen->arquivo, "%s = %s;\n", result_clean, arg1_clean);
            }
            break;
        }
            
        case INSTR_BINOP: {
            // resultado = arg1 op arg2
            // O operador já vem normalizado do intermediário
            const char *raw_result = instr->resultado;
            char result_clean[255];
            limpar_nome_var(result_clean, raw_result, sizeof(result_clean));

            // Preparar argumentos (preservar números)
            if (eh_numero(instr->arg1)) {
                strncpy(arg1_clean, instr->arg1, sizeof(arg1_clean) - 1);
                arg1_clean[sizeof(arg1_clean) - 1] = '\0';
            } else {
                limpar_nome_var(arg1_clean, instr->arg1, sizeof(arg1_clean));
            }
            if (eh_numero(instr->arg2)) {
                strncpy(arg2_clean, instr->arg2, sizeof(arg2_clean) - 1);
                arg2_clean[sizeof(arg2_clean) - 1] = '\0';
            } else {
                limpar_nome_var(arg2_clean, instr->arg2, sizeof(arg2_clean));
            }

            imprimirIndentC(codegen);
            
            // Tratamento especial para potência
            if (instr->op == 'P') {
                // Potência: usar pow() da math.h
                if (!is_declared(codegen, result_clean)) {
                    fprintf(codegen->arquivo, "int %s = (int)pow((double)%s, (double)%s);\n", 
                            result_clean, arg1_clean, arg2_clean);
                    add_declared(codegen, result_clean);
                } else {
                    fprintf(codegen->arquivo, "%s = (int)pow((double)%s, (double)%s);\n", 
                            result_clean, arg1_clean, arg2_clean);
                }
            } else {
                // Transcrever operador diretamente
                char op_str[10] = "";
                switch (instr->op) {
                    case '+': strcpy(op_str, "+"); break;
                    case '-': strcpy(op_str, "-"); break;
                    case '*': strcpy(op_str, "*"); break;
                    case '/': strcpy(op_str, "/"); break;
                    case '%': strcpy(op_str, "%"); break;
                    case 'E': strcpy(op_str, "=="); break;  // Igualdade
                    case 'D': strcpy(op_str, "!="); break;  // Diferença
                    case '<': strcpy(op_str, "<"); break;   // Menor que
                    case '>': strcpy(op_str, ">"); break;   // Maior que
                    case 'G': strcpy(op_str, ">="); break;  // Maior ou igual
                    case 'L': strcpy(op_str, "<="); break;  // Menor ou igual
                    case '&': strcpy(op_str, "&&"); break;  // AND lógico
                    case '|': strcpy(op_str, "||"); break;  // OR lógico
                    default: strcpy(op_str, "+"); break;    // Fallback seguro
                }
                if (!is_declared(codegen, result_clean)) {
                    fprintf(codegen->arquivo, "int %s = %s %s %s;\n", result_clean, arg1_clean, op_str, arg2_clean);
                    add_declared(codegen, result_clean);
                } else {
                    fprintf(codegen->arquivo, "%s = %s %s %s;\n", result_clean, arg1_clean, op_str, arg2_clean);
                }
            }
            break;
        }
            
        case INSTR_UNOP: {
            // resultado = op arg
            // Operadores unários: '-' (negação) e '!' (NOT lógico)
            const char *raw_result_un = instr->resultado;
            char result_un_clean[255];
            limpar_nome_var(result_un_clean, raw_result_un, sizeof(result_un_clean));

            // Preparar argumento (preservar número se for literal)
            if (eh_numero(instr->arg1)) {
                strncpy(arg1_clean, instr->arg1, sizeof(arg1_clean) - 1);
                arg1_clean[sizeof(arg1_clean) - 1] = '\0';
            } else {
                limpar_nome_var(arg1_clean, instr->arg1, sizeof(arg1_clean));
            }

            imprimirIndentC(codegen);
            if (instr->op == '-') {
                if (!is_declared(codegen, result_un_clean)) {
                    fprintf(codegen->arquivo, "int %s = -%s;\n", result_un_clean, arg1_clean);
                    add_declared(codegen, result_un_clean);
                } else {
                    fprintf(codegen->arquivo, "%s = -%s;\n", result_un_clean, arg1_clean);
                }
            } else if (instr->op == '!') {
                if (!is_declared(codegen, result_un_clean)) {
                    fprintf(codegen->arquivo, "int %s = !%s;\n", result_un_clean, arg1_clean);
                    add_declared(codegen, result_un_clean);
                } else {
                    fprintf(codegen->arquivo, "%s = !%s;\n", result_un_clean, arg1_clean);
                }
            }
            break;
        }
            
        case INSTR_LABEL:
            // Label - sem indentação
            fprintf(codegen->arquivo, "L%d:\n", instr->label);
            break;
            
        case INSTR_GOTO:
            // Salto incondicional
            imprimirIndentC(codegen);
            fprintf(codegen->arquivo, "goto L%d;\n", instr->label);
            break;
            
        case INSTR_IF_FALSE: {
            // if_false cond goto L  ->  if (!cond) goto L;
            if (eh_numero(instr->arg1)) {
                strncpy(arg1_clean, instr->arg1, sizeof(arg1_clean) - 1);
                arg1_clean[sizeof(arg1_clean) - 1] = '\0';
            } else {
                limpar_nome_var(arg1_clean, instr->arg1, sizeof(arg1_clean));
            }
            imprimirIndentC(codegen);
            fprintf(codegen->arquivo, "if (!%s) goto L%d;\n", arg1_clean, instr->label);
            break;
        }
            
        case INSTR_IF_TRUE: {
            // if_true cond goto L  ->  if (cond) goto L;
            if (eh_numero(instr->arg1)) {
                strncpy(arg1_clean, instr->arg1, sizeof(arg1_clean) - 1);
                arg1_clean[sizeof(arg1_clean) - 1] = '\0';
            } else {
                limpar_nome_var(arg1_clean, instr->arg1, sizeof(arg1_clean));
            }
            imprimirIndentC(codegen);
            fprintf(codegen->arquivo, "if (%s) goto L%d;\n", arg1_clean, instr->label);
            break;
        }
            
        case INSTR_RETURN: {
            // return valor;
            imprimirIndentC(codegen);
            if (instr->arg1[0] != '\0') {
                if (eh_numero(instr->arg1)) {
                    strncpy(arg1_clean, instr->arg1, sizeof(arg1_clean) - 1);
                    arg1_clean[sizeof(arg1_clean) - 1] = '\0';
                } else {
                    limpar_nome_var(arg1_clean, instr->arg1, sizeof(arg1_clean));
                }
                fprintf(codegen->arquivo, "return %s;\n", arg1_clean);
            } else {
                fprintf(codegen->arquivo, "return 0;\n");
            }
            break;
        }
            
        case INSTR_FUNC_BEGIN: {
            // Início de função
            char func_clean[255];
            limpar_nome_var(func_clean, instr->resultado, sizeof(func_clean));
            fprintf(codegen->arquivo, "\nvoid %s() {\n", func_clean);
            codegen->indent_level++;
            break;
        }
            
        case INSTR_FUNC_END:
            // Fim de função
            codegen->indent_level--;
            fprintf(codegen->arquivo, "}\n");
            break;
            
        default:
            break;
    }
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
