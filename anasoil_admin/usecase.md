AnaSoil

Especificação de Caso de Uso: Gerenciar Usuários

Versão 1.0

# Breve Descrição

Este caso de uso permite que o ator Administrador realize o gerenciamento completo dos usuários do sistema AnaSoil. Isso inclui a criação, consulta, edição e exclusão de contas de usuário, bem como a atribuição de seus respectivos perfis de acesso (como Agricultor, Consultor ou outro Administrador) para garantir a governança de dados adequada.

# Fluxo Básico de Eventos

- O caso de uso inicia quando o Administrador, já autenticado no sistema, seleciona a opção de gerenciamento de usuários.
- O sistema exibe uma lista de todos os usuários cadastrados, apresentando informações como nome, e-mail e perfil.
- O Administrador seleciona uma das seguintes operações: "Criar Novo Usuário", "Editar Usuário" ou "Excluir Usuário".
  - **Criar Novo Usuário:**
    - O sistema apresenta um formulário para o cadastro de um novo usuário.
    - O Administrador preenche os dados solicitados (ex: nome, e-mail, senha provisória) e seleciona o perfil (Agricultor, Consultor, etc.).
    - O Administrador confirma a operação.
    - O sistema valida os dados, cria o novo usuário no banco de dados e exibe uma mensagem de sucesso.
  - **Editar Usuário:**
    - O Administrador seleciona um usuário da lista e clica na opção "Editar".
    - O sistema exibe um formulário com os dados atuais do usuário selecionado.
    - O Administrador modifica as informações desejadas (ex: nome, perfil).
    - O Administrador confirma a alteração.
    - O sistema valida os dados, atualiza as informações do usuário no banco de dados e exibe uma mensagem de sucesso.
  - **Excluir Usuário:**
    - O Administrador seleciona um usuário da lista e clica na opção "Excluir".
    - O sistema solicita uma confirmação para a exclusão.
    - O Administrador confirma a exclusão.
    - O sistema altera o estado de ativo do usuário no banco de dados para false exibe uma mensagem de sucesso.
- A lista de usuários é atualizada para refletir a alteração realizada.

# Fluxos Alternativos

#### **3.1 A1 - Dados Inválidos ou Incompletos**

- Se, no passo **Criar Novo Usuário**, passo iv ou **Editar Usuário**, passo v do fluxo básico, o Administrador inserir dados inválidos (ex: formato de e-mail incorreto) ou deixar campos obrigatórios em branco, o sistema não salvará as informações. Em vez disso, exibirá uma mensagem de erro indicando o(s) campo(s) que precisa(m) ser corrigido(s) e aguardará a correção pelo Administrador.

#### **3.2 A2 - Tentativa de Excluir o Próprio Usuário**

- Se, no passo **Excluir Usuário,** passo i, do fluxo básico, o Administrador tentar excluir a sua própria conta de usuário, o sistema exibirá uma mensagem de erro informando que a operação não é permitida e a ação será cancelada.

# Cenários Chave

# 4.1 Cenário 1**: Criação de um Novo Usuário com Sucesso**

- **Pré-condição:** O Administrador deve estar logado no sistema e na tela de gerenciamento de usuários.
- **Passos:**
  - O Administrador seleciona a opção "Criar Novo Usuário".
  - Preenche todos os campos obrigatórios do formulário com dados válidos (nome, e-mail único, senha provisória).
  - Seleciona o perfil "Agricultor".
  - Clica em "Salvar".
- **Resultado Esperado:**
  - Um novo registro de usuário é criado no banco de dados.
  - O novo usuário aparece na lista de usuários cadastrados com o perfil "Agricultor".

#### **4.2 Cenário 2 (Alternativo): Tentativa de Criar Usuário com E-mail Duplicado**

- **Pré-condição:** O Administrador deve estar logado e tentando criar um novo usuário.
- **Passos:**
  - O Administrador preenche o formulário com um e-mail que já está em uso por outro usuário.
  - Clica em "Salvar".
- **Resultado Esperado:**
  - O novo usuário não é criado e o sistema dispara uma mensagem para o usuário.

#### **4.3 Cenário 3 (Alternativo): Tentativa de Excluir o Próprio Usuário**

- **Pré-condição:** O Administrador deve estar logado no sistema.
- **Passos:**
  - O Administrador seleciona sua própria conta de usuário na lista.
  - Clica em "Excluir".
- **Resultado Esperado:**
  - A operação de exclusão é cancelada.

# Condições Prévias

## Autenticação Prévia

O Administrador deve estar logado no sistema AnaSoil para ter acesso à funcionalidade de gerenciamento de usuários.

# Condições Posteriores

## Sucesso na Criação

Um novo registro de usuário é criado e armazenado no sistema.

## Sucesso na Edição

As informações do usuário selecionado são atualizadas no sistema.

## Sucesso na Exclusão

O usuário selecionado é desativado do sistema.

# Requisitos Especiais

## Governança de Dados

O sistema deve garantir que os dados sejam protegidos entre os diferentes perfis de usuário, com cada um tendo seu nível de acesso claramente definido.

## Integridade dos Dados

Todas as operações (criação, edição, exclusão) devem ser realizadas de forma íntegra para garantir que nenhum dado seja perdido ou modificado incorretamente, assegurando a assertividade das informações do sistema.

## Autenticação

Este caso de uso é a base para o requisito de que todo acesso ao aplicativo exige um cadastro prévio, pois é aqui que as contas de acesso são criadas e mantidas, apenas pelo Administrador do sistema.
