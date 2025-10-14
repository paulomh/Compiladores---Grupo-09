# Sistema de Build - Compilador Python

## Makefile Completo

O projeto utiliza um Makefile profissional com múltiplos targets para facilitar o desenvolvimento e testes.

### Comandos Principais

```bash
# Compilar tudo
make all          # ou apenas 'make'

# Limpar arquivos gerados
make clean

# Executar compilador
make run

# Teste básico
make test

# Criar arquivo de exemplo
make example

# Executar com arquivo de exemplo
make run-example

# Mostrar ajuda
make help
```

## Targets Detalhados

### Build Targets

| Target | Descrição | Uso |
|--------|-----------|-----|
| `all` | Compila o compilador completo | `make all` |
| `clean` | Remove todos os arquivos gerados | `make clean` |
| `$(TARGET)` | Compila apenas o executável | `make compilador` |

### Arquivos Gerados

| Arquivo | Descrição | Gerado por |
|---------|-----------|------------|
| `lex.yy.c` | Código C do analisador léxico | `flex lexer/lexer.l` |
| `parser.tab.c` | Código C do analisador sintático | `bison parser/parser.y` |
| `parser.tab.h` | Header do parser | `bison -d parser/parser.y` |
| `parser.output` | Relatório de conflitos do Bison | `bison -v` |
| `*.o` | Arquivos objeto | `gcc -c` |
| `compilador` | Executável final | `gcc -o` |

### Test Targets

| Target | Descrição | Exemplo |
|--------|-----------|---------|
| `test` | Teste básico com pipe | `echo "x = 10 + 5" \| ./compilador` |
| `example` | Cria arquivo exemplo.txt | Arquivo com código Python |
| `run-example` | Executa com arquivo exemplo | `./compilador exemplo.txt` |

## Scripts Disponíveis

### `compilar.sh` - Compilação Automática

```bash
#!/bin/bash
echo "Compilando Compilador - Grupo 09"

# Limpeza
rm -f *.o compilador

# Compilação em etapas
flex lexer/lexer.l
bison -d -v -o parser.tab.c parser/parser.y
gcc -Wall -Wextra -std=c99 -c lex.yy.c -o lex.yy.o
gcc -Wall -Wextra -std=c99 -c parser.tab.c -o parser.tab.o  
gcc -Wall -Wextra -std=c99 -c src/main.c -o src/main.o
gcc -Wall -Wextra -std=c99 -o compilador lex.yy.o parser.tab.o src/main.o -lfl
```

### `testes.sh` - Suite de Testes

O script executa 8 categorias de testes:

1. **Operações Básicas**
2. **Precedência de Operadores**
3. **Números Negativos**
4. **Parênteses Complexos**
5. **Divisão**
6. **Expressões Longas**
7. **Casos Especiais**
8. **Expressões com Espaços**

## Processo de Compilação

### Etapa 1: Análise Léxica
```bash
flex lexer/lexer.l
# Gera: lex.yy.c (código C do analisador léxico)
```

### Etapa 2: Análise Sintática  
```bash
bison -d -v -o parser.tab.c parser/parser.y
# Gera: parser.tab.c (código C do parser)
# Gera: parser.tab.h (headers)
# Gera: parser.output (relatório)
```

### Etapa 3: Compilação dos Objetos
```bash
gcc -Wall -Wextra -std=c99 -c lex.yy.c -o lex.yy.o
gcc -Wall -Wextra -std=c99 -c parser.tab.c -o parser.tab.o
gcc -Wall -Wextra -std=c99 -c src/main.c -o src/main.o
```

### Etapa 4: Linkagem
```bash
gcc -Wall -Wextra -std=c99 -o compilador lex.yy.o parser.tab.o src/main.o -lfl
```

## Configurações do Makefile

### Variáveis

```makefile
CC = gcc                    # Compilador C
CFLAGS = -Wall -Wextra -std=c99  # Flags de compilação
LEX = flex                  # Gerador léxico
YACC = bison               # Gerador sintático
YFLAGS = -d -v             # Flags do Bison
TARGET = compilador        # Nome do executável
```

### Dependências

```makefile
# main.c depende do parser.tab.h
$(MAIN_SRC:.c=.o): $(PARSER_H)

# lexer depende do parser.tab.h  
$(LEXER_C:.c=.o): $(PARSER_H)

# Regra especial para main.o
src/main.o: src/main.c $(PARSER_H)
	$(CC) $(CFLAGS) -c $< -o $@
```

## Debug e Troubleshooting

### Verificar Conflitos do Parser

```bash
# Após compilar, verificar relatório
cat parser.output

# Procurar por conflitos
grep -i "conflict" parser.output
```

### Compilação com Debug

```bash
# Adicionar flags de debug
gcc -Wall -Wextra -std=c99 -g -DDEBUG -c src/main.c -o src/main.o
```

### Verbose Mode

```bash
# Makefile com verbose
make V=1

# Ver comandos executados
make --debug=basic
```

## Comandos de Desenvolvimento

### Desenvolvimento Rápido

```bash
# Ciclo completo: limpar, compilar, testar
make clean && make && make test

# Compilar e executar com arquivo
make && ./compilador teste.py

# Compilar e testar expressão
make && echo "3 + 4 * 2" | ./compilador
```

### Automação

```bash
# Script para desenvolvimento contínuo
#!/bin/bash
while true; do
    inotifywait -e modify lexer/lexer.l parser/parser.y src/main.c
    make clean && make && make test
done
```

## Estrutura de Build

```
build-artifacts/
├── lex.yy.c              # Gerado pelo Flex
├── lex.yy.o              # Objeto do lexer
├── parser.tab.c          # Gerado pelo Bison
├── parser.tab.h          # Headers do parser
├── parser.tab.o          # Objeto do parser
├── parser.output         # Relatório do Bison
├── src/main.o            # Objeto do main
└── compilador            # Executável final
```

---

<div align="center">
  <strong>Sistema de Build - Grupo 09</strong><br>
  <sub>Compilador Python - Compiladores 1 - UnB/2025.2</sub>
</div>
