# Padronização dos Commits e Branches

## Introdução

Este documento define as diretrizes para padronização dos commits e organização das branches no repositório do projeto. O objetivo é facilitar a colaboração entre os membros do time, garantir rastreabilidade e manter a consistência no fluxo de trabalho.

## Commits

Conforme as diretrizes do [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/), utilizaremos commits semânticos para garantir a compreensão clara das mudanças no histórico do projeto. Essa convenção facilita a rastreabilidade e a padronização.

### Tipos de Commit

| Tipo | Descrição | Impacto |
|------|-----------|---------|
| **feat** | Adição de um novo recurso | MINOR |
| **fix** | Correção de um bug | PATCH |
| **docs** | Alterações na documentação | - |
| **test** | Modificações em testes | - |
| **build** | Alterações em arquivos de build e dependências | - |
| **perf** | Ajustes de performance | - |
| **style** | Alterações de formatação, sem impacto no código | - |
| **refactor** | Refatorações que não mudam a funcionalidade | - |
| **chore** | Tarefas de configuração e manutenção | - |
| **ci** | Mudanças relacionadas à integração contínua | - |
| **raw** | Arquivos de configuração e parâmetros | - |
| **cleanup** | Remoção de código desnecessário e ajustes de legibilidade | - |
| **remove** | Exclusão de arquivos ou funcionalidades obsoletas | - |

### Recomendação de commit:

- Comece o commit colocando o seu tipo, seguido de ":" e uma breve descrição do que foi feito.
- Escreva na terceira pessoa.
- Inicie a descrição com letra maiúscula e finalize com um ponto final.
- (Opcional) Detalhe mais a fundo o que foi feito na descrição do commit.

**Exemplo:** `git commit -m "docs: Revisa a metodologia."`

## Branches

### Branches Principais

| Branch | Descrição | Restrições |
|--------|-----------|------------|
| **main** | Contém o código estável | Somente alterações revisadas e aprovadas que passaram pela develop devem ser mescladas nesta branch. **Nenhuma alteração deve ser feita diretamente aqui.** |
| **gh-pages** | Utilizada para hospedar a versão estática do site do projeto | Atualizada automaticamente com base nas mudanças na branch **docs** |
| **docs** | Dedicada à documentação do projeto | Após revisão, todas as atualizações devem ser mescladas nesta branch |
| **develop** | Contém o código em desenvolvimento | Todas as branches relacionadas ao desenvolvimento de funcionalidades ou correções de código devem partir desta branch |

### Branches Secundárias

As branches secundárias são criadas temporariamente para atender demandas específicas, como o desenvolvimento de funcionalidades, correção de bugs ou atualização de documentação. Elas devem ser removidas após a conclusão da tarefa e o merge, garantindo a organização do repositório.

#### 1. Desenvolvimento de Código

| Atributo | Especificação |
|----------|---------------|
| **Origem** | Branches de código devem ser criadas a partir da branch **develop** |
| **Prefixo** | `dev:` seguido de uma descrição clara e objetiva da tarefa |
| **Exemplos** | `dev:feature-pomodoro`<br>`dev:fix-login-bug` |

#### 2. Atualização de Documentação

| Atributo | Especificação |
|----------|---------------|
| **Origem** | Branches relacionadas à documentação devem ser criadas a partir da branch **docs** |
| **Prefixo** | `doc:` seguido de uma descrição clara da tarefa |
| **Exemplos** | `doc:update-readme`<br>`doc:guide-setup` |
