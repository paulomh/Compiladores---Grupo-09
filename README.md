# Compilador Python - Grupo 09

[![Linguagem](https://img.shields.io/badge/linguagem-Python-blue)](https://www.python.org/)
[![Flex](https://img.shields.io/badge/flex-2.6+-green)](https://github.com/westes/flex)
[![Bison](https://img.shields.io/badge/bison-3.8+-green)](https://www.gnu.org/software/bison/)

> Compilador para subconjunto Python desenvolvido para a disciplina **Compiladores 1** - UnB/2025.2

Este projeto implementa um **compilador funcional para subconjunto Python** com foco em expressões aritméticas, estruturas de controle e gerenciamento completo de indentação Python. Atualmente suporta análise léxica e sintática completas com avaliação de expressões.

## Funcionalidades Implementadas

- **Análise Léxica**: Reconhecimento completo de tokens Python usando Flex
- **Análise Sintática**: Parser funcional com gramática Python usando Bison  
- **Avaliação de Expressões**: Cálculo de expressões aritméticas e lógicas
- **Indentação Python**: Gerenciamento de INDENT/DEDENT
- **Estruturas de Controle**: Parsing de if/else, funções, loops
- **Análise Semântica**: Em desenvolvimento
- **Geração de Código**: Planejado

## Equipe de Desenvolvimento

| <img src="https://github.com/xzxjesse.png" width="100px"> | <img src="https://github.com/Ruan-Carvalho.png" width="100px"> | <img src="https://github.com/paulomh.png" width="100px"> | <img src="https://github.com/LucasAvelar2711.png" width="100px"> |
| :-------------------------------------------------------: | :-------------------------------------------------------: | :----------------------------------------------------------: | :-------------------------------------------------------------: |
| **[Jesse Eveline](https://github.com/xzxjesse)**<br/>*Análise Léxica* | **[Ruan Carvalho](https://github.com/Ruan-Carvalho)**<br/>*Análise Sintática* | **[Paulo Henrique](https://github.com/paulomh)**<br/>*Análise Semântica* | **[Lucas Avelar](https://github.com/LucasAvelar2711)**<br/>*Geração de Código* |

## Arquitetura Implementada

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│ Código Python   │──▶│ Análise Léxica   │───▶│   Tokens       │
│    (.py)        │    │    (Flex)       │    │   + Indentação  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                                        │
                       ┌─────────────────┐    ┌─────────▼─────────┐
                       │   Resultado     │◀───│ Análise Sintática│
                       │  (Avaliação)    │    │    (Bison)        │
                       └─────────────────┘    └───────────────────┘
```

## Documentação Disponível

- **[Características Técnicas](Caracteristicas%20Tecnicas.md)**: Especificações técnicas detalhadas da implementação
- **[Configuração do Ambiente](Configuracao%20Ambiente.md)**: Guia completo de setup e instalação  
- **[Guia de Contribuição](CONTRIBUTING.md)**: Workflow e padrões de desenvolvimento específicos para compiladores

## Status do Projeto

### Atual: 
- [x] Formação da equipe e organização inicial
- [x] Configuração do ambiente de desenvolvimento
- [x] Definição da linguagem-fonte (subconjunto Python)
- [x] Elaboração da gramática formal Python
- [x] Implementação do analisador léxico
- [x] Implementação do analisador sintático
- [x] Sistema de gerenciamento de indentação
- [x] Avaliação de expressões aritméticas

### Próximas Etapas
- Análise semântica (tabela de símbolos, verificação de tipos)
- Geração de código intermediário e execução de variáveis
- Suporte a funções e otimizações básicas
- Documentação completa

### Componentes Implementados

#### **Analisador Léxico** (`lexer/lexer.l`)
- **Ferramenta**: Flex
- **Funcionalidades**: 
  - Reconhecimento de tokens Python
  - Gerenciamento de indentação (INDENT/DEDENT)
  - Suporte a comentários (linha única e múltiplas linhas)
  - Números inteiros e decimais com sinal
  - Strings com aspas simples e duplas
- **Tokens**: 46+ tipos diferentes

#### **Analisador Sintático** (`parser/parser.y`)
- **Ferramenta**: Bison
- **Funcionalidades**:
  - Gramática Python com precedência de operadores
  - Estruturas de controle (if/else)
  - Definições de função (def)
  - Avaliação de expressões aritméticas e lógicas
- **Ações Semânticas**: Cálculo direto de resultados

#### **Programa Principal** (`src/main.c`)
- **Funcionalidades**:
  - Interface de linha de comando
  - Suporte a entrada via arquivo ou stdin  
  - Inicialização do compilador
  - Tratamento de erros básico

## Funcionalidades vs. Limitações

### **O que FUNCIONA**
- Reconhecimento completo de tokens Python
- Parsing de estruturas de controle (if/else, def, while, for)
- Avaliação de expressões aritméticas complexas
- Operadores lógicos (and, or, not)
- Gerenciamento de indentação Python (INDENT/DEDENT)
- Sistema de testes
- Tratamento de comentários (linha única e múltiplas linhas)

### **Limitações Atuais**
- **Variáveis**: Não armazena/recupera valores de variáveis
- **Funções**: Apenas parsing, sem execução real
- **Loops**: Reconhece sintaxe mas não executa iterações  
- **Tipos**: Conversão limitada (float → int)
- **Escopo**: Sem tabela de símbolos implementada

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
  <strong>Compilador Python Funcional - Grupo 09</strong><br>
  <sub>Universidade de Brasília - Compiladores 1 - 2025.2</sub><br><br>
  <em>"Do código Python ao resultado: análise léxica e sintática completas!"</em>
</div>
