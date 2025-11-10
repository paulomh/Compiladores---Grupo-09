# Definições do Projeto - Compilador Python Grupo 09

## Sumário

- [Fluxo de Compilação](#fluxo-de-compilação)
- [Funcionalidades Implementadas](#funcionalidades-implementadas)
  - [Análise Léxica Avançada](#análise-léxica-avançada)
  - [Gerenciamento de Indentação](#gerenciamento-de-indentação)
  - [Análise Sintática com AST](#análise-sintática-com-ast)
  - [Tabela de Símbolos e Escopo](#tabela-de-símbolos-e-escopo)
- [Especificações Técnicas Implementadas](#especificações-técnicas-implementadas)
  - [ETAPA 1: ANÁLISE LÉXICA](#etapa-1-análise-léxica)
  - [ETAPA 2: DEFINIÇÃO DE TOKENS](#etapa-2-definição-de-tokens)
  - [ETAPA 3: ANÁLISE SINTÁTICA](#etapa-3-análise-sintática)
  - [ETAPA 4: AVALIAÇÃO DE EXPRESSÕES](#etapa-4-avaliação-de-expressões)
  - [ETAPA 5: CONSTRUÇÃO DA AST](#etapa-5-construção-da-ast)
  - [ETAPA 6: INICIALIZAÇÃO E EXECUÇÃO](#etapa-6-inicialização-e-execução)
  - [ETAPA 7: SISTEMA DE BUILD](#etapa-7-sistema-de-build)
  - [ETAPA 8: TRATAMENTO DE ERROS](#etapa-8-tratamento-de-erros)
- [Exemplos de Uso](#exemplos-de-uso)

---

## Fluxo de Compilação

```
Arquivo .py
    ↓
[LEXER - lexer.l]
  ├─ Tokenização
  ├─ Detecção de Indentação
  └─ Geração de INDENT/DEDENT
    ↓
Token Stream
    ↓
[PARSER - parser.y]
  ├─ Parsing Sintático
  ├─ Construção de AST
  └─ Verificação Semântica
    ↓
[AST - ast.c / tabela.c]
  ├─ Árvore Sintática
  ├─ Tabela de Símbolos
  └─ Informações de Tipo
    ↓
[OUTPUT]
  ├─ Sucesso: AST impressa
  └─ Erro: Mensagem e linha
```

## Funcionalidades Implementadas

### Análise Léxica Avançada
- **Números**: Suporta inteiros e floats com sinais opcionais
- **Strings**: Detecta strings com aspas simples ou duplas
- **Comentários**: Remove comentários simples (`#`) e compostos (`"""` ou `'''`)
- **Identificadores**: Valida identificadores Python com `_` e números
- **Operadores**: 28+ operadores incluindo comparação (`==`, `!=`), atribuição (`+=`, `-=`) e potência (`**`)
- **Palavras-chave**: 10 palavras-chave Python (`if`, `else`, `def`, `return`, `while`, `for`, `and`, `or`, `not`, `is`, `in`, `pass`)

### Gerenciamento de Indentação
- **Pilha de Indentação**: Estrutura `stack` com máximo de 100 níveis
- **Tokens INDENT/DEDENT**: Gera corretamente com `dedent_line` para múltiplos DEDENTs
- **Estados Flex**: Usa `INDENT_STATE` após newlines para análise específica
- **Validação**: Detecta erros de indentação inconsistente
- **EOF Handling**: Insere `DEDENT`s automaticamente no fim do arquivo

### Análise Sintática com AST
- **Árvore Sintática**: Construção completa de AST via funções em `ast.c`
- **Suporte a Estruturas**: `if`/`else`, funções (`def`), parâmetros, retorno
- **Expressões Complexas**: Precedência correta de operadores (16 níveis)
- **Verificação de Tipos**: Sistema de 7 tipos (`T_INT`, `T_FLOAT`, `T_STRING`, `T_FUNC`, `T_VOID`, `T_ERRO`, etc.)

### Tabela de Símbolos e Escopo
- **Tabela Global**: Registra variáveis e funções
- **Funções**: Armazena nome, tipo de retorno e parâmetros
- **Parâmetros**: Suporta parâmetros com valores padrão
- **Escopo**: Função `finalizarEscopo()` fecha escopo após definição
- **Verificação Semântica**: Detecta variáveis não declaradas

## Especificações Técnicas Implementadas

Esta tabela define todas as regras de funcionamento implementadas no compilador, organizadas pelo fluxo de compilação.

### ETAPA 1: ANÁLISE LÉXICA (lexer/lexer.l)

#### 1.1 Estrutura de Dados - Pilha de Indentação
| Local | Regra de Funcionamento | Demostração |
|-------|----------------------------------|----------------------------|
| `lexer/lexer.l:23-60` | Pilha para níveis de indentação | `stack` com `indent[MAX]` e `indent_top` |
| `lexer/lexer.l:41-45` | Empilhar novo nível | `stack_push(s, level)` quando indentação aumenta |
| `lexer/lexer.l:47-52` | Desempilhar nível | `stack_pop(s)` quando indentação diminui |
| `lexer/lexer.l:67-75` | Mecanismo de geração de DEDENTs | `dedent_line` contador em `yylex()` → Retorna `DEDENT` por linha |

#### 1.2 Reconhecimento de Tokens - Literais
| Local | Regra de Funcionamento | Demostração |
|-------|----------------------------------|----------------------------|
| `lexer/lexer.l:82` | Números inteiros com sinal opcional | `123`, `-45`, `+10` → Token `INT` |
| `lexer/lexer.l:83` | Números decimais com sinal opcional | `3.14`, `-2.5`, `+1.0` → Token `FLOAT` |
| `lexer/lexer.l:84` | Strings com aspas simples ou duplas | `"hello"`, `'world'` → Token `STRING` |
| `lexer/lexer.l:86-100` | Identificadores válidos Python | `variavel`, `_temp`, `func1` → Token `IDENTIFIER` |

#### 1.3 Reconhecimento de Tokens - Palavras-chave e Comentários
| Local | Regra de Funcionamento | Demostração |
|-------|----------------------------------|----------------------------|
| `lexer/lexer.l:73` | Comentários de linha única | `# Este é um comentário` → Ignorado |
| `lexer/lexer.l:74-75` | Comentários de bloco múltiplas linhas | `"""comentário"""`, `'''comentário'''` → Ignorado |
| `lexer/lexer.l:86-100` | Palavras-chave Python: `if`, `else`, `while`, `for`, `and`, `or`, `not`, `def`, `return`, `pass`, `is`, `in` | `if`, `else`, `while`, `for` → Tokens `IF`, `ELSE`, `WHILE`, `FOR` |

#### 1.4 Reconhecimento de Tokens - Operadores
| Local | Regra de Funcionamento | Demostração |
|-------|----------------------------------|----------------------------|
| `lexer/lexer.l:108-118` | Operadores duplos: comparação e assignment | `==`, `!=`, `>=`, `<=`, `**`, `//`, `+=`, `-=`, `*=`, `/=`, `%=` → Tokens específicos |
| `lexer/lexer.l:120-135` | Operadores simples e delimitadores | `+`, `-`, `*`, `/`, `%`, `>`, `<`, `(`, `)`, `:`, `,` → Tokens específicos |

#### 1.5 Detecção de Indentação - Mudança de Estado
| Local | Regra de Funcionamento | Demostração |
|-------|----------------------------------|----------------------------|
| `lexer/lexer.l:137` | Espaços em branco ignorados | `[ \t\r]+` → Ignorado completamente |
| `lexer/lexer.l:139` | Detecção de nova linha com mudança de estado | `\n` → Token `NEWLINE` + ativa estado `INDENT_STATE` |

#### 1.6 Cálculo de Indentação em INDENT_STATE
| Local | Regra de Funcionamento | Demostração |
|-------|----------------------------------|----------------------------|
| `lexer/lexer.l:145-163` | Contagem de espaços/tabs em BEGIN(INDENT_STATE) | `    código` (espaços) → Calcula nível via `strlen(yytext)` |
| `lexer/lexer.l:145` | Lookahead para não-newline | `[ \t]+/[^\n]` → Evita consumir linha vazia |
| `lexer/lexer.l:147` | Cálculo do nível atual | `int actual_level = strlen(yytext)` |
| `lexer/lexer.l:148` | Comparação com nível anterior | `int previous_level = stack_peek(s)` |

#### 1.7 Processamento de Indentação - Aumento
| Local | Regra de Funcionamento | Demostração |
|-------|----------------------------------|----------------------------|
| `lexer/lexer.l:147-152` | Aumento de indentação | `actual_level > previous_level` → Token `INDENT` + empilha nível |

#### 1.8 Processamento de Indentação - Diminuição
| Local | Regra de Funcionamento | Demostração |
|-------|----------------------------------|----------------------------|
| `lexer/lexer.l:154-160` | Diminuição de indentação | `actual_level < previous_level` → Incrementa `dedent_line` + desempilha |
| `lexer/lexer.l:156-158` | Validação de indentação | Erro se nível não coincide com pilha: `IndentationError` |

#### 1.9 Processamento de Indentação - Casos Especiais
| Local | Regra de Funcionamento | Demostração |
|-------|----------------------------------|----------------------------|
| `lexer/lexer.l:165-167` | Linhas em branco | `[ \t]*\n` no `INDENT_STATE` → Apenas `NEWLINE` |
| `lexer/lexer.l:169-183` | Volta ao nível 0 sem espaços | `.` com `yyless(0)` → Desempilha tudo se nível > 0 |
| `lexer/lexer.l:197-215` | Tratamento de fim de arquivo | `<<EOF>>` → Gera `DEDENT`s para todos níveis restantes via `dedent_line` |

### ETAPA 2: DEFINIÇÃO DE TOKENS (parser/parser.y - Cabeçalho)

#### 2.1 Sistema de Tipos Semânticos
| Local | Regra de Funcionamento | Demostração |
|-------|----------------------------------|----------------------------|
| `parser/parser.y:29-33` | Union de tipos semânticos | `int intValue`, `float floatValue`, `char* strValue`, `NoAST* no`, `Tipo tipo` |
| `parser/parser.y:36-38` | Tokens com valor semântico inteiro | `%token <intValue> INT` → Armazena valor numérico |
| `parser/parser.y:39` | Tokens com valor semântico float | `%token <floatValue> FLOAT` → Armazena ponto flutuante |
| `parser/parser.y:40` | Tokens com valor semântico string | `%token <strValue> IDENTIFIER`, `STRING` → Armazena identificador |

#### 2.2 Declaração de Tokens
| Local | Regra de Funcionamento | Demostração |
|-------|----------------------------------|----------------------------|
| `parser/parser.y:43-46` | Palavras-chave reservadas sem valor | `IF`, `ELSE`, `WHILE`, `FOR`, `DEF`, `RETDEF` → Tokens simples |
| `parser/parser.y:49-53` | Tokens de indentação | `INDENT`, `DEDENT`, `NEWLINE`, `END_OF_FILE` |

#### 2.3 Precedência de Operadores
| Local | Regra de Funcionamento | Demostração |
|-------|----------------------------------|----------------------------|
| `parser/parser.y:59-68` | Precedência crescente: OR → AND → NOT → Relacionais → Aritméticos → UMINUS | `%left OR` (menor) → `%right UMINUS` (maior) |

### ETAPA 3: ANÁLISE SINTÁTICA (parser/parser.y - Regras)

#### 3.1 Estrutura de Programa
| Local | Regra de Funcionamento | Demostração |
|-------|----------------------------------|----------------------------|
| `parser/parser.y:72-75` | Programa principal | `program: /* vazio */ | statement_list | statement_list END_OF_FILE` |
| `parser/parser.y:77-79` | Lista de statements | `statement_list: statement | statement_list statement` → Sequência via `;` |

#### 3.2 Tipos de Statements
| Local | Regra de Funcionamento | Demostração |
|-------|----------------------------------|----------------------------|
| `parser/parser.y:81-84` | Tipos de statement | `NEWLINE`, `simple_statement NEWLINE`, `compound_statement` |
| `parser/parser.y:86-88` | Statements simples | `expr`, `return_statement`, `assignment_statement` |
| `parser/parser.y:94-96` | Statements compostos | `if_statement`, `function_definition` |

#### 3.3 Suite (Bloco Indentado)
| Local | Regra de Funcionamento | Demostração |
|-------|----------------------------------|----------------------------|
| `parser/parser.y:99-101` | Suite (bloco indentado) | `NEWLINE INDENT statement_list DEDENT` → Agrupa nó com `;` |

#### 3.4 Atribuição com Verificação de Tipo
| Local | Regra de Funcionamento | Demostração |
|-------|----------------------------------|----------------------------|
| `parser/parser.y:90-92` | Atribuição de variável com verificação de tipo | `IDENTIFIER ASSIGNMENT expr` → Busca/insere símbolo com tipo |

#### 3.5 Estruturas de Controle
| Local | Regra de Funcionamento | Demostração |
|-------|----------------------------------|----------------------------|
| `parser/parser.y:103-111` | Estrutura if/else com árvore AST | `IF expr COLON suite [ELSE COLON suite]` → Cria nós `?` e `:` |

#### 3.6 Definição de Função
| Local | Regra de Funcionamento | Demostração |
|-------|----------------------------------|----------------------------|
| `parser/parser.y:113-126` | Definição de função com escopo e tabela de símbolos | `DEF IDENTIFIER LPAREN parameter_list RPAREN COLON suite` → Insere símbolo função |
| `parser/parser.y:128-136` | Parâmetros com valores padrão | `parameter: IDENTIFIER | IDENTIFIER ASSIGNMENT expr` → Registra parâmetro |

### ETAPA 4: AVALIAÇÃO DE EXPRESSÕES (parser/parser.y - Regras de expr)

#### 4.1 Operadores Lógicos
| Local | Regra de Funcionamento | Demostração |
|-------|----------------------------------|----------------------------|
| `parser/parser.y:149` | Operador lógico OR | `expr OR expr` → `novoNoOp('|', $1, $3)` → Nó AST com `|` |
| `parser/parser.y:150` | Operador lógico AND | `expr AND expr` → `novoNoOp('&', $1, $3)` → Nó AST com `&` |
| `parser/parser.y:151` | Operador lógico NOT | `NOT expr` → `novoNoOp('!', $2, NULL)` → Nó AST com `!` |

#### 4.2 Operadores Relacionais
| Local | Regra de Funcionamento | Demostração |
|-------|----------------------------------|----------------------------|
| `parser/parser.y:152-157` | Operadores relacionais com nó AST | `==`, `!=`, `>`, `<`, `>=`, `<=` → Nós `e`, `d`, `>`, `<`, `g`, `l` |

#### 4.3 Operadores Aritméticos
| Local | Regra de Funcionamento | Demostração |
|-------|----------------------------------|----------------------------|
| `parser/parser.y:158-164` | Operadores aritméticos com verificação de tipo | `+`, `-`, `*`, `/`, `%`, `**`, `//` → Nós AST com operadores |

#### 4.4 Agrupamento e Literais
| Local | Regra de Funcionamento | Demostração |
|-------|----------------------------------|----------------------------|
| `parser/parser.y:165` | Parênteses para agrupamento | `LPAREN expr RPAREN` → `$$ = $2` (sem nó) |
| `parser/parser.y:166` | Literal inteiro | `INT` → `novoNoNum($1)` → Nó AST com valor inteiro |
| `parser/parser.y:167` | Literal float | `FLOAT` → `novoNoNum((int)$1)` → Conversão para int |

#### 4.5 Identificadores e Funções
| Local | Regra de Funcionamento | Demostração |
|-------|----------------------------------|----------------------------|
| `parser/parser.y:168-172` | Identificador com busca de símbolo | `IDENTIFIER` → `buscarSimbolo($1)` → Retorna tipo ou erro |
| `parser/parser.y:173` | Menos unário | `MINUS expr %prec UMINUS` → `novoNoOp('-', novoNoNum(0), $2)` |
| `parser/parser.y:174` | Chamada de função | `IDENTIFIER LPAREN argument_list RPAREN` → `novoNoOp('C', novoNoId($1), $3)` |

### ETAPA 5: CONSTRUÇÃO DA AST (src/ast.c e src/tabela.c)

#### 5.1 Nós da Árvore Sintática
| Local | Regra de Funcionamento | Demostração |
|-------|----------------------------------|----------------------------|
| `src/ast.c` | Criação de nós AST | Funções `novoNoOp()`, `novoNoNum()`, `novoNoId()`, `novoNoAtrib()` |
| `src/tabela.c` | Gerenciamento de tabela de símbolos | `inserirSimbolo()`, `buscarSimbolo()`, `finalizarEscopo()` |

### ETAPA 6: INICIALIZAÇÃO E EXECUÇÃO (src/main.c e parser/parser.y)

#### 6.1 Inicialização
| Local | Regra de Funcionamento | Demostração |
|-------|----------------------------------|----------------------------|
| `src/main.c:17-25` | Modo de entrada por arquivo | `argc > 1` → `yyin = fopen(argv[1], "r")` |
| `src/main.c:28` | Inicialização do compilador | `init_compiler()` → Inicializa pilha de indentação |
| `src/main.c:177` | Função de inicialização | `void init_compiler()` → Setup do compilador |
| `src/main.c:182-186` | Inicialização da pilha | `s = stack_init()` + mensagem de boas-vindas |

#### 6.2 Execução e Saída
| Local | Regra de Funcionamento | Demostração |
|-------|----------------------------------|----------------------------|
| `src/main.c:29` | Execução da análise | `yyparse()` → Retorna 0 se sucesso |
| `parser/parser.y:84-87` | Ação ao sucesso de parsing | `imprimirAST($$)` → Imprime árvore AST |

### ETAPA 7: SISTEMA DE BUILD

#### 7.1 Makefile
| Local | Regra de Funcionamento | Demostração |
|-------|----------------------------------|----------------------------|
| `Makefile:4-8` | Variáveis de compilação | `CC = gcc`, `CFLAGS = -Wall -Wextra -std=c99` |
| `Makefile:27` | Target principal | `all: $(TARGET)` → Compila tudo |
| `Makefile:30-32` | Compilação do executável | `$(CC) $(CFLAGS) -o $(TARGET) $(OBJECTS) -lfl` |
| `Makefile:35-36` | Geração do lexer | `$(LEX) $(LEXER_SRC)` → `lex.yy.c` |
| `Makefile:39-40` | Geração do parser | `$(YACC) $(YFLAGS) -o parser.tab.c $(PARSER_SRC)` |
| `Makefile:47-50` | Limpeza de arquivos | `rm -f $(LEXER_C) $(PARSER_C) $(PARSER_H) *.o $(TARGET)` |

#### 7.2 Scripts de Automação
| Local | Regra de Funcionamento | Demostração |
|-------|----------------------------------|----------------------------|
| `compilar.sh:8` | Limpeza antes compilação | `rm -f *.o compilador` |
| `compilar.sh:12` | Geração do lexer | `flex lexer/lexer.l` |
| `compilar.sh:15` | Geração do parser | `bison -d -v -o parser.tab.c parser/parser.y` |
| `compilar.sh:18-20` | Compilação de objetos | `gcc -c` para cada arquivo `.c` |
| `compilar.sh:23` | Linkagem final | `gcc -o compilador *.o -lfl` |

### ETAPA 8: TRATAMENTO DE ERROS

#### 8.1 Erros Detectados
| Local | Regra de Funcionamento | Demostração |
|-------|----------------------------------|----------------------------|
| `lexer/lexer.l:154-156` | Erro de indentação | `IndentationError: unindent does not match any outer indentation level` |
| `lexer/lexer.l:200` | Caractere inválido | `printf("Caractere invalido: %s\n", yytext)` |
| `parser/parser.y:164-166` | Erro de sintaxe | `printf("Erro de sintaxe: %s\n", s)` |
| `parser/parser.y:149` | Proteção divisão por zero | `$3 != 0 ? $1 / $3 : 0` |

## Exemplos de Uso

### Exemplo 1: Estrutura de Controle
```python
if 10 > 5:
    x = 40 + 2
    if x == 42:
        resultado = 1000
else:
    resultado = 50
```
**Análise Léxica**: 24 tokens gerados (IF, INT, GREATER, NEWLINE, INDENT, etc.)
**Análise Sintática**: AST com estrutura `if-else` aninhada
**Verificação Semântica**: Variáveis `x` e `resultado` registradas na tabela de símbolos

### Exemplo 2: Definição de Função
```python
def somar(a, b=10):
    resultado = a + b
    return resultado
```
**Análise Léxica**: 13 tokens (DEF, IDENTIFIER, LPAREN, ASSIGNMENT, etc.)
**Análise Sintática**: Função registrada com 2 parâmetros, um com valor padrão
**Tabela de Símbolos**: `somar` é `T_FUNC` com parâmetros `a` (T_INT) e `b` (T_INT, padrão=10)

### Exemplo 3: Expressões com Precedência
```python
resultado = 2 + 3 * 4
```
**Lexer Output**: 9 tokens
**Parser Output**: AST com `+` na raiz e `*` como sub-expressão (precedência correta)
**Avaliação**: Não executada, apenas AST construída


---

<div align="center">
  <strong>Definições do Projeto - Grupo 09</strong><br>
  <sub>Compilador Python - Compiladores 1 - UnB/2025.2</sub><br><br>
</div>
