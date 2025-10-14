# Configuração do Ambiente de Desenvolvimento

## Visão Geral

Este documento fornece instruções completas para configurar o ambiente de desenvolvimento necessário para o projeto do compilador. Seguindo estas instruções, você terá todas as ferramentas necessárias para compilar, testar e desenvolver o compilador do **Grupo 09**.

## Pré-requisitos

### Sistemas Operacionais Suportados
- **Linux** (Ubuntu 20.04+, Debian 11+, Fedora 35+)
- **macOS** (10.15+)
- **Windows** (via WSL2)

### Ferramentas Essenciais
- **Flex** 2.6.0+ (Gerador de analisador léxico)
- **Bison** 3.8.0+ (Gerador de analisador sintático)
- **GCC** 9.0+ (Compilador C/C++)
- **Make** 4.0+ (Sistema de build)
- **Git** 2.25+ (Controle de versão)

## Instalação no Linux (Ubuntu/Debian)

### Método Automatizado (Recomendado)

```bash
# Clone o repositório
git clone https://github.com/usuario/compilador-grupo09.git
cd compilador-grupo09

# Execute o script de instalação
chmod +x scripts/install-deps.sh
./scripts/install-deps.sh
```

### Instalação Manual

```bash
# 1. Atualizar sistema
sudo apt update && sudo apt upgrade -y

# 2. Instalar ferramentas de desenvolvimento essenciais
sudo apt install -y build-essential

# 3. Instalar Flex e Bison
sudo apt install -y flex bison

# 4. Instalar ferramentas adicionais
sudo apt install -y make git valgrind gdb

# 5. Instalar bibliotecas de desenvolvimento
sudo apt install -y libc6-dev

# 6. Verificar instalações
echo "=== Verificando Instalações ==="
flex --version
bison --version
gcc --version
make --version
git --version
```

## Instalação no macOS

### Usando Homebrew (Recomendado)

```bash
# 1. Instalar Homebrew (se não tiver)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2. Instalar ferramentas
brew install flex bison gcc make git

# 3. Configurar PATH para usar as versões do Homebrew
echo 'export PATH="/opt/homebrew/opt/flex/bin:$PATH"' >> ~/.zshrc
echo 'export PATH="/opt/homebrew/opt/bison/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

# 4. Verificar instalações
flex --version
bison --version
gcc --version
```

### Usando MacPorts

```bash
# 1. Instalar MacPorts (se não tiver)
# Baixe de: https://www.macports.org/install.php

# 2. Instalar ferramentas
sudo port install flex bison gcc12 gmake git

# 3. Verificar instalações
flex --version
bison --version
gcc-mp-12 --version
```

## Instalação no Windows (WSL2)

### Configuração Inicial do WSL2

```powershell
# 1. Executar como Administrador no PowerShell
# Habilitar WSL
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart

# Habilitar Virtual Machine Platform
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

# 2. Reiniciar o computador

# 3. Após reiniciar, definir WSL2 como padrão
wsl --set-default-version 2

# 4. Instalar Ubuntu
wsl --install -d Ubuntu-22.04

# 5. Configurar usuário e senha quando solicitado
```

### Configuração do Ambiente no WSL2

```bash
# 1. Atualizar sistema Ubuntu
sudo apt update && sudo apt upgrade -y

# 2. Instalar ferramentas de desenvolvimento
sudo apt install -y build-essential flex bison make git curl wget

# 3. Instalar ferramentas de debug
sudo apt install -y valgrind gdb

# 4. Configurar Git (substitua pelos seus dados)
git config --global user.name "Seu Nome"
git config --global user.email "seu.email@exemplo.com"

# 5. Verificar instalações
echo "=== Verificando Instalações no WSL2 ==="
flex --version
bison --version
gcc --version
make --version
```

## Configuração do Projeto

### Clonando o Repositório

```bash
# 1. Clone o repositório
git clone https://github.com/usuario/compilador-grupo09.git
cd compilador-grupo09

# 2. Configurar permissões dos scripts
chmod +x scripts/*.sh

# 3. Instalar dependências (se não fez anteriormente)
./scripts/install-deps.sh
```

### Estrutura de Diretórios

```bash
# Criar estrutura de diretórios necessária
mkdir -p {src/{lexer,parser,semantic,codegen},tests/{lexer,parser,semantic,integration},docs,scripts}
```

## Compilação e Build

### Usando Make (Recomendado)

```bash
# Compilar tudo
make all

# Compilar apenas o analisador léxico
make lexer

# Compilar apenas o analisador sintático
make parser

# Limpar arquivos gerados
make clean

# Recompilar tudo do zero
make rebuild
```

### Usando Scripts

```bash
# Script de build completo
./scripts/build.sh

# Script de build com debug
./scripts/build.sh --debug

# Script de build para release
./scripts/build.sh --release
```

### Compilação Manual (Para Debug)

```bash
# 1. Gerar analisador léxico
flex -o src/lexer/lex.yy.c src/lexer/lexer.l

# 2. Gerar analisador sintático
bison -d -v -o src/parser/parser.tab.c src/parser/parser.y

# 3. Compilar componentes
gcc -Wall -Wextra -std=c99 -g -c src/lexer/lex.yy.c -o build/lex.yy.o
gcc -Wall -Wextra -std=c99 -g -c src/parser/parser.tab.c -o build/parser.tab.o
gcc -Wall -Wextra -std=c99 -g -c src/main.c -o build/main.o

# 4. Linkar executável
gcc -Wall -Wextra -std=c99 -g -o bin/compilador build/*.o -lfl
```

## Execução e Testes

### Execução Básica

```bash
# Compilar um arquivo fonte
./bin/compilador examples/exemplo.src

# Executar com opções de debug
./bin/compilador examples/exemplo.src --debug --tokens --ast

# Executar com entrada interativa
./bin/compilador --interactive
```

### Testes Automatizados

```bash
# Executar todos os testes
make test

# Testes por componente
make test-lexer
make test-parser
make test-semantic
make test-codegen

# Testes de integração
make test-integration

# Testes com cobertura
make coverage
```

### Testes Manuais

```bash
# Testar analisador léxico
echo "int x = 42;" | ./bin/compilador --tokens

# Testar analisador sintático
echo "if (x > 0) { print(x); }" | ./bin/compilador --ast

# Testar análise semântica
./bin/compilador examples/semantic_test.src --semantic

# Testar geração de código
./bin/compilador examples/codegen_test.src --codegen
```

## Ferramentas de Desenvolvimento

### IDEs e Editores Recomendados

#### Visual Studio Code
```bash
# Extensões recomendadas
code --install-extension ms-vscode.cpptools
code --install-extension ms-vscode.cmake-tools
code --install-extension ms-vscode.makefile-tools
```

#### Vim/Neovim
```bash
# Plugins recomendados para ~/.vimrc
Plugin 'vim-syntastic/syntastic'
Plugin 'rhysd/vim-clang-format'
Plugin 'octol/vim-cpp-enhanced-highlight'
```

### Debugging

```bash
# Compilar com símbolos de debug
make debug

# Debug com GDB
gdb ./bin/compilador
(gdb) run examples/exemplo.src
(gdb) break main
(gdb) step

# Debug com Valgrind (detecção de vazamentos)
valgrind --leak-check=full ./bin/compilador examples/exemplo.src
```

### Profiling

```bash
# Compilar com profiling
make profile

# Executar com gprof
./bin/compilador examples/exemplo.src
gprof ./bin/compilador gmon.out > profile.txt
```

## Verificação da Instalação

### Script de Verificação Completa

```bash
#!/bin/bash
# scripts/verify-install.sh

echo "=== Verificação do Ambiente de Desenvolvimento ==="

# Verificar ferramentas
tools=("flex" "bison" "gcc" "make" "git")
for tool in "${tools[@]}"; do
    if command -v $tool &> /dev/null; then
        echo "$tool: $(command -v $tool)"
        $tool --version | head -n 1
    else
        echo "$tool: NÃO ENCONTRADO"
    fi
    echo
done

# Verificar compilação
echo "=== Testando Compilação ==="
if make test-build; then
    echo "Compilação: SUCESSO"
else
    echo "Compilação: FALHA"
fi

echo "=== Verificação Concluída ==="
```

### Executar Verificação

```bash
chmod +x scripts/verify-install.sh
./scripts/verify-install.sh
```


## Solução de Problemas

### Problemas Comuns de Instalação

#### Erro: "make: command not found"
```bash
# Ubuntu/Debian
sudo apt install -y make

# macOS
brew install make

# CentOS/RHEL/Fedora
sudo dnf install -y make
```

#### Erro: "flex: command not found"
```bash
# Ubuntu/Debian
sudo apt install -y flex

# macOS
brew install flex

# CentOS/RHEL/Fedora
sudo dnf install -y flex
```

#### Erro: "bison: command not found"
```bash
# Ubuntu/Debian
sudo apt install -y bison

# macOS
brew install bison

# CentOS/RHEL/Fedora
sudo dnf install -y bison
```

#### Erro: "gcc: command not found"
```bash
# Ubuntu/Debian
sudo apt install -y build-essential

# macOS
xcode-select --install

# CentOS/RHEL/Fedora
sudo dnf groupinstall -y "Development Tools"
```

### Problemas de Compilação

#### Erro: "lex.yy.c: No such file or directory"
```bash
# Gerar arquivo léxico manualmente
flex -o src/lexer/lex.yy.c src/lexer/lexer.l
```

#### Erro: "parser.tab.h: No such file or directory"
```bash
# Gerar arquivos do parser com headers
bison -d -v -o src/parser/parser.tab.c src/parser/parser.y
```

#### Erro: "undefined reference to `yywrap'"
```bash
# Adicionar flag -lfl na linkagem
gcc -o compilador *.o -lfl
```

#### Erro: "conflicting types for 'yylex'"
```bash
# Adicionar declaração no arquivo .y
%{
extern int yylex(void);
%}
```

### Problemas no WSL2

#### Erro: "WSL 2 requires an update to its kernel component"
```bash
# Baixar e instalar o kernel update do WSL2
# https://aka.ms/wsl2kernel
```

#### Performance lenta no WSL2
```bash
# Trabalhar dentro do sistema de arquivos do WSL
cd ~
# Evitar trabalhar em /mnt/c/
```

#### Problema com permissões de arquivo
```bash
# Configurar permissões corretas
chmod +x scripts/*.sh
chmod 644 src/**/*.{c,h,l,y}
```

### Problemas no macOS

#### Erro: "bison version too old"
```bash
# Usar versão do Homebrew
export PATH="/opt/homebrew/opt/bison/bin:$PATH"
```

#### Erro: "flex version too old"
```bash
# Usar versão do Homebrew
export PATH="/opt/homebrew/opt/flex/bin:$PATH"
```

### Problemas de Versionamento

#### Verificar versões mínimas
```bash
# Script para verificar versões
#!/bin/bash
echo "Verificando versões mínimas..."

# Flex >= 2.6.0
flex_version=$(flex --version | head -n1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
echo "Flex: $flex_version (mínimo: 2.6.0)"

# Bison >= 3.8.0
bison_version=$(bison --version | head -n1 | grep -oE '[0-9]+\.[0-9]+')
echo "Bison: $bison_version (mínimo: 3.8)"

# GCC >= 9.0
gcc_version=$(gcc --version | head -n1 | grep -oE '[0-9]+\.[0-9]+')
echo "GCC: $gcc_version (mínimo: 9.0)"
```

## Suporte e Ajuda

### Canais de Comunicação

- **Issues do GitHub**: Para reportar bugs e problemas técnicos
- **Discussions**: Para dúvidas gerais e discussões

### Recursos Adicionais

- **[Documentação do Flex](https://github.com/westes/flex)**
- **[Manual do Bison](https://www.gnu.org/software/bison/manual/)**
- **[GCC Documentation](https://gcc.gnu.org/onlinedocs/)**
- **[Make Manual](https://www.gnu.org/software/make/manual/)**

### Logs de Debug

```bash
# Habilitar logs detalhados
export DEBUG=1
make clean && make all 2>&1 | tee build.log

# Verificar logs de compilação
cat build.log | grep -i error
cat build.log | grep -i warning
```

---

<div align="center">
  <strong>Configuração de Ambiente - Grupo 09</strong><br>
  <sub>Compiladores 1 - UnB/2025.2</sub>
</div>
