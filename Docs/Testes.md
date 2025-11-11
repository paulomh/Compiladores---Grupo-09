# Sistema de Testes - Compilador Python

## Sumário

- [Visão Geral](#visão-geral)
- [Estrutura de Testes](#estrutura-de-testes)
  - [Categorias de Testes](#categorias-de-testes)
  - [Arquivos de Teste](#arquivos-de-teste)
  - [Organização de Diretórios](#organização-de-diretórios)
- [Execução de Testes](#execução-de-testes)
  - [Suíte Completa](#suíte-completa)
  - [Testes por Categoria](#testes-por-categoria)
  - [Testes Individuais](#testes-individuais)
  - [Compilação e Teste](#compilação-e-teste)
- [Descrição das Categorias](#descrição-das-categorias)
  - [1. AST (Árvore Sintática Abstrata)](#1-ast-árvore-sintática-abstrata)
  - [2. Condicionais](#2-condicionais)
  - [3. Detecção de Erros](#3-detecção-de-erros)
  - [4. Testes Gerais](#4-testes-gerais)
  - [5. Tabela de Símbolos](#5-tabela-de-símbolos)
  - [6. Integração](#6-integração)
- [Formato de Saída](#formato-de-saída)
  - [Mensagens de Teste](#mensagens-de-teste)
  - [Relatórios Finais](#relatórios-finais)


---

## Visão Geral

O compilador Python do Grupo 09 possui uma suíte completa de testes organizada em **6 categorias funcionais**. Os testes validam cada etapa do processo de compilação: análise léxica, análise sintática, construção da árvore sintática (AST), gerenciamento de símbolos, detecção de erros e integração entre componentes.

**Estatísticas da Suíte:**
- **Total de Testes:** 48
- **Categorias:** 6
- **Arquivos de Teste:** 45 arquivo Python
- **Scripts de Execução:** 7 scripts Bash

---

## Estrutura de Testes

### Categorias de Testes

| Categoria | Testes | Foco | Arquivo Script |
|-----------|--------|------|-----------------|
| **AST** | 10 | Construção e validação da árvore sintática | `test_category_ast.sh` |
| **Condicionais** | 3 | Estruturas `if/else` e blocos condicionais | `test_category_conditional.sh` |
| **Erros** | 4 | Detecção de erros com indicação de linha | `test_category_error.sh` |
| **Gerais** | 11 | Funcionalidades básicas do compilador | `test_category_general.sh` |
| **Símbolos** | 10 | Gerenciamento da tabela de símbolos | `test_category_symbol.sh` |
| **Integração** | 10 | Integração AST + Tabela de Símbolos | `test_category_integration.sh` |

### Arquivos de Teste

Todos os arquivos de teste estão localizados em `tests/files/` com nomenclatura descritiva:

```
tests/files/
├── ast_*.py                    (10 arquivos)
├── conditional_*.py            (3 arquivos)
├── error_*.py                  (4 arquivos)
├── assign_basic.py
├── comment_basic.py
├── expr_basic.py
├── func_basic.py
├── indent_deep.py
├── mixed_complete.py
├── test_*.py                   (4 arquivos)
├── symbol_*.py                 (10 arquivos)
└── integration_*.py            (10 arquivos)
```

### Organização de Diretórios

```
tests/
├── files/                      # Arquivos de teste (.py)
│   ├── ast_*.py
│   ├── conditional_*.py
│   ├── error_*.py
│   ├── symbol_*.py
│   ├── integration_*.py
│   └── [outros].py
└── scripts/                    # Scripts de execução (.sh)
    ├── test_category_all.sh        # Master script
    ├── test_category_ast.sh
    ├── test_category_conditional.sh
    ├── test_category_error.sh
    ├── test_category_general.sh
    ├── test_category_symbol.sh
    └── test_category_integration.sh
```

---

## Execução de Testes

### Suíte Completa

**Opção 1: Compilar e executar todos os testes**

```bash
# Completo com build
make clean && make && chmod +x tests/scripts/test_category_*.sh && bash tests/scripts/test_category_all.sh
```

**Opção 2: Apenas executar (sem recompilar)**

```bash
# Rápido, sem build
bash tests/scripts/test_category_all.sh
```

**Opção 3: Com WSL2 (Windows)**

```powershell
# Compilar e testar
wsl -d Ubuntu bash -lc 'cd "$(pwd)" && make clean && make && chmod +x tests/scripts/test_category_*.sh && bash tests/scripts/test_category_all.sh'

# Ou navegando no caminho
wsl -d Ubuntu bash -c 'cd /caminho/do/projeto && make clean && make && bash tests/scripts/test_category_all.sh'
```

### Testes por Categoria

Execute apenas os testes de uma categoria específica:

#### AST
```bash
bash tests/scripts/test_category_ast.sh
```

#### Condicionais
```bash
bash tests/scripts/test_category_conditional.sh
```

#### Erros
```bash
bash tests/scripts/test_category_error.sh
```

#### Gerais
```bash
bash tests/scripts/test_category_general.sh
```

#### Símbolos
```bash
bash tests/scripts/test_category_symbol.sh
```

#### Integração
```bash
bash tests/scripts/test_category_integration.sh
```

### Testes Individuais

Executar um teste específico manualmente:

```bash
# Testar um arquivo específico
./compilador tests/files/ast_binop.py

# Com saída detalhada
./compilador tests/files/ast_binop.py 2>&1
```

### Compilação e Teste

Ciclo completo de desenvolvimento:

```bash
# Limpar, compilar e testar em uma única linha
make clean && make && bash tests/scripts/test_category_all.sh

# Apenas recompilar e testar (sem clean)
make && bash tests/scripts/test_category_all.sh
```

---

## Descrição das Categorias

### 1. AST (Árvore Sintática Abstrata)

**Propósito:** Validar a construção correta da árvore sintática abstrata.

**Testes Inclusos (10 testes):**
- `ast_assignment.py` - Atribuições simples
- `ast_binop.py` - Operações binárias (+, -, *, /)
- `ast_comparison.py` - Comparações (==, <, >, <=, >=)
- `ast_complex_nested.py` - Expressões complexas aninhadas
- `ast_logical_ops.py` - Operadores lógicos (and, or, not)
- `ast_parentheses.py` - Expressões com parênteses
- `ast_precedence.py` - Precedência de operadores
- `ast_unary_minus.py` - Operador unário menos
- `ast_unary_not.py` - Operador NOT
- `ast_variable.py` - Identificadores e variáveis

**Validação:** Verifica se a AST contém estruturas esperadas (BINOP, UNOP, ID, NUM).

---

### 2. Condicionais

**Propósito:** Validar suporte a estruturas de controle condicional.

**Testes Inclusos (3 testes):**
- `conditional_basic.py` - if simples
- `conditional_complex.py` - if com múltiplas condições
- `conditional_nested.py` - if aninhados

**Validação:** Verifica compilação bem-sucedida de estruturas condicionais.

---

### 3. Detecção de Erros

**Propósito:** Validar detecção e reportagem adequada de erros com indicação de linha.

**Testes Inclusos (4 testes):**
- `error_bad_indentation.py` - Indentação incorreta
- `error_invalid_chars.py` - Caracteres inválidos no código
- `error_syntax_error.py` - Erro de sintaxe
- `error_unbalanced_parens.py` - Parênteses desbalanceados

**Validação:** 
- Erro deve ser detectado
- Mensagem deve incluir número de linha
- Código de saída deve indicar erro (não-zero)

---

### 4. Testes Gerais

**Propósito:** Validar funcionalidades básicas e integradas do compilador.

**Testes Inclusos (11 testes):**
- `assign_basic.py` - Atribuições básicas
- `comment_basic.py` - Comentários
- `expr_basic.py` - Expressões básicas
- `func_basic.py` - Definição de funções
- `indent_deep.py` - Indentação profunda
- `mixed_complete.py` - Código misto complexo
- `test_simple.py` - Teste simples
- `test_ast_table.py` - AST com tabela
- `test_symbol_table.py` - Tabela de símbolos
- `test_escopo_tipos.py` - Escopo e tipos (esperado erro)
- `test_tipos_retorno.py` - Tipos de retorno (esperado erro)

**Validação:** Compilação bem-sucedida ou erro esperado conforme o teste.

---

### 5. Tabela de Símbolos

**Propósito:** Validar gerenciamento correto da tabela de símbolos, tipos e escopo.

**Testes Inclusos (10 testes):**
- `symbol_simple_insert.py` - Inserção simples de símbolo
- `symbol_multiple_vars.py` - Múltiplas variáveis
- `symbol_different_types.py` - Tipos diferentes (int, float)
- `symbol_redeclaration.py` - Redeclaração de variável
- `symbol_function_def.py` - Definição de função
- `symbol_scope.py` - Escopo de variáveis
- `symbol_function_params.py` - Parâmetros de função
- `symbol_assignment_with_vars.py` - Atribuição com variáveis
- `symbol_nested_functions.py` - Funções aninhadas
- `symbol_undefined_var.py` - Variável indefinida (erro esperado)

**Validação:** 
- Sucesso em casos válidos
- Erro ao referenciar variáveis indefinidas
- Correta propagação de escopo

---

### 6. Integração

**Propósito:** Validar integração entre AST e tabela de símbolos.

**Testes Inclusos (10 testes):**
- `integration_var_in_expr.py` - Variável em expressão
- `integration_undefined_in_expr.py` - Variável indefinida em expressão (erro)
- `integration_compatible_types.py` - Atribuição de tipos compatíveis
- `integration_type_mismatch.py` - Tipos incompatíveis
- `integration_function_call_valid.py` - Chamada de função válida
- `integration_function_call_invalid_args.py` - Argumentos incorretos
- `integration_implicit_cast.py` - Conversão implícita de tipos
- `integration_shadowing.py` - Variable shadowing (sombreamento)
- `integration_type_propagation.py` - Propagação de tipos
- `integration_conditional_scope.py` - Variável em escopo condicional

**Validação:**
- AST construída corretamente
- Símbolos resolvidos apropriadamente
- Tipos verificados e propagados

---

## Formato de Saída

### Mensagens de Teste

Cada teste individual exibe:

```
Testando: nome_do_arquivo.py -> [OK]
```

Ou em caso de falha:

```
Testando: nome_do_arquivo.py -> [FALHA] motivo da falha
```

Ou para testes que esperam erro:

```
Testando: nome_do_arquivo.py -> [OK] Erro detectado
```

### Relatórios Finais

Ao final de cada categoria:

```
==========================================
RELATÓRIO FINAL - [CATEGORIA]
==========================================
Total: 10 | Aprovados: 10 | Falhados: 0
Resultado: Todos os testes de [categoria] passaram com sucesso.
```

Relatório consolidado final:

```
==========================================
RELATÓRIO FINAL POR CATEGORIA
==========================================
[OK] AST: SUCESSO
[OK] CONDICIONAIS: SUCESSO
[OK] ERROS: SUCESSO
[OK] GERAIS: SUCESSO
[OK] SÍMBOLOS: SUCESSO
[OK] INTEGRAÇÃO: SUCESSO
==========================================
Resultado: Todos os testes passaram com sucesso.
```


---

<div align="center">
  <strong>Testes - Grupo 09</strong><br>
  <sub>Compilador Python - Compiladores 1 - UnB/2025.2</sub>
</div>
