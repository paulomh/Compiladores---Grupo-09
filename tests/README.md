# Como Executar os Testes - Compilador Grupo 09

Este guia explica como executar todos os testes do compilador de forma simples e eficiente.

## Execução Rápida

### Executar TODOS os Testes
```bash
# Windows (PowerShell)
wsl -d Ubuntu bash -c "cd /mnt/c/caminho/do/projeto && ./tests/run_all_tests.sh"

# Linux/WSL/macOS
./tests/run_all_tests.sh
```

### Executar Tipos Específicos

#### Testes Inline (Expressões - 115 testes)
```bash
# Windows (PowerShell)
wsl -d Ubuntu bash -c "cd /mnt/c/caminho/do/projeto && ./tests/scripts/testes.sh"

# Linux/WSL/macOS
./tests/scripts/testes.sh
```

#### Testes de Arquivos (Funcionalidades - 14 testes)
```bash
# Windows (PowerShell)
wsl -d Ubuntu bash -c "cd /mnt/c/caminho/do/projeto && ./tests/scripts/testes_arquivos.sh"

# Linux/WSL/macOS
./tests/scripts/testes_arquivos.sh
```

#### Teste Individual de Arquivo
```bash
# Windows (PowerShell)
wsl -d Ubuntu bash -c "cd /mnt/c/caminho/do/projeto && ./compilador tests/files/01_conditional_basic.py"

# Linux/WSL/macOS
./compilador tests/files/01_conditional_basic.py
```

## Estrutura dos Testes

```
tests/
├── run_all_tests.sh           # Script principal - executa TODOS os testes
├── scripts/
│   ├── testes.sh              # Testes inline (115 expressões)
│   └── testes_arquivos.sh     # Testes de arquivos (14 arquivos)
└── files/
    ├── 01_conditional_basic.py     # Condicionais básicas
    ├── 02_conditional_nested.py    # Condicionais aninhadas
    ├── 03_conditional_complex.py   # Condicionais complexas
    ├── 04_expressions_only.py      # Apenas expressões
    ├── 05_assignments.py           # Atribuições
    ├── 06_comments.py              # Comentários
    ├── 07_deep_indentation.py      # Indentação profunda
    ├── 08_functions.py             # Definições de função
    ├── 09_mixed_complete.py        # Funcionalidades mistas
    ├── error_01_bad_indentation.py # Erro: Indentação
    ├── error_02_syntax_error.py    # Erro: Sintaxe
    ├── error_03_unbalanced_parens.py # Erro: Parênteses
    └── error_04_invalid_chars.py   # Erro: Caracteres inválidos
```

## Pré-requisitos

1. **Compilar o projeto**:
   ```bash
   make clean && make
   ```

2. **WSL instalado** (para Windows):
   ```bash
   wsl --install -d Ubuntu
   ```

## Tipos de Testes

### Testes Inline (115 testes)
- **O que testa**: Expressões aritméticas e lógicas diretas
- **Cobertura**: Operadores, precedência, casos de erro
- **Tempo**: ~30 segundos
- **Arquivo**: `tests/scripts/testes.sh`

### Testes de Arquivos (14 testes)
- **O que testa**: Funcionalidades completas com arquivos Python
- **Cobertura**: Condicionais, indentação, funções, comentários
- **Tempo**: ~15 segundos  
- **Arquivo**: `tests/scripts/testes_arquivos.sh`

## Interpretando os Resultados

### Teste Passou
```
Testando: 3 + 4 -> PASSOU (Resultado: 7)
Testando arquivo: 01_conditional_basic.py -> PASSOU (Compilação bem-sucedida)
```

### Teste de Erro (Comportamento Esperado)
```
Testando: 3 @ 4 -> PASSOU (Erro detectado corretamente)
Testando arquivo: error_01_bad_indentation.py -> PASSOU (Erro detectado corretamente)
```

### Relatório Final
```
==========================================
         RELATÓRIO FINAL DOS TESTES
==========================================
Total de testes executados: 129
Testes aprovados: 129
Testes falharam: 0

TODOS OS TESTES PASSARAM!
```

## Resolução de Problemas

### Erro: "Executável não encontrado"
```bash
# Solução: Compilar o projeto
make clean && make
```

### Erro: "Permission denied"
```bash
# Solução: Dar permissão de execução
chmod +x tests/run_all_tests.sh
chmod +x tests/scripts/*.sh
```

### Erro: "Diretório não encontrado"
```bash
# Solução: Verificar se está no diretório correto
pwd  # Deve mostrar o caminho do projeto
ls   # Deve mostrar: compilador, tests/, Makefile, etc.
```

### WSL não instalado (Windows)
```bash
# Instalar WSL
wsl --install -d Ubuntu

# Ou executar no Git Bash/MinGW
bash tests/run_all_tests.sh
```

## Comandos de Exemplo

### Execução Completa Típica
```bash
# 1. Compilar
make clean && make

# 2. Executar todos os testes
./tests/run_all_tests.sh

# 3. Ver saída esperada
# Testes inline: 115/115 passaram
# Testes de arquivos: 14/14 passaram
# TODOS OS TESTES PASSARAM!
```

### Teste Específico para Debug
```bash
# Testar apenas um arquivo específico
./compilador tests/files/01_conditional_basic.py

# Testar apenas operadores básicos
echo "5 + 3 * 2" | ./compilador
```

## Cobertura dos Testes

- **Operadores**: `+`, `-`, `*`, `/`, `%`, `**`, `//`, `and`, `or`, `not`
- **Comparações**: `==`, `!=`, `>`, `<`, `>=`, `<=`
- **Estruturas**: `if/else`, indentação Python, blocos aninhados
- **Recursos**: Comentários, atribuições, definições de função
- **Casos de erro**: Sintaxe inválida, caracteres não suportados
- **Precedência**: Operadores aritméticos, lógicos e de comparação
