# Makefile para o Compilador - Grupo 09

# Compiladores
CC = gcc
LEX = flex
YACC = bison

# Flags
CFLAGS = -Wall -Wextra -std=c99 -I.
LDFLAGS = -lfl

# Diretórios
SRC_DIR = src
PARSER_DIR = parser
LEXER_DIR = lexer

# Nome do executável
TARGET = compilador

# Arquivos fonte
LEXER_SRC = $(LEXER_DIR)/lexer.l
PARSER_SRC = $(PARSER_DIR)/parser.y
AST_SRC = $(SRC_DIR)/ast.c
AST_ATRIB_SRC = $(SRC_DIR)/ast_atrib.c
TABELA_SRC = $(SRC_DIR)/tabela.c
MAIN_SRC = $(SRC_DIR)/main.c

# Arquivos objeto
LEXER_OBJ = $(LEXER_DIR)/lex.yy.o
PARSER_OBJ = $(PARSER_DIR)/parser.tab.o
AST_OBJ = $(SRC_DIR)/ast.o
AST_ATRIB_OBJ = $(SRC_DIR)/ast_atrib.o
TABELA_OBJ = $(SRC_DIR)/tabela.o
MAIN_OBJ = $(SRC_DIR)/main.o

OBJS = $(LEXER_OBJ) $(PARSER_OBJ) $(AST_OBJ) $(TABELA_OBJ) $(MAIN_OBJ)

# Regras
all: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) $(OBJS) -o $@ $(LDFLAGS)

$(LEXER_DIR)/lex.yy.c: $(LEXER_SRC) $(PARSER_DIR)/parser.tab.h
	$(LEX) -o $@ $<

$(PARSER_DIR)/parser.tab.c $(PARSER_DIR)/parser.tab.h: $(PARSER_SRC)
	$(YACC) -d -o $(PARSER_DIR)/parser.tab.c $<

$(LEXER_OBJ): $(LEXER_DIR)/lex.yy.c
	$(CC) $(CFLAGS) -c $< -o $@

$(PARSER_OBJ): $(PARSER_DIR)/parser.tab.c
	$(CC) $(CFLAGS) -c $< -o $@

$(AST_OBJ): $(AST_SRC)
	$(CC) $(CFLAGS) -c $< -o $@

$(TABELA_OBJ): $(TABELA_SRC)
	$(CC) $(CFLAGS) -c $< -o $@

$(MAIN_OBJ): $(MAIN_SRC)
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(LEXER_DIR)/lex.yy.c
	rm -f $(PARSER_DIR)/parser.tab.c $(PARSER_DIR)/parser.tab.h
	rm -f $(OBJS)
	rm -f $(TARGET)
	rm -f parser.output

.PHONY: all clean