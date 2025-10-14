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
compilador-grupo09/
├── lexer/
│   └── lexer.l                 # Analisador léxico (Flex)
├── parser/
│   └── parser.y                # Analisador sintático (Bison)
├── src/
│   └── main.c                  # Programa principal
├── Makefile                    # Sistema de build
├── compilar.sh                 # Script de compilação
├── testes.sh                   # Script de testes
├── teste.py                    # Arquivo de teste Python
└── README.md                   # Documentação
```

## Linguagem-Fonte: Subconjunto Python

### Características Implementadas

O compilador suporta um **subconjunto de Python** com as seguintes características:

#### **Tokens Implementados**

| Categoria | Token | Regex/Definição | Exemplo |
|-----------|-------|-----------------|---------|
| **Números Inteiros** | `INT` | `[-\+]?[0-9]+` | `123`, `-45`, `+10` |
| **Números Reais** | `FLOAT` | `[-\+]?[0-9]+\.[0-9]+` | `3.14`, `-2.5` |
| **Identificadores** | `IDENTIFIER` | `[a-zA-Z_][a-zA-Z0-9_]*` | `variavel`, `_temp` |
| **Strings** | `STRING` | `"[^"]*"\|'[^']*'` | `"hello"`, `'world'` |

#### **Operadores Implementados**

| Tipo | Operadores | Tokens | Exemplo |
|------|------------|--------|---------|
| **Aritméticos** | `+`, `-`, `*`, `/`, `%`, `**`, `//` | `PLUS`, `MINUS`, `TIMES`, `DIVIDE`, `MODULE`, `EXPONENTIAL`, `INTDIVIDE` | `5 + 3`, `2 ** 3` |
| **Relacionais** | `==`, `!=`, `>=`, `<=`, `>`, `<` | `EQUALS`, `DIFFROM`, `GTOREQUAL`, `LSOREQUAL`, `GREATER`, `LESS` | `x == 5`, `y > 10` |
| **Lógicos** | `and`, `or`, `not` | `AND`, `OR`, `NOT` | `a and b`, `not flag` |
| **Atribuição** | `=`, `+=`, `-=`, `*=`, `/=`, `%=` | `ASSIGNMENT`, `INCREMENT`, `DECREMENT`, `INCTIMES`, `DIVBY`, `MODBY` | `x = 5`, `y += 10` |

#### **Palavras-Chave Implementadas**

```python
# Estruturas de Controle
if, else, while, for

# Operadores Lógicos
and, or, not, is, in

# Definição de Funções
def, return

# Outros
pass
```

#### **Delimitadores e Estruturas**

| Token | Símbolo | Uso |
|-------|---------|-----|
| `LPAREN` | `(` | Parênteses esquerdo |
| `RPAREN` | `)` | Parênteses direito |
| `COLON` | `:` | Dois pontos (estruturas de controle) |
| `COMMA` | `,` | Vírgula (separador) |
| `INDENT` | - | Aumento de indentação |
| `DEDENT` | - | Diminuição de indentação |
| `NEWLINE` | `\n` | Nova linha |

#### **Comentários Suportados**

```python
# Comentário de linha única
"""
Comentário de
múltiplas linhas
"""
'''
Comentário alternativo
de múltiplas linhas
'''
```

## Análise Léxica Implementada

### Arquivo: `lexer/lexer.l`

#### Estados do Analisador

- **INITIAL**: Estado padrão para reconhecimento de tokens
- **INDENT_STATE**: Estado especial para processamento de indentação Python

#### Funcionalidades Especiais

1. **Gerenciamento de Indentação**
   ```c
   typedef struct stack {
       int indent[MAX];
       int indent_top;
   } stack;
   ```
   - Stack para controle de níveis de indentação
   - Geração automática de tokens `INDENT` e `DEDENT`
   - Validação de indentação consistente

2. **Contagem de Linhas**
   ```c
   int newline_count = 0; // Contador global de "enters"
   ```

3. **Tratamento de EOF**
   - Geração automática de `DEDENT` no final do arquivo
   - Fechamento correto de todos os níveis de indentação

### Exemplos de Reconhecimento

```python
# Entrada Python
if 10 > 5:
    x = 42
    print(x)

# Tokens gerados
IF INT(10) GREATER INT(5) COLON NEWLINE
INDENT IDENTIFIER(x) ASSIGNMENT INT(42) NEWLINE
IDENTIFIER(print) LPAREN IDENTIFIER(x) RPAREN NEWLINE
DEDENT
```

## Análise Sintática Implementada

### Arquivo: `parser/parser.y`

#### Gramática Implementada

```yacc
program:
    /* vazio */
    | statement_list

statement_list:
    statement
    | statement_list statement

statement:
    NEWLINE
    | simple_statement NEWLINE
    | compound_statement

simple_statement:
    expr
    | return_statement
    | assignment_statement

compound_statement:
    if_statement
    | function_definition

suite:
    NEWLINE INDENT statement_list DEDENT

if_statement:
    IF expr COLON suite
    | IF expr COLON suite ELSE COLON suite

function_definition:
    DEF IDENTIFIER LPAREN parameter_list RPAREN COLON suite

expr:
    expr OR expr
    | expr AND expr
    | NOT expr
    | expr EQUALS expr
    | expr GREATER expr
    | expr PLUS expr
    | expr MINUS expr
    | expr TIMES expr
    | expr DIVIDE expr
    | LPAREN expr RPAREN
    | INT
    | FLOAT
    | IDENTIFIER
    | MINUS expr %prec UMINUS
```

#### Precedência de Operadores

```yacc
%left OR                    // Menor precedência
%left AND
%left NOT
%left EQUALS DIFFROM GTOREQUAL LSOREQUAL GREATER LESS
%left PLUS MINUS
%left TIMES DIVIDE MODULE INTDIVIDE
%right EXPONENTIAL
%right UMINUS               // Maior precedência
```

#### Ações Semânticas

```c
expr: expr PLUS expr    { $$ = $1 + $3; }
    | expr MINUS expr   { $$ = $1 - $3; }
    | expr TIMES expr   { $$ = $1 * $3; }
    | expr DIVIDE expr  { $$ = $3 != 0 ? $1 / $3 : 0; }
    | INT               { $$ = $1; }
    | LPAREN expr RPAREN { $$ = $2; }
```

## Funcionalidades Implementadas

### 1. Avaliação de Expressões Aritméticas

```python
# Suportado
3 + 4 * 2          # Resultado: 11
(3 + 4) * 2        # Resultado: 14
-5 + 3             # Resultado: -2
2 ** 3             # Resultado: 8 (implementado com loop)
10 // 3            # Resultado: 3
```

### 2. Estruturas de Controle

```python
# Suportado
if x > 5:
    print("maior")
else:
    print("menor")
```

### 3. Definição de Funções

```python
# Suportado
def minha_funcao(param1, param2):
    return param1 + param2
```

### 4. Operadores Lógicos

```python
# Suportado
True and False     # Resultado: False
not True          # Resultado: False
x > 5 or y < 10   # Avaliação lógica
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

### Script: `testes.sh`

O projeto inclui **testes automatizados** organizados em categorias:

1. **Operações Básicas**
   ```bash
   echo "3 + 4" | ./compilador    # Resultado: 7
   echo "7 - 2" | ./compilador    # Resultado: 5
   echo "5 * 6" | ./compilador    # Resultado: 30
   echo "8 / 2" | ./compilador    # Resultado: 4
   ```

2. **Precedência de Operadores** 
   ```bash
   echo "2 + 3 * 4" | ./compilador      # Resultado: 14
   echo "(2 + 3) * 4" | ./compilador    # Resultado: 20
   ```

3. **Números Negativos**
   ```bash
   echo "-5" | ./compilador             # Resultado: -5
   echo "-3 + 7" | ./compilador         # Resultado: 4
   ```

4. **Parênteses Complexos** 
5. **Divisão e Casos Especiais** 
6. **Expressões Longas** 
7. **Casos Especiais** 
8. **Expressões com Espaços** 

### Arquivo de Teste: `teste.py`

```python
if 10 > 5:
    40 + 2
    if 1 == 1:
        1000
    else: 
        2000
else:
    50 - 5
```

## Limitações Atuais

### Funcionalidades Não Implementadas

- **Análise Semântica**: Verificação de tipos, tabela de símbolos
- **Geração de Código**: Código intermediário ou final
- **Variáveis**: Armazenamento e recuperação de valores
- **Funções**: Chamadas e execução real
- **Loops**: `while`, `for` (apenas parsing)
- **Listas e Estruturas**: Arrays, dicionários
- **Imports**: Módulos e bibliotecas
- **Classes**: Orientação a objetos

## Status do Desenvolvimento

### Implementado 
- [x] Analisador léxico 
- [x] Analisador sintático funcional
- [x] Avaliação de expressões aritméticas
- [x] Suporte à indentação Python
- [x] Sistema de build (Makefile)
- [x] Scripts de compilação e teste
- [x] Documentação 

### Em Desenvolvimento 
- [ ] Análise semântica básica
- [ ] Tabela de símbolos
- [ ] Verificação de tipos simples

### Planejado 
- [ ] Geração de código intermediário
- [ ] Suporte a variáveis
- [ ] Execução de funções
- [ ] Otimizações básicas

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
./compilador teste.py

# Pipe
echo "3 + 4 * 2" | ./compilador
```

### Testes

```bash
# Todos os testes
chmod +x testes.sh
./testes.sh

# Teste específico
make test
```


---

<div align="center">
  <strong>Especificações Técnicas - Grupo 09</strong><br>
  <sub>Compilador Python - Compiladores 1 - UnB/2025.2</sub>
</div>