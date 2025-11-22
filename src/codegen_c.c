#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include "codegen_c.h"

// Criar gerador de código C
CodeGenC* criarCodeGenC(const char *filename) {
    CodeGenC *codegen = malloc(sizeof(CodeGenC));
    if (!codegen)
        exit(1);
    
    codegen->arquivo = fopen(filename, "w");
    if (!codegen->arquivo) {
        perror("Erro ao abrir arquivo para escrita");
        free(codegen);
        exit(1);
    }
    
    codegen->indent_level = 0;
    codegen->label_counter = 0;
    codegen->declared_vars = malloc(sizeof(char*) * 16);
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

static void reiniciarDeclaracoes(CodeGenC *codegen) {
    for(int i = 0; i < codegen->declared_count; i++)
        free(codegen->declared_vars[i]);
    
    codegen->declared_count = 0;
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
    if (is_declared(codegen, name)) return;

    if (codegen->declared_count >= codegen->declared_size) {
        int newsize = codegen->declared_size * 2;
        char **tmp = realloc(codegen->declared_vars, sizeof(char*) * newsize);
        if (!tmp) return;
        codegen->declared_vars = tmp;
        codegen->declared_size = newsize;
    }
    codegen->declared_vars[codegen->declared_count++] = strdup(name);
}

// Imprimir instrução em C
void imprimirInstrucaoC(Instrucao *instr, CodeGenC *codegen) {
    if (!codegen || !instr) return;
    
    char var_temp[255], arg1_clean[255], arg2_clean[255];
    
    switch (instr->tipo) {
        case INSTR_PARAM:
            break;

        case INSTR_ASSIGN: {
            // var = valor  ->  int var = valor;  (apenas na primeira vez)
            // Não sanitizar números; sanitizar identificadores
            const char *raw_result = instr->resultado;
            char result_clean[255];
            limpar_nome_var(result_clean, raw_result, sizeof(result_clean));

            // Preparar valor (preserva números negativos)
            if (eh_numero(instr->arg1)) {
                strcpy(arg1_clean, instr->arg1);
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
            if (eh_numero(instr->arg1)) strcpy(arg1_clean, instr->arg1);
            else limpar_nome_var(arg1_clean, instr->arg1, sizeof(arg1_clean));
            
            if (eh_numero(instr->arg2)) strcpy(arg2_clean, instr->arg2);
            else limpar_nome_var(arg2_clean, instr->arg2, sizeof(arg2_clean));

            imprimirIndentC(codegen);

            char op_str[10] = "";
            
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
                return;
            }
            
            switch (instr->op) {
                case '+': strcpy(op_str, "+"); break;
                case '-': strcpy(op_str, "-"); break;
                case '*': strcpy(op_str, "*"); break;
                case '/': strcpy(op_str, "/"); break;
                case '%': strcpy(op_str, "%"); break;
                case 'E': strcpy(op_str, "=="); break;
                case 'D': strcpy(op_str, "!="); break;
                case '<': strcpy(op_str, "<"); break;
                case '>': strcpy(op_str, ">"); break;
                case 'G': strcpy(op_str, ">="); break;
                case 'L': strcpy(op_str, "<="); break;
                case '&': strcpy(op_str, "&&"); break;
                case '|': strcpy(op_str, "||"); break;
                default: strcpy(op_str, "+"); break;
            }

            if (!is_declared(codegen, result_clean)) {
                fprintf(codegen->arquivo, "int %s = %s %s %s;\n", result_clean, arg1_clean, op_str, arg2_clean);
                add_declared(codegen, result_clean);
            } else {
                fprintf(codegen->arquivo, "%s = %s %s %s;\n", result_clean, arg1_clean, op_str, arg2_clean);
            }
            break;
        }
            
        case INSTR_UNOP: {
            // resultado = op arg
            // Operadores unários: '-' (negação) e '!' (NOT lógico)
            char result_un_clean[255];
            limpar_nome_var(result_un_clean, instr->resultado, sizeof(result_un_clean));

            if (eh_numero(instr->arg1)) strcpy(arg1_clean, instr->arg1);
            else limpar_nome_var(arg1_clean, instr->arg1, sizeof(arg1_clean));

            imprimirIndentC(codegen);
            char op = (instr->op == '!') ? '!' : '-';
            
            if (!is_declared(codegen, result_un_clean)) {
                fprintf(codegen->arquivo, "int %s = %c%s;\n", result_un_clean, op, arg1_clean);
                add_declared(codegen, result_un_clean);
            } else {
                fprintf(codegen->arquivo, "%s = %c%s;\n", result_un_clean, op, arg1_clean);
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
            
        case INSTR_IF_FALSE:
            // if_false cond goto L  ->  if (!cond) goto L;
            if (eh_numero(instr->arg1))
                strcpy(arg1_clean, instr->arg1);
            else
                limpar_nome_var(arg1_clean, instr->arg1, sizeof(arg1_clean));

            imprimirIndentC(codegen);
            fprintf(codegen->arquivo, "if (!%s) goto L%d;\n", arg1_clean, instr->label);
            break;
            
        case INSTR_IF_TRUE:
            // if_true cond goto L  ->  if (cond) goto L;
            if (eh_numero(instr->arg1))
                strcpy(arg1_clean, instr->arg1);
            else
                limpar_nome_var(arg1_clean, instr->arg1, sizeof(arg1_clean));

            imprimirIndentC(codegen);
            fprintf(codegen->arquivo, "if (%s) goto L%d;\n", arg1_clean, instr->label);
            break;
            
        case INSTR_RETURN:
            // return valor;
            imprimirIndentC(codegen);
            if (instr->arg1[0] != '\0') {
                if (eh_numero(instr->arg1)) strcpy(arg1_clean, instr->arg1);
                else limpar_nome_var(arg1_clean, instr->arg1, sizeof(arg1_clean));
                fprintf(codegen->arquivo, "return %s;\n", arg1_clean);
            } else {
                fprintf(codegen->arquivo, "return 0;\n");
            }
            break;
            
        case INSTR_FUNC_BEGIN:
        case INSTR_FUNC_END:
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

    Instrucao *atual = codigo_intermediario->inicio;

    // Funções fora da main
    while(atual) {
        if (atual->tipo == INSTR_FUNC_BEGIN) {
            reiniciarDeclaracoes(codegen);

            char func_name[255];
            limpar_nome_var(func_name, atual->resultado, sizeof(func_name));
            
            // Lookahead para pegar parâmetros
            fprintf(codegen->arquivo, "int %s(", func_name);
            
            Instrucao *param = atual->prox;
            int first_param = 1;
            while (param && param->tipo == INSTR_PARAM) {
                if (!first_param) fprintf(codegen->arquivo, ", ");
                
                char param_clean[255];
                limpar_nome_var(param_clean, param->arg1, sizeof(param_clean));
                
                fprintf(codegen->arquivo, "int %s", param_clean);
                add_declared(codegen, param_clean); // Registra que parâmetro já existe
                
                first_param = 0;
                param = param->prox;
            }
            fprintf(codegen->arquivo, ") {\n");
            codegen->indent_level = 1;
            
            // Gera o corpo da função
            atual = param; // 'param' parou na primeira instrução que NÃO é PARAM
            
            while (atual && atual->tipo != INSTR_FUNC_END) {
                if (atual->tipo != INSTR_FUNC_BEGIN) {
                    imprimirInstrucaoC(atual, codegen);
                }
                atual = atual->prox;
            }
            
            fprintf(codegen->arquivo, "}\n\n");
            codegen->indent_level = 0;
        }
        
        if (atual) atual = atual->prox;
    }
    
    // Função main
    reiniciarDeclaracoes(codegen);
    fprintf(codegen->arquivo, "int main() {\n");
    codegen->indent_level = 1;

    atual = codigo_intermediario->inicio;
    int dentro_funcao = 0;
    
    while (atual) {
        if (atual->tipo == INSTR_FUNC_BEGIN) {
            dentro_funcao = 1;
        }
        
        if (atual->tipo == INSTR_FUNC_END) {
            dentro_funcao = 0;
            atual = atual->prox;
            continue;
        }

        if (!dentro_funcao) {
            imprimirInstrucaoC(atual, codegen);
        }
        
        atual = atual->prox;
    }
    
    // Fecha função main
    fprintf(codegen->arquivo, "    return 0;\n");
    fprintf(codegen->arquivo, "}\n");
    
    printf("\n[INFO] Código C gerado em: %s\n", codegen->arquivo ? "arquivo" : "desconhecido");
}
