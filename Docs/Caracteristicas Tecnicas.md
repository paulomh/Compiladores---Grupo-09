# Especificações Técnicas do Compilador Python

## Sumário

- [Visão Geral](#visão-geral)
- [Arquitetura Implementada](#arquitetura-implementada)
- [Estrutura Real do Projeto](#estrutura-real-do-projeto)
- [Sistema de Build](#sistema-de-build)
  - [Makefile](#makefile)
  - [Comandos Disponíveis](#comandos-disponíveis)
- [Sistema de Testes](#sistema-de-testes)
  - [Organização de Testes](#organização-de-testes)
  - [Scripts de Teste Disponíveis](#scripts-de-teste-disponíveis)
  - [Arquivos de Teste](#arquivos-de-teste)
- [Como Usar](#como-usar)
  - [Compilação](#compilação)
  - [Execução](#execução)
  - [Testes](#testes)
  - [Ciclo Completo de Desenvolvimento](#ciclo-completo-de-desenvolvimento)

---

## Visão Geral

Este documento descreve as especificações técnicas do compilador Python desenvolvido pelo **Grupo 09** para a disciplina de Compiladores 1. O compilador implementa um subconjunto funcional da linguagem Python com foco em expressões aritméticas, estruturas de controle e gerenciamento de indentação.

## Arquitetura Implementada

```
┌─────────────────────────────────────────────────────────────────────┐
│                    COMPILADOR PYTHON - GRUPO 09                     │
├─────────────────────────────────────────────────────────────────────┤
│    Código Python (.py) → Tokens → AST → Avaliação → Resultado       │
└─────────────────────────────────────────────────────────────────────┘

┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│   ANÁLISE    │  │   ANÁLISE    │  │   AVALIAÇÃO  │
│    LÉXICA    │→ │   SINTÁTICA  │→ │      DE      │
│    (Flex)    │  │   (Bison)    │  │  EXPRESSÕES  │
└──────────────┘  └──────────────┘  └──────────────┘
```

## Estrutura Real do Projeto

```
./
├── Docs/                       # Documentação do projeto
│   ├── Caracteristicas Tecnicas.md
│   ├── Configuracao Ambiente.md
│   ├── Definicoes Projeto.md
│   └── Guia - Projeto de um compilador.md
├── lexer/
│   └── lexer.l                 # Analisador léxico (Flex)
├── parser/
│   └── parser.y                # Analisador sintático (Bison)
├── src/
│   ├── ast.c                   # Árvore sintática (implementação)
│   ├── ast.h                   # Árvore sintática (header)
│   ├── tabela.c                # Tabela de símbolos (implementação)
│   ├── tabela.h                # Tabela de símbolos (header)
│   └── main.c                  # Programa principal
├── tests/
│   ├── files/                  # Casos de teste
│   ├── scripts/                # Scripts auxiliares de teste
│   └── run_all_tests.sh        # Runner de testes
├── Makefile                    # Sistema de build
├── compilar.sh                 # Script de compilação
└── README.md                   # Visão geral do projeto
```

## Sistema de Build

### Makefile

```makefile
CC = gcc
CFLAGS = -Wall -Wextra -std=c99
LEX = flex
YACC = bison
YFLAGS = -d -v

TARGET = compilador
LEXER_SRC = lexer/lexer.l
PARSER_SRC = parser/parser.y
MAIN_SRC = src/main.c
```

### Comandos Disponíveis

```bash
make all          # Compilar tudo
make clean        # Limpar arquivos gerados  
make run          # Executar compilador
make test         # Teste básico
make example      # Criar arquivo de exemplo
make run-example  # Executar com exemplo
make help         # Mostrar ajuda
```

## Sistema de Testes

### Organização de Testes

A suíte de testes é organizada em **6 categorias funcionais** com um total de **48 testes**:

| Categoria | Testes | Descrição |
|-----------|--------|-----------|
| AST | 10 | Construção e validação da árvore sintática |
| Condicionais | 3 | Estruturas `if/else` |
| Erros | 4 | Detecção de erros com indicação de linha |
| Gerais | 11 | Funcionalidades básicas do compilador |
| Símbolos | 10 | Gerenciamento da tabela de símbolos |
| Integração | 10 | Integração AST + Tabela de Símbolos |

### Scripts de Teste Disponíveis

```
tests/scripts/
├── test_category_all.sh              # Master script (executa todas as categorias)
├── test_category_ast.sh              # Testes de AST
├── test_category_conditional.sh      # Testes de condicionais
├── test_category_error.sh            # Testes de erros
├── test_category_general.sh          # Testes gerais
├── test_category_symbol.sh           # Testes de símbolos
└── test_category_integration.sh      # Testes de integração
```

### Arquivos de Teste

45 arquivos de teste localizados em `tests/files/`:
- 10 arquivos para AST (`ast_*.py`)
- 3 arquivos para condicionais (`conditional_*.py`)
- 4 arquivos para erros (`error_*.py`)
- 10 arquivos para símbolos (`symbol_*.py`)
- 10 arquivos para integração (`integration_*.py`)
- 8 arquivos gerais (atribuições, comentários, expressões, funções, indentação, etc.)

## Como Usar

### Compilação

```bash
# Método 1: Make (Recomendado)
make clean && make

# Método 2: Script
chmod +x compilar.sh
./compilar.sh
```

### Execução

```bash
# Com arquivo
./compilador tests/files/ast_binop.py

# Pipe
echo "x = 10 + 5" | ./compilador
```

### Testes

```bash
# Todos os testes (suíte completa)
make clean && make && bash tests/scripts/test_category_all.sh

# Teste de categoria específica
bash tests/scripts/test_category_ast.sh
bash tests/scripts/test_category_symbol.sh
bash tests/scripts/test_category_integration.sh

# Teste individual
./compilador tests/files/ast_binop.py
```

### Ciclo Completo de Desenvolvimento

```bash
# Compilar, limpar e testar tudo
make clean && make && bash tests/scripts/test_category_all.sh

# Saída esperada (sucesso):
# [OK] AST: SUCESSO
# [OK] CONDICIONAIS: SUCESSO
# [OK] ERROS: SUCESSO
# [OK] GERAIS: SUCESSO
# [OK] SÍMBOLOS: SUCESSO
# [OK] INTEGRAÇÃO: SUCESSO
# Resultado: Todos os testes passaram com sucesso.
```

**Para documentação completa dos testes**, consulte `Docs/Testes.md`.

---

<div align="center">
  <strong>Especificações Técnicas - Grupo 09</strong><br>
  <sub>Compilador Python - Compiladores 1 - UnB/2025.2</sub>
</div>