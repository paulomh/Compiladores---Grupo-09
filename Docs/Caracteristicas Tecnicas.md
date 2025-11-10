# Especificações Técnicas do Compilador Python

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

### Scripts de Teste

- `tests/run_all_tests.sh`: Executa a suíte completa de testes.
- `tests/scripts/testes.sh`: Script auxiliar com baterias de testes.
- `tests/scripts/test_symbol_table.sh`: Testes focados em tabela de símbolos.
- Consulte também `tests/README.md` para instruções e detalhes dos cenários de teste.

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
# Entrada interativa
./compilador

# Com arquivo
./compilador tests/files/04_expressions_only.py

# Pipe
echo "3 + 4 * 2" | ./compilador
```

### Testes

```bash
# Todos os testes
chmod +x tests/run_all_tests.sh
./tests/run_all_tests.sh

# Teste específico
chmod +x tests/scripts/testes.sh
./tests/scripts/testes.sh
make test
```

---

<div align="center">
  <strong>Especificações Técnicas - Grupo 09</strong><br>
  <sub>Compilador Python - Compiladores 1 - UnB/2025.2</sub>
</div>