# Compilador - Grupo 09

Compilador desenvolvido para a disciplina Compiladores 1 usando Flex e Bison. Analisador de expressões aritméticas com suporte a operadores Python.

## Estrutura do Projeto

```
├── lexer/
│   └── lexer.l          # Analisador léxico (Flex) - Suporte Python
├── parser/
│   └── parser.y         # Analisador sintático (Bison) - Regras gramaticais
├── src/
│   └── main.c           # Programa principal
├── Makefile             # Sistema de build
├── compilar.sh          # Script de compilação
├── testes.sh            # Script de testes abrangente
└── README.md            # Documentação do projeto
```

## Arquitetura

### Analisador Léxico (lexer.l)
- Reconhece tokens da linguagem Python
- Suporte a comentários de linha e bloco
- Números inteiros e decimais com sinal
- Strings entre aspas simples e duplas
- Palavras-chave e operadores Python

### Analisador Sintático (parser.y)
- Regras gramaticais para expressões aritméticas e lógicas
- Precedência correta dos operadores
- Suporte a parênteses e operadores unários
- Tratamento de erros sintáticos

### Programa Principal (main.c)
- Interface de linha de comando
- Suporte a entrada via arquivo ou stdin
- Tratamento de erros e mensagens informativas

## Funcionalidades

### Operadores Suportados
- **Aritméticos:** `+`, `-`, `*`, `/`, `%`, `**`, `//`
- **Comparação:** `==`, `!=`, `>=`, `<=`, `>`, `<`
- **Lógicos:** `and`, `or`, `not`
- **Atribuição:** `=`, `+=`, `-=`, `*=`, `/=`, `%=`

### Tipos de Dados
- **Inteiros:** `123`, `-45`
- **Decimais:** `3.14`, `-2.5`
- **Identificadores:** `variavel`, `_nome`
- **Strings:** `"texto"`, `'string'`

### Palavras-chave Python
- `if`, `else`, `while`, `for`, `def`, `return`
- `and`, `or`, `not`, `is`, `in`, `pass`

### Comentários
- **Linha única:** `# comentário`
- **Bloco:** `"""comentário"""` ou `'''comentário'''`

## Configuração do Ambiente

### Pré-requisitos
- WSL (Windows Subsystem for Linux) ou Linux
- Flex e Bison
- GCC (compilador C)
- Make

### Instalação das Ferramentas

#### No WSL/Ubuntu:
```bash
# Atualizar sistema
sudo apt update && sudo apt upgrade -y

# Instalar ferramentas de desenvolvimento
sudo apt install -y build-essential flex bison make

# Verificar instalação
flex --version
bison --version
gcc --version
```

#### No Windows (PowerShell como Administrador):
```powershell
# Instalar WSL
wsl --install

# Instalar Ubuntu
wsl --install -d Ubuntu
```

## Como Usar

### Compilação
```bash
# Método 1: Script automático (Recomendado)
chmod +x compilar.sh
./compilar.sh

# Método 2: Make
make clean
make

# Método 3: Manual
flex lexer/lexer.l
bison -d -v -o parser.tab.c parser/parser.y
gcc -Wall -Wextra -std=c99 -c lex.yy.c -o lex.yy.o
gcc -Wall -Wextra -std=c99 -c parser.tab.c -o parser.tab.o
gcc -Wall -Wextra -std=c99 -c src/main.c -o src/main.o
gcc -Wall -Wextra -std=c99 -o compilador lex.yy.o parser.tab.o src/main.o -lfl
```

### Execução
```bash
# Executar com entrada interativa
./compilador

# Executar com arquivo
./compilador arquivo.txt

# Exemplo de uso
echo "3 + 4 * 2" | ./compilador
```

### Testes
```bash
# Executar suite completa de testes (32 testes)
chmod +x testes.sh
./testes.sh

# Testes manuais
echo "3 + 4" | ./compilador
echo "2 * (3 + 4)" | ./compilador
echo "-5 + 3" | ./compilador
```

## Exemplos de Uso

### Expressões Aritméticas
```bash
# Operações básicas
echo "3 + 4" | ./compilador          # Resultado: 7
echo "10 - 3" | ./compilador         # Resultado: 7
echo "2 * 5" | ./compilador          # Resultado: 10
echo "15 / 3" | ./compilador         # Resultado: 5

# Precedência de operadores
echo "2 + 3 * 4" | ./compilador      # Resultado: 14
echo "(2 + 3) * 4" | ./compilador    # Resultado: 20

# Números negativos
echo "-5" | ./compilador             # Resultado: -5
echo "-3 + 7" | ./compilador         # Resultado: 4
```

### Testes Automatizados por Script
O projeto inclui 32 testes automatizados que cobrem:
- Operações básicas (+, -, *, /)
- Precedência de operadores
- Números negativos
- Parênteses complexos
- Divisão (incluindo divisão por zero)
- Expressões longas
- Casos especiais
- Expressões com espaços

## Solução de Problemas

### Erro: "make: command not found"
```bash
sudo apt install -y make
```

### Erro: "flex: command not found"
```bash
sudo apt install -y flex
```

### Erro: "bison: command not found"
```bash
sudo apt install -y bison
```

### Erro: "gcc: command not found"
```bash
sudo apt install -y build-essential
```

## Grupo 09

Desenvolvido para a disciplina Compiladores 1 - Universidade de Brasília
