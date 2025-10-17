#ifndef AST_H
#define AST_H

typedef enum
{
    T_INT,
    T_FLOAT,
    T_FUNC,
    T_VOID,
    T_ERROR,
    T_ERRO,
    T_VAZIO
} Tipo;

typedef struct noAST
{
    char op;
    int val;
    char nome[255];
    Tipo tipo;
    int linha;  // Linha onde o nó foi criado
    struct noAST *esq;
    struct noAST *dir;
} NoAST;

NoAST *novoNoOp(char op, NoAST *esq, NoAST *dir);
NoAST *novoNoNum(int valor);
NoAST *novoNoId(char* nome, Tipo tipo);
NoAST *novoNoAtrib(char* id, NoAST* expr);
void imprimirAST(NoAST *no);
int tiposCompativeis(Tipo t1, Tipo t2);
const char* getTipoString(Tipo tipo);
Tipo verificarTipoRetorno(NoAST *no);

#endif