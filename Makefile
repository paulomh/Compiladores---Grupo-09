# Makefile para o Compilador - Grupo 09
# Compilador usando Flex e Bison

CC = gcc
CFLAGS = -Wall -Wextra -std=gnu99
LEX = flex
YACC = bison
YFLAGS = -d -v

# Nome do executável
TARGET = compilador

# Arquivos fonte
LEXER_SRC = lexer/lexer.l
PARSER_SRC = parser/parser.y
MAIN_SRC = src/main.c
AST_SRC = src/ast.c
TABELA_SRC = src/tabela.c
GERADOR_SRC = src/gerador.c
CODEGEN_C_SRC = src/codegen_c.c

# Arquivos gerados
LEXER_C = lex.yy.c
PARSER_C = parser.tab.c
PARSER_H = parser.tab.h

# Objetos
OBJECTS = $(LEXER_C:.c=.o) $(PARSER_C:.c=.o) $(MAIN_SRC:.c=.o) $(AST_SRC:.c=.o) $(TABELA_SRC:.c=.o) $(GERADOR_SRC:.c=.o) $(CODEGEN_C_SRC:.c=.o)

# Regra principal
all: $(TARGET)

# Compilar o executável
$(TARGET): $(OBJECTS)
	$(CC) $(CFLAGS) -o $(TARGET) $(OBJECTS) -lfl
	@echo "✅ Compilador compilado com sucesso!"

# Gerar arquivo C do lexer (depende do header do parser)
$(LEXER_C): $(LEXER_SRC) $(PARSER_H)
	$(LEX) $(LEXER_SRC)

# Gerar arquivos C e H do parser
$(PARSER_C) $(PARSER_H): $(PARSER_SRC)
	$(YACC) $(YFLAGS) -o parser.tab.c $(PARSER_SRC)

# Compilar objetos
%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

# Limpar arquivos gerados
clean:
	@rm -f $(LEXER_C) $(PARSER_C) $(PARSER_H) *.o src/*.o $(TARGET) test_ast
	@rm -f parser.output
	@rm -rf tests/c tests/bitcode
	@echo "🧹 Arquivos de compilação removidos"

# Executar o compilador
run: $(TARGET)
	./$(TARGET)

# Testar com arquivo de exemplo
test: $(TARGET)
	@echo "Testando com entrada padrão..."
	@echo "x = 10 + 5" | ./$(TARGET)

# Criar arquivo de exemplo
example:
	@echo "x = 10 + 5" > exemplo.txt
	@echo "y = x * 2" >> exemplo.txt
	@echo "if x > 5:" >> exemplo.txt
	@echo "    print(x)" >> exemplo.txt
	@echo "Arquivo de exemplo criado: exemplo.txt"

# Executar com arquivo de exemplo
run-example: $(TARGET) example
	./$(TARGET) exemplo.txt

# Mostrar ajuda
help:
	@echo "Comandos disponíveis:"
	@echo "  make          - Compilar o compilador"
	@echo "  make clean    - Limpar arquivos gerados"
	@echo "  make run      - Executar o compilador"
	@echo "  make test     - Testar com entrada padrão"
	@echo "  make example  - Criar arquivo de exemplo"
	@echo "  make run-example - Executar com arquivo de exemplo"
	@echo "  make help     - Mostrar esta ajuda"

# Dependências
$(MAIN_SRC:.c=.o): $(PARSER_H) src/ast.h src/tabela.h src/gerador.h src/codegen_c.h
$(LEXER_C:.c=.o): $(PARSER_H)
$(AST_SRC:.c=.o): src/ast.h
$(TABELA_SRC:.c=.o): src/tabela.h
$(GERADOR_SRC:.c=.o): src/gerador.h src/ast.h
$(CODEGEN_C_SRC:.c=.o): src/codegen_c.h src/gerador.h

# Forçar recompilação do main.c após parser.tab.h e headers
src/main.o: src/main.c $(PARSER_H) src/ast.h src/tabela.h src/gerador.h src/codegen_c.h
	$(CC) $(CFLAGS) -c $< -o $@

# Compilar ast.c
src/ast.o: src/ast.c src/ast.h
	$(CC) $(CFLAGS) -c $< -o $@

# Compilar tabela.c
src/tabela.o: src/tabela.c src/tabela.h
	$(CC) $(CFLAGS) -c $< -o $@

# Compilar gerador.c
src/gerador.o: src/gerador.c src/gerador.h src/ast.h
	$(CC) $(CFLAGS) -c $< -o $@

# Compilar codegen_c.c
src/codegen_c.o: src/codegen_c.c src/codegen_c.h src/gerador.h
	$(CC) $(CFLAGS) -c $< -o $@

# === Teste isolado da AST ===
test_ast: src/test_ast.c src/ast.c src/ast.h
	$(CC) $(CFLAGS) -o test_ast src/test_ast.c src/ast.c

run_test_ast: test_ast
	./test_ast

.PHONY: all clean run test example run-example help test_ast run_test_ast