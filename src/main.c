#include <stdio.h>
#include <stdlib.h>
#include "ast.h"
#include "tabela.h"
#include "../parser.tab.h"

extern int yyparse();
extern FILE* yyin;
extern void init_compiler();

int main(int argc, char* argv[]) {
    printf("=== Compilador - Grupo 09 ===\n");
    //printf("Analisador de Expressões Aritméticas\n\n");
    
    // Inicializar compilador
    //init_compiler();
    //yyparse();
    
    if (argc > 1) {
        // Abrir arquivo de entrada se fornecido
        yyin = fopen(argv[1], "r");
        if (!yyin) {
            printf("Erro: Não foi possível abrir o arquivo '%s'\n", argv[1]);
            return 1;
        }
        printf("Analisando arquivo: %s\n\n", argv[1]);
    }
    
    // Executar análise sintática
    init_compiler();
    int result = yyparse();
    
    if (result == 0) {
        printf("\nAnálise concluída com sucesso!\n");
    } else {
        printf("\nErro na análise sintática!\n");
    }

    
    if (yyin != stdin) {
        fclose(yyin);
    }
    
    return result;
}
