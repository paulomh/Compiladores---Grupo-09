# Sistema de Build - Compilador Python

## Sumário

- [Makefile Completo](#makefile-completo)
  - [Comandos Principais](#comandos-principais)
  - [Targets Detalhados](#targets-detalhados)
  - [Arquivos Gerados](#arquivos-gerados)
- [Scripts Disponíveis](#scripts-disponíveis)
  - [`compilar.sh` - Compilação Automática](#compilarsh---compilação-automática)
  - [Scripts de Teste](#scripts-de-teste)
- [Processo de Compilação](#processo-de-compilação)
  - [Etapa 1: Análise Léxica](#etapa-1-análise-léxica)
  - [Etapa 2: Análise Sintática](#etapa-2-análise-sintática)
  - [Etapa 3: Compilação dos Objetos](#etapa-3-compilação-dos-objetos)
  - [Etapa 4: Linkagem](#etapa-4-linkagem)
- [Configurações do Makefile](#configurações-do-makefile)
  - [Variáveis](#variáveis)
  - [Dependências](#dependências)
- [Debug e Troubleshooting](#debug-e-troubleshooting)
  - [Verificar Conflitos do Parser](#verificar-conflitos-do-parser)
  - [Compilação com Debug](#compilação-com-debug)
  - [Verbose Mode](#verbose-mode)
- [Comandos de Desenvolvimento](#comandos-de-desenvolvimento)
  - [Desenvolvimento Rápido](#desenvolvimento-rápido)
  - [Automação](#automação)
- [Estrutura de Build](#estrutura-de-build)

---

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

# Executar suíte completa de testes (48 testes em 7 categorias)
make test-all

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
| `clean` | Remove todos os arquivos gerados, incluindo testes | `make clean` |
| `test` | Executa teste básico com entrada padrão | `make test` |
| `test-all` | Executa suíte completa (48 testes, 7 categorias) | `make test-all` |
| `run` | Executa o compilador | `make run` |
| `example` | Cria arquivo de exemplo Python | `make example` |
| `run-example` | Compila e executa com exemplo | `make run-example` |
| `help` | Mostra ajuda de comandos | `make help` |
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

**Nota:** O target `clean` remove todos esses arquivos, incluindo as pastas de testes (`tests/c/` e `tests/bitcode/`).

## Scripts Disponíveis

### `compilar.sh` - Compilação Automática

O projeto utiliza **Makefile** para compilação automática. O script `compilar.sh` é legado e não é mais necessário.

**Para compilar, use simplesmente:**
```bash
make
```

**Isto executa automaticamente:**
1. Flex para gerar `lex.yy.c`
2. Bison para gerar `parser.tab.c` e `parser.tab.h`
3. Compila todos os arquivos: `src/ast.c`, `src/tabela.c`, `src/gerador.c`, `src/codegen_c.c`, `src/main.c`
4. Linka todos os objetos com `-lfl`

### Scripts de Teste

O projeto possui uma suíte completa de testes organizada em 7 categorias com 48 testes no total.

**Localização:** `tests/scripts/`

**Scripts Disponíveis:**
- `test_category_all.sh` - Executa todos os testes de todas as categorias
- `test_category_ast.sh` - Testes de construção da AST (10 testes)
- `test_category_conditional.sh` - Testes de estruturas condicionais (3 testes)
- `test_category_error.sh` - Testes de detecção de erros (4 testes)
- `test_category_general.sh` - Testes gerais e básicos (11 testes)
- `test_category_symbol.sh` - Testes de tabela de símbolos (10 testes)
- `test_category_integration.sh` - Testes de integração AST + Símbolos (10 testes)
- `test_category_codegen.sh` - Testes de geração de código 

**Executar testes:**
```bash
# Todos os testes
bash tests/scripts/test_category_all.sh

# Teste específico
bash tests/scripts/test_category_ast.sh
```

**Consulte** `Docs/Testes.md` para documentação completa do sistema de testes.



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
gcc -Wall -Wextra -std=gnu99 -c lex.yy.c -o lex.yy.o
gcc -Wall -Wextra -std=gnu99 -c parser.tab.c -o parser.tab.o
gcc -Wall -Wextra -std=gnu99 -c src/main.c -o src/main.o
gcc -Wall -Wextra -std=gnu99 -c src/ast.c -o src/ast.o
gcc -Wall -Wextra -std=gnu99 -c src/tabela.c -o src/tabela.o
gcc -Wall -Wextra -std=gnu99 -c src/gerador.c -o src/gerador.o
gcc -Wall -Wextra -std=gnu99 -c src/codegen_c.c -o src/codegen_c.o
```

### Etapa 4: Linkagem
```bash
gcc -Wall -Wextra -std=gnu99 -o compilador lex.yy.o parser.tab.o src/main.o src/ast.o src/tabela.o src/gerador.o src/codegen_c.o -lfl
```

## Configurações do Makefile

### Variáveis

```makefile
CC = gcc                           # Compilador C
CFLAGS = -Wall -Wextra -std=gnu99  # Flags de compilação
LEX = flex                         # Gerador léxico
YACC = bison                       # Gerador sintático
YFLAGS = -d -v                     # Flags do Bison
TARGET = compilador                # Nome do executável

# Objetos compilados
OBJECTS = lex.yy.o parser.tab.o src/main.o src/ast.o src/tabela.o src/gerador.o src/codegen_c.o
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
# Compilar tudo
make clean && make

# Compilar e testar (suíte completa)
make clean && make && make test-all

# Apenas recompilar e testar
make && make test-all

# Testar categoria específica
make && bash tests/scripts/test_category_ast.sh

# Compilar e executar teste individual
make && ./compilador tests/files/ast_binop.py
```

### Executando Suíte de Testes

O comando `make test-all` executa a suíte completa de testes:

```bash
# Opção 1: Compilar e testar (recomendado para desenvolvimento)
make clean && make && make test-all

# Opção 2: Apenas testar (sem recompilar)
make test-all

# Opção 3: Teste individual (sem compilar)
./compilador tests/files/ast_binop.py
```

**Categorias testadas:**
- AST (10 testes)
- Condicionais (3 testes)
- Erros (4 testes)
- Gerais (11 testes)
- Símbolos (10 testes)
- Integração (10 testes)
- Geração de Código (48 testes: Bitcode + C)

### Automação

```bash
# Script para desenvolvimento contínuo com testes
#!/bin/bash
while true; do
    inotifywait -e modify lexer/lexer.l parser/parser.y src/main.c
    make clean && make && bash tests/scripts/test_category_all.sh
done
```

### Ciclo Completo

```bash
# Limpar, compilar, todos os testes
make clean && make && make test-all

# Se tudo passou, você verá:
# [OK] AST: SUCESSO
# [OK] CONDICIONAIS: SUCESSO
# [OK] ERROS: SUCESSO
# [OK] GERAIS: SUCESSO
# [OK] SÍMBOLOS: SUCESSO
# [OK] INTEGRAÇÃO: SUCESSO
# [OK] GERAÇÃO DE CÓDIGO: SUCESSO
# Resultado: Todos os testes passaram com sucesso.
```

**No Windows (PowerShell com WSL):**

```powershell
wsl -d Ubuntu bash -lc 'cd "/mnt/c/caminho/do/projeto" && make clean && make && make test-all'
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
