#ifndef AST_H
#define AST_H

typedef enum
{
    T_INT,
    T_FLOAT,
    T_STRING,
    T_ERRO,
    T_VOID,   // adicionado p/ funções sem retorno
    T_FUNC    // adicionado p/ identificar símbolos de função
} Tipo;

typedef struct noAST
{
    char op;
    int val;
    char nome[255];
    Tipo tipo;
    struct noAST *esq;
    struct noAST *dir;
} NoAST;

NoAST *novoNoOp(char op, NoAST *esq, NoAST *dir);
NoAST *novoNoNum(int val);
NoAST *novoNoStr(char *val);
NoAST *novoNoId(char *nome, Tipo tipo);
void imprimirAST(NoAST *no);
void imprimirAST_formatada(const NoAST *raiz); // Adicione esta linha
int tiposCompativeis(Tipo t1, Tipo t2);

// Novas APIs usadas no parser
NoAST *novoNoAtrib(char *nome, NoAST *expr);
const char *getTipoString(Tipo t);
Tipo verificarTipoRetorno(const NoAST *func_body);

#endif