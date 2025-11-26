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
  - [ETAPA 8: GERAÇÃO DE CÓDIGO INTERMEDIÁRIO](#etapa-8-geração-de-código-intermediário)
  - [ETAPA 9: GERAÇÃO DE CÓDIGO C](#etapa-9-geração-de-código-c)
  - [ETAPA 10: TRATAMENTO DE ERROS](#etapa-10-tratamento-de-erros)
  - [ETAPA 11: PIPELINE DE COMPILAÇÃO COMPLETO](#etapa-11-pipeline-de-compilação-completo)
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

### Análise Léxica 
- Reconhecimento completo de tokens Python usando Flex
- Suporte a palavras-chave: `if`, `else`, `while`, `for`, `def`, `return`, `and`, `or`, `not`
- Operadores aritméticos: `+`, `-`, `*`, `/`, `%`, `^` (exponenciação), `//` (divisão inteira)
- Operadores comparação: `==`, `!=`, `<`, `>`, `<=`, `>=`
- Operadores atribuição: `=`, `+=`, `-=`, `*=`, `/=`, `%=`
- Números inteiros e ponto flutuante (parcial, conversão para int no parser)
- Strings com delimitadores simples/duplos
- Comentários com `#`
- Gerenciamento completo de indentação (INDENT/DEDENT)

### Análise Sintática
- Parser funcional com gramática Python usando Bison
- Expressões aritméticas com precedência correta
- Expressões lógicas (and, or, not)
- Estruturas condicionais (if/else)
- Estruturas de repetição (while)
- Definição de funções com parâmetros e retorno
- Chamadas de função
- Tratamento de indentação Python

### Árvore Sintática Abstrata - AST 
- Construção completa da AST
- Tipos de nós: operador (BINOP), unário (UNOP), identificador (ID), número (NUM), string (STR)
- Operadores especiais: atribuição, condicional, loop, chamada de função
- Suporte a operadores unários (negação, not)
- Impressão formatada da AST

### Tabela de Símbolos
- Gerenciamento completo de símbolos
- Controle de escopo (local/global)
- Suporte a múltiplos tipos: `INT`, `FLOAT`, `STRING`, `FUNC`, `VOID`
- Detecção de redeclarações
- Gerenciamento de funções com parâmetros e tipo de retorno
- Verificação de tipos em atribuições

### Análise Semântica
- Verificação de tipos
- Validação de compatibilidade em operações
- Propagação de tipos
- Detecção de variáveis indefinidas
- Verificação de argumentos em chamadas de função

### Geração de Código Intermediário
- Geração de código de três endereços
- Instruções intermediárias: assign, binop, unop, label, goto, if_false, if_true
- Gerenciamento de temporários
- Suporte a arrays/vetores
- Chamadas de função e retorno

### Geração de Código C
- Geração de código C sintaticamente válido
- Conversão de AST para C
- Suporte a estruturas de controle em C
- Gerenciamento de variáveis e tipos

### Sistema de Testes 
- 48 testes em 7 categorias
- Testes de AST (10 testes)
- Testes de condicionais (3 testes)
- Testes de detecção de erros (4 testes)
- Testes gerais (11 testes)
- Testes de símbolos (10 testes)
- Testes de integração (10 testes)

### Build & Tooling
- Makefile com regras de compilação automática
- Scripts de teste por categoria
- Suporte a compilação Flex + Bison integrados
- Sistema de limpeza de artefatos

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
| `parser/parser.y:300` | Menos unário | `MINUS expr %prec UMINUS` → `novoNoOp('-', $2, NULL)` → Nó AST unário com `-` |
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
| `Makefile:4-8` | Variáveis de compilação | `CC = gcc`, `CFLAGS = -Wall -Wextra -std=gnu99` |
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

### ETAPA 8: GERAÇÃO DE CÓDIGO INTERMEDIÁRIO (src/gerador.c e src/gerador.h)

#### 8.1 Estrutura de Dados - Instruções de Três Endereços
| Local | Regra de Funcionamento | Demostração |
|-------|----------------------------------|----------------------------|
| `src/gerador.h:9-25` | Enum de tipos de instrução | `INSTR_ASSIGN`, `INSTR_BINOP`, `INSTR_UNOP`, `INSTR_LABEL`, `INSTR_GOTO`, `INSTR_IF_FALSE`, `INSTR_IF_TRUE`, etc. |
| `src/gerador.h:27-38` | Estrutura de instrução | `tipo`, `resultado`, `arg1`, `arg2`, `op`, `label`, `prox` |
| `src/gerador.h:40-46` | Lista de instruções | `inicio`, `fim`, `contador_temp`, `contador_label` |

#### 8.2 Gerenciamento de Memória
| Local | Regra de Funcionamento | Demostração |
|-------|----------------------------------|----------------------------|
| `src/gerador.c:42-50` | Criação de lista | `criarListaInstrucoes()` → Aloca e inicializa estrutura |
| `src/gerador.c:52-63` | Liberação de memória | `liberarListaInstrucoes()` → Libera cadeia de instruções |
| `src/gerador.c:65-74` | Geração de temporários | `novoTemp()` → Retorna nomes `t0`, `t1`, `t2`, ... |
| `src/gerador.c:76-79` | Geração de labels | `novoLabel()` → Retorna números sequenciais `L0`, `L1`, ... |

#### 8.3 Adição de Instruções
| Local | Regra de Funcionamento | Demostração |
|-------|----------------------------------|----------------------------|
| `src/gerador.c:81-97` | Adicionar instrução à lista | `adicionarInstrucao()` → Encadeia na lista vinculada |
| `src/gerador.c:99-112` | Criar instrução ASSIGN | `novaInstrucaoAssign()` → Instrução de atribuição simples |
| `src/gerador.c:114-127` | Criar instrução BINOP | `novaInstrucaoBinop()` → Operação binária (dest = arg1 op arg2) |
| `src/gerador.c:129-140` | Criar instrução UNOP | `novaInstrucaoUnop()` → Operação unária (dest = op arg) |
| `src/gerador.c:142-148` | Criar instrução LABEL | `novaInstrucaoLabel()` → Marca posição no código |
| `src/gerador.c:150-155` | Criar instrução GOTO | `novaInstrucaoGoto()` → Salto incondicional para label |
| `src/gerador.c:157-162` | Criar instrução IF_FALSE | `novaInstrucaoIfFalse()` → Salto condicional (se falso) |
| `src/gerador.c:164-169` | Criar instrução RETURN | `novaInstrucaoReturn()` → Retorno de função |

#### 8.4 Geração de Código Intermediário da AST
| Local | Regra de Funcionamento | Demostração |
|-------|----------------------------------|----------------------------|
| `src/gerador.c:171-180` | Função principal de geração | `gerarCodigoIntermediario()` → Traduz AST para código intermediário |
| `src/gerador.c:182-250` | Processamento recursivo de expressões | `gerarCodigoExpr()` → Gera instruções para cada nó AST |
| `src/gerador.c:252-300` | Tratamento de operações binárias | `BINOP` → Aloca temporário + cria `INSTR_BINOP` |
| `src/gerador.c:302-320` | Tratamento de operações unárias | `UNOP` → Aloca temporário + cria `INSTR_UNOP` |
| `src/gerador.c:322-340` | Tratamento de identificadores | `ID` → Retorna nome da variável |
| `src/gerador.c:342-350` | Tratamento de números | `NUM` → Converte valor para string |
| `src/gerador.c:352-360` | Tratamento de strings | `STR` → Registra string constante |

#### 8.5 Impressão de Código Intermediário
| Local | Regra de Funcionamento | Demostração |
|-------|----------------------------------|----------------------------|
| `src/gerador.c:362-400` | Função de impressão | `imprimirCodigoIntermediario()` → Lista todas instruções com índices |
| `src/gerador.c:402-450` | Formatação de instrução | `imprimirInstrucao()` → Converte instrução para formato legível |

### ETAPA 9: GERAÇÃO DE CÓDIGO C (src/codegen_c.c e src/codegen_c.h)

#### 9.1 Estrutura de Dados - Gerador de Código C
| Local | Regra de Funcionamento | Demostração |
|-------|----------------------------------|----------------------------|
| `src/codegen_c.h:8-24` | Estrutura CodeGenC | `arquivo`, `indent_level`, `label_counter` |
| `src/codegen_c.h:9` | Tracking de variáveis declaradas | `declared_vars[]` → Evita redeclarações |
| `src/codegen_c.h:10` | Tracking de ponteiros (arrays) | `ptr_vars[]` → Gerencia vetores |
| `src/codegen_c.h:11` | Tracking de strings | `str_vars[]` → Controla constantes de string |

#### 9.2 Inicialização e Liberação
| Local | Regra de Funcionamento | Demostração |
|-------|----------------------------------|----------------------------|
| `src/codegen_c.c:4-37` | Criação do gerador | `criarCodeGenC()` → Abre arquivo C, aloca estruturas |
| `src/codegen_c.c:39-70` | Liberação do gerador | `liberarCodeGenC()` → Fecha arquivo, libera todas listas |
| `src/codegen_c.c:72-87` | Reinicialização de declarações | `reiniciarDeclaracoes()` → Limpa listas entre funções |

#### 9.3 Formatação de Código C
| Local | Regra de Funcionamento | Demostração |
|-------|----------------------------------|----------------------------|
| `src/codegen_c.c:89-96` | Impressão de indentação | `imprimirIndentC()` → Adiciona espaços baseado em `indent_level` |
| `src/codegen_c.c:98-102` | Validação de número | `eh_numero()` → Diferencia literais de identificadores |
| `src/codegen_c.c:104-150` | Conversão de tipo | `converterTipoCodigo()` → `T_INT` → `int`, `T_STRING` → `char*` |

#### 9.4 Gerenciamento de Declarações
| Local | Regra de Funcionamento | Demostração |
|-------|----------------------------------|----------------------------|
| `src/codegen_c.c:152-180` | Verificar se declarada | `jaDeclarada()` → Evita redeclarações duplicadas |
| `src/codegen_c.c:182-210` | Registrar variável | `registrarVariavel()` → Adiciona à lista de declaradas |
| `src/codegen_c.c:212-240` | Registrar vetor | `registrarVetor()` → Controla ponteiros |
| `src/codegen_c.c:242-260` | Registrar string | `registrarString()` → Mantém strings únicas |

#### 9.5 Geração de Instruções C
| Local | Regra de Funcionamento | Demostração |
|-------|----------------------------------|----------------------------|
| `src/codegen_c.c:262-310` | Função principal de geração | `gerarCodigoC()` → Traduz código intermediário para C |
| `src/codegen_c.c:312-350` | Impressão de instrução | `imprimirInstrucaoC()` → Converte tipo de instrução para código C |
| `src/codegen_c.c:352-400` | Tratamento de ASSIGN | `INSTR_ASSIGN` → `dest = fonte;` |
| `src/codegen_c.c:402-450` | Tratamento de BINOP | `INSTR_BINOP` → `dest = arg1 op arg2;` |
| `src/codegen_c.c:452-480` | Tratamento de UNOP | `INSTR_UNOP` → `dest = op arg;` |
| `src/codegen_c.c:482-510` | Tratamento de LABEL | `INSTR_LABEL` → `label_L123:` (marcação) |
| `src/codegen_c.c:512-530` | Tratamento de GOTO | `INSTR_GOTO` → `goto label_L123;` |
| `src/codegen_c.c:532-560` | Tratamento de IF_FALSE | `INSTR_IF_FALSE` → `if (!cond) goto label_L123;` |
| `src/codegen_c.c:562-580` | Tratamento de RETURN | `INSTR_RETURN` → `return valor;` |

#### 9.6 Emissão de Headers e Footers
| Local | Regra de Funcionamento | Demostração |
|-------|----------------------------------|----------------------------|
| `src/codegen_c.c:582-600` | Header do programa | `#include <stdio.h>`, `#include <stdlib.h>` |
| `src/codegen_c.c:602-620` | Declarações de variáveis | Emite `int var1, var2;` etc. com base em rastreamento |
| `src/codegen_c.c:622-640` | Função main | `int main() { ... }` |
| `src/codegen_c.c:642-660` | Footer do programa | `return 0;` e fechamento de chaves |

### ETAPA 10: TRATAMENTO DE ERROS

#### 10.1 Erros Detectados
| Local | Regra de Funcionamento | Demostração |
|-------|----------------------------------|----------------------------|
| `lexer/lexer.l:154-156` | Erro de indentação | `IndentationError: unindent does not match any outer indentation level` |
| `lexer/lexer.l:200` | Caractere inválido | `printf("Caractere invalido: %s\n", yytext)` |
| `parser/parser.y:164-166` | Erro de sintaxe | `printf("Erro de sintaxe: %s\n", s)` |
| `parser/parser.y:149` | Proteção divisão por zero | `$3 != 0 ? $1 / $3 : 0` |
| `src/gerador.c:27-33` | Erro de alocação (gerador) | `perror("Erro fatal: Falha ao alocar instrucao")` |
| `src/codegen_c.c:18-21` | Erro ao abrir arquivo C | `perror("Erro ao abrir arquivo para escrita")` |

#### 10.2 Recuperação de Erros
| Local | Regra de Funcionamento | Demostração |
|-------|----------------------------------|----------------------------|
| `src/gerador.c:42-50` | Validação de alocação | `if (!lista) exit(1)` → Garante lista válida |
| `src/codegen_c.c:4-37` | Validação de arquivo | `if (!codegen->arquivo) exit(1)` → Garante escrita |
| `src/main.c:17-25` | Validação de entrada | `if (!yyin) printf("Erro: Nao foi possivel...")` |

### ETAPA 11: PIPELINE DE COMPILAÇÃO COMPLETO (src/main.c)

#### 11.1 Fluxo de Execução Principal
| Local | Regra de Funcionamento | Demostração |
|-------|----------------------------------|----------------------------|
| `src/main.c:14-18` | Inicialização | `init_compiler()` → Setup lexer, parser, tabela de símbolos |
| `src/main.c:20-25` | Abertura de arquivo | Se `argc > 1`: `yyin = fopen(argv[1], "r")` |
| `src/main.c:29` | Análise sintática | `yyparse()` → Executa lexer + parser, constrói AST |
| `src/main.c:31-45` | Impressão de AST | Se sucesso: `imprimirAST_formatada()` + `imprimirAST()` |

#### 11.2 Geração de Código Intermediário
| Local | Regra de Funcionamento | Demostração |
|-------|----------------------------------|----------------------------|
| `src/main.c:47-50` | Criação de lista | `criarListaInstrucoes()` → Inicializa estrutura |
| `src/main.c:51` | Geração intermediária | `gerarCodigoIntermediario(raiz_ast, codigo)` → Traduz AST |
| `src/main.c:52` | Impressão intermediária | `imprimirCodigoIntermediario(codigo)` → Mostra instruções 3-endereços |

#### 11.3 Geração de Código C
| Local | Regra de Funcionamento | Demostração |
|-------|----------------------------------|----------------------------|
| `src/main.c:54-69` | Construção de nome de saída | Extrai basename de `argv[1]`, substitui `.py` por `.c` |
| `src/main.c:70` | Criação do gerador C | `criarCodeGenC(output_file)` → Abre arquivo para escrita |
| `src/main.c:71` | Geração de código C | `gerarCodigoC(codigo, codegen)` → Converte intermediário para C |
| `src/main.c:72` | Liberação do gerador | `liberarCodeGenC(codegen)` → Fecha arquivo e libera memória |

#### 11.4 Limpeza de Recursos
| Local | Regra de Funcionamento | Demostração |
|-------|----------------------------------|----------------------------|
| `src/main.c:74` | Liberação de lista intermediária | `liberarListaInstrucoes(codigo)` → Desaloca instruções |
| `src/main.c:76-80` | Fechamento de arquivo | Se entrada era arquivo: `fclose(yyin)` |
| `src/main.c:82` | Código de retorno | `return 0` (sucesso) ou `return 1` (erro) |

#### 11.5 Pipeline Integrado: Transformações
| Estágio | Entrada | Transformação | Saída | Arquivo |
|---------|---------|---------------|-------|---------|
| 1 | Arquivo `.py` | Flex tokenização | Token stream | `lexer.l` |
| 2 | Token stream | Bison parsing | Árvore AST | `parser.y` |
| 3 | Árvore AST | Verificação semântica | AST tipado | `ast.c` |
| 4 | AST tipado | Geração intermediária | Instruções 3-end. | `gerador.c` |
| 5 | Instruções 3-end. | Código C | Arquivo `.c` | `codegen_c.c` |

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
