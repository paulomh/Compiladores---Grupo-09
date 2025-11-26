# Compilador Python - Grupo 09

[![Linguagem](https://img.shields.io/badge/linguagem-Python-blue)](https://www.python.org/)
[![Flex](https://img.shields.io/badge/flex-2.6+-green)](https://github.com/westes/flex)
[![Bison](https://img.shields.io/badge/bison-3.8+-green)](https://www.gnu.org/software/bison/)

## Sumário

- [Visão Geral](#visão-geral)
- [Funcionalidades Implementadas](#funcionalidades-implementadas)
- [Equipe de Desenvolvimento](#equipe-de-desenvolvimento)
- [Documentação Disponível](#documentação-disponível)
- [Como Contribuir](#como-contribuir)
- [Informações do Projeto](#informações-do-projeto)

---

## Visão Geral

> Compilador para subconjunto Python desenvolvido para a disciplina **Compiladores 1** - UnB/2025.2

Este projeto implementa um **compilador funcional para subconjunto Python** com foco em expressões aritméticas, estruturas de controle e gerenciamento completo de indentação Python. Atualmente suporta análise léxica e sintática completas com avaliação de expressões.

## Funcionalidades Implementadas

### Análise Léxica 
- Reconhecimento completo de tokens Python usando Flex
- Suporte a palavras-chave: `if`, `else`, `while`, `for`, `def`, `return`, `and`, `or`, `not`
- Operadores aritméticos: `+`, `-`, `*`, `/`, `%`, `^` (exponenciação), `//` (divisão inteira)
- Operadores comparação: `==`, `!=`, `<`, `>`, `<=`, `>=`
- Operadores atribuição: `=`, `+=`, `-=`, `*=`, `/=`, `%=`
- Números inteiros e ponto flutuante
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

## Equipe de Desenvolvimento

| <img src="https://github.com/xzxjesse.png" width="100px"> | <img src="https://github.com/Ruan-Carvalho.png" width="100px"> | <img src="https://github.com/paulomh.png" width="100px"> | <img src="https://github.com/LucasAvelar2711.png" width="100px"> |
| :-------------------------------------------------------: | :-------------------------------------------------------: | :----------------------------------------------------------: | :-------------------------------------------------------------: |
| **[Jesse Eveline](https://github.com/xzxjesse)**<br/> | **[Ruan Carvalho](https://github.com/Ruan-Carvalho)**<br/>| **[Paulo Henrique](https://github.com/paulomh)**<br/> | **[Lucas Avelar](https://github.com/LucasAvelar2711)** |

## Documentação Disponível

- **[Características Técnicas](Docs/Caracteristicas%20Tecnicas.md)**: Especificações detalhadas de arquitetura, build e testes
- **[Configuração do Ambiente](Docs/Configuracao%20Ambiente.md)**: Guia de instalação e setup
- **[Testes](Docs/Testes.md)**: Documentação completa do sistema de testes (48 testes, 7 categorias)
- **[Guia de Contribuição](CONTRIBUTING.md)**: Workflow de desenvolvimento e padrões de commits

## Como Contribuir

Consulte nosso [**Guia de Contribuição**](CONTRIBUTING.md) que inclui:
- Padrões de commits específicos para compiladores
- Workflow de branches por componente
- Checklist de code review para cada fase
- Templates de PR e testes

## Informações do Projeto

- **Professor**: Sérgio Freitas (sergiofreitas@unb.br)
- **Disciplina**: Compiladores 1 - UnB/2025.2  
- **Semestre**: 2025.2
- **Universidade**: Universidade de Brasília (UnB)

---

<div align="center">
  <strong>Grupo 09</strong><br>
  <sub>Universidade de Brasília - Compiladores 1 - 2025.2</sub><br><br>
</div>
