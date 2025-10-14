# Definições do Projeto - Compilador Python Grupo 09

## Especificações Técnicas Implementadas

Esta tabela define todas as regras de funcionamento implementadas no compilador, baseadas na análise do código fonte real.

| Local | Regra de Funcionamento | Demostração |
|-------|----------------------------------|----------------------------|
| **ANÁLISE LÉXICA** | | |
| `lexer/lexer.l:82` | Números inteiros com sinal opcional | `123`, `-45`, `+10` → Token `INT` |
| `lexer/lexer.l:83` | Números decimais com sinal opcional | `3.14`, `-2.5`, `+1.0` → Token `FLOAT` |
| `lexer/lexer.l:84` | Strings com aspas simples ou duplas | `"hello"`, `'world'` → Token `STRING` |
| `lexer/lexer.l:99` | Identificadores válidos Python | `variavel`, `_temp`, `func1` → Token `IDENTIFIER` |
| `lexer/lexer.l:78` | Comentários de linha única | `# Este é um comentário` → Ignorado |
| `lexer/lexer.l:79-80` | Comentários de bloco múltiplas linhas | `"""comentário"""`, `'''comentário'''` → Ignorado |
| `lexer/lexer.l:86-97` | Palavras-chave Python reservadas | `if`, `else`, `def`, `return`, `and`, `or`, `not` → Tokens específicos |
| `lexer/lexer.l:101-111` | Operadores duplos específicos | `==`, `!=`, `>=`, `<=`, `**`, `//`, `+=` → Tokens específicos |
| `lexer/lexer.l:113-125` | Operadores simples e delimitadores | `+`, `-`, `*`, `/`, `(`, `)`, `:`, `,` → Tokens específicos |
| `lexer/lexer.l:127` | Espaços em branco ignorados | `[ \t\r]+` → Ignorado completamente |
| **INDENTAÇÃO PYTHON** | | |
| `lexer/lexer.l:129-134` | Detecção de nova linha | `\n` → Token `NEWLINE` + estado `INDENT_STATE` |
| `lexer/lexer.l:136-160` | Contagem de espaços/tabs para indentação | `    código` (4 espaços) → Calcula nível de indentação |
| `lexer/lexer.l:142-146` | Aumento de indentação | Nível atual > anterior → Token `INDENT` + empilha nível |
| `lexer/lexer.l:148-158` | Diminuição de indentação | Nível atual < anterior → Token(s) `DEDENT` + desempilha |
| `lexer/lexer.l:22-58` | Pilha para níveis de indentação | `stack` com `indent[MAX]` e `indent_top` |
| `lexer/lexer.l:41-45` | Empilhar novo nível | `stack_push(s, level)` quando indentação aumenta |
| `lexer/lexer.l:47-52` | Desempilhar nível | `stack_pop(s)` quando indentação diminui |
| `lexer/lexer.l:185-197` | Tratamento de fim de arquivo | `<<EOF>>` → Gera `DEDENT`s para todos níveis restantes |
| `lexer/lexer.l:136` | Aceita espaços OU tabs | `[ \t]+` → Conta caracteres para nível |
| `lexer/lexer.l:137` | Cálculo do nível atual | `int actual_level = strlen(yytext)` |
| `lexer/lexer.l:138` | Comparação com nível anterior | `int previous_level = stack_peek(s)` |
| `lexer/lexer.l:153-156` | Validação de indentação | Erro se nível não coincide com pilha |
| `lexer/lexer.l:162-166` | Linhas em branco | `[ \t]*\n` → Apenas `NEWLINE` |
| `lexer/lexer.l:168-183` | Volta ao nível 0 | Sem espaços → Desempilha tudo |
| **ANÁLISE SINTÁTICA** | | |
| `parser/parser.y:24-28` | Union de tipos semânticos | `int intValue`, `double floatValue`, `char* strValue` |
| `parser/parser.y:31-34` | Tokens com valor semântico | `%token <intValue> INT`, `%token <strValue> IDENTIFIER` |
| `parser/parser.y:52-59` | Precedência de operadores | `%left OR` (menor) → `%right UMINUS` (maior) |
| `parser/parser.y:63-66` | Programa principal | `program: /* vazio */ | statement_list` |
| `parser/parser.y:68-71` | Lista de statements | `statement_list: statement | statement_list statement` |
| `parser/parser.y:73-77` | Tipos de statement | `NEWLINE`, `simple_statement NEWLINE`, `compound_statement` |
| `parser/parser.y:79-83` | Statements simples | `expr`, `return_statement`, `assignment_statement` |
| `parser/parser.y:85-87` | Atribuição de variável | `IDENTIFIER ASSIGNMENT expr` |
| `parser/parser.y:89-92` | Statements compostos | `if_statement`, `function_definition` |
| `parser/parser.y:95-97` | Suite (bloco indentado) | `NEWLINE INDENT statement_list DEDENT` |
| `parser/parser.y:99-102` | Estrutura if/else | `IF expr COLON suite [ELSE COLON suite]` |
| `parser/parser.y:104-106` | Definição de função | `DEF IDENTIFIER LPAREN parameter_list RPAREN COLON suite` |
| **AVALIAÇÃO DE EXPRESSÕES** | | |
| `parser/parser.y:137` | Operador lógico OR | `expr OR expr` → `$$ = $1 || $3` (avaliação direta) |
| `parser/parser.y:138` | Operador lógico AND | `expr AND expr` → `$$ = $1 && $3` (avaliação direta) |
| `parser/parser.y:139` | Operador lógico NOT | `NOT expr` → `$$ = !$2` (negação) |
| `parser/parser.y:140-145` | Operadores relacionais | `==`, `!=`, `>`, `<`, `>=`, `<=` → Comparação direta |
| `parser/parser.y:146-147` | Operadores aritméticos básicos | `+`, `-` → `$$ = $1 + $3`, `$$ = $1 - $3` |
| `parser/parser.y:148-151` | Operadores multiplicativos | `*`, `/`, `%`, `//` → Com proteção divisão por zero |
| `parser/parser.y:152` | Operador exponenciação | `expr ** expr` → Loop for para calcular potência |
| `parser/parser.y:153` | Parênteses para agrupamento | `LPAREN expr RPAREN` → `$$ = $2` |
| `parser/parser.y:154` | Literal inteiro | `INT` → `$$ = $1` (valor direto) |
| `parser/parser.y:155` | Literal float | `FLOAT` → `$$ = (int)$1` (conversão para int) |
| `parser/parser.y:156` | Identificador (placeholder) | `IDENTIFIER` → `$$ = 0` (sem tabela de símbolos) |
| `parser/parser.y:157` | Menos unário | `MINUS expr %prec UMINUS` → `$$ = -$2` |
| **PROGRAMA PRINCIPAL** | | |
| `src/main.c:17-25` | Modo de entrada por arquivo | `argc > 1` → `yyin = fopen(argv[1], "r")` |
| `src/main.c:28` | Inicialização do compilador | `init_compiler()` → Inicializa pilha de indentação |
| `src/main.c:29` | Execução da análise | `yyparse()` → Retorna 0 se sucesso |
| `src/main.c:169-172` | Inicialização da pilha | `s = stack_init()` + mensagem de boas-vindas |
| `src/main.c:19-21` | Função de resultado | `print_result(int value)` → `printf("Resultado: %d\n", value)` |
| **SISTEMA DE BUILD** | | |
| `Makefile:4-8` | Variáveis de compilação | `CC = gcc`, `CFLAGS = -Wall -Wextra -std=c99` |
| `Makefile:27` | Target principal | `all: $(TARGET)` → Compila tudo |
| `Makefile:30-32` | Compilação do executável | `$(CC) $(CFLAGS) -o $(TARGET) $(OBJECTS) -lfl` |
| `Makefile:35-36` | Geração do lexer | `$(LEX) $(LEXER_SRC)` → `lex.yy.c` |
| `Makefile:39-40` | Geração do parser | `$(YACC) $(YFLAGS) -o parser.tab.c $(PARSER_SRC)` |
| `Makefile:47-50` | Limpeza de arquivos | `rm -f $(LEXER_C) $(PARSER_C) $(PARSER_H) *.o $(TARGET)` |
| `Makefile:53-54` | Execução do compilador | `./$(TARGET)` |
| `Makefile:57-59` | Teste básico | `echo "x = 10 + 5" | ./$(TARGET)` |
| **SCRIPTS DE AUTOMAÇÃO** | | |
| `compilar.sh:8` | Limpeza antes compilação | `rm -f *.o compilador` |
| `compilar.sh:12` | Geração do lexer | `flex lexer/lexer.l` |
| `compilar.sh:15` | Geração do parser | `bison -d -v -o parser.tab.c parser/parser.y` |
| `compilar.sh:18-20` | Compilação de objetos | `gcc -c` para cada arquivo `.c` |
| `compilar.sh:23` | Linkagem final | `gcc -o compilador *.o -lfl` |
| **SISTEMA DE TESTES** | | |
| `testes.sh:27-31` | Operações básicas | `3 + 4` → `7`, `8 / 2` → `4` |
| `testes.sh:34-38` | Precedência operadores | `2 + 3 * 4` → `14`, `(2 + 3) * 4` → `20` |
| `testes.sh:41-45` | Números negativos | `-5` → `-5`, `-3 + 7` → `4` |
| `testes.sh:48-51` | Parênteses complexos | `((2 + 3) * 4) - 1` → `19` |
| `testes.sh:54-58` | Divisão e casos especiais | `5 / 0` → `0` (proteção) |
| `testes.sh:61-65` | Expressões longas | `1 + 2 + 3 + 4` → `10` |
| `testes.sh:68-73` | Casos especiais | `0` → `0`, `((10))` → `10` |
| `testes.sh:76-79` | Expressões com espaços | `  3   +   4  ` → `7` |
| **ARQUIVO DE EXEMPLO** | | |
| `teste.py:1-2` | Estrutura if com indentação | `if 10 > 5:\n    40 + 2` |
| `teste.py:3-4` | If aninhado com indentação | `    if 1 == 1:\n        1000` |
| `teste.py:5-6` | Else com indentação | `    else:\n        2000` |
| `teste.py:7-8` | Else do if principal | `else:\n    50 - 5` |
| **TRATAMENTO DE ERROS** | | |
| `lexer/lexer.l:154-156` | Erro de indentação | `IndentationError: unindent does not match any outer indentation level` |
| `lexer/lexer.l:200` | Caractere inválido | `printf("Caractere invalido: %s\n", yytext)` |
| `parser/parser.y:164-166` | Erro de sintaxe | `printf("Erro de sintaxe: %s\n", s)` |
| `parser/parser.y:149` | Proteção divisão por zero | `$3 != 0 ? $1 / $3 : 0` |
| **FUNCIONALIDADES NÃO IMPLEMENTADAS** | | |
| N/A | Tabela de símbolos | Variáveis sempre retornam `0` |
| N/A | Verificação de tipos | Sem análise semântica |
| N/A | Execução de funções | Apenas parsing da sintaxe |
| N/A | Loops funcionais | `while`, `for` reconhecidos mas não executam |
| N/A | Geração de código | Sem código intermediário ou final |

## Resumo das Regras Implementadas

### Indentação Python
- **Aceita**: Espaços (`' '`) e tabs (`\t`) misturados
- **Conta**: `strlen(yytext)` para determinar nível
- **Pilha**: Gerencia níveis aninhados de indentação
- **Tokens**: Gera `INDENT` (aumento) e `DEDENT` (diminuição)
- **Validação**: Erro se nível não coincide com estrutura

### Avaliação de Expressões
- **Imediata**: Calcula resultado durante parsing
- **Proteção**: Divisão por zero retorna 0
- **Conversão**: Float → Int automática
- **Precedência**: Implementada via Bison (`%left`, `%right`)

### Sistema de Testes
- **32 casos**: Organizados em 8 categorias
- **Cobertura**: Operações, precedência, casos especiais
- **Automatizado**: Script bash com verificação

---

<div align="center">
  <strong>Definições do Projeto - Grupo 09</strong><br>
  <sub>Compilador Python - Compiladores 1 - UnB/2025.2</sub><br><br>
  <em>"Especificações técnicas tabulares baseadas na implementação real"</em>
</div>
