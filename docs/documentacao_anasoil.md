# Documentação Técnica: Projeto AnaSoil

Este documento descreve a arquitetura e os fluxos de comportamento do sistema **AnaSoil**, utilizando a notação UML via Mermaid.js. A documentação segue as diretrizes do **RUP (Rational Unified Process)** e adota o padrão de design **EBC (Entity-Boundary-Control)**.

---

## 1. Diagrama de Classes (Modelo de Projeto)

Este diagrama representa a estrutura estática do sistema, dividida em camadas de Fronteira (Boundary), Controle (Control) e Entidade (Entity), além dos serviços de integração. O modelo reflete a implementação **RBAC (Role-Based Access Control)** conforme o código-fonte desenvolvido em Flutter.

```mermaid
classDiagram
    %% ==========================================
    %% FRONTEIRAS (BOUNDARY) - UIs e Telas
    %% ==========================================
    class LoginPage {
        <<Boundary>>
        +build()
    }
    class HomePage {
        <<Boundary>>
        +build()
    }
    class ProfilePage {
        <<Boundary>>
        +build()
    }
    class AnalysisPage {
        <<Boundary>>
        +build()
    }
    class FarmersListPage {
        <<Boundary>>
        +build()
    }
    class DocumentsPage {
        <<Boundary>>
        +build()
    }

    %% ==========================================
    %% CONTROLES (CONTROL) - ViewModels
    %% ==========================================
    class AuthViewModel {
        <<Control>>
        +login()
        +logout()
    }
    class ProfileViewModel {
        <<Control>>
        +loadProfile()
        +updateProfile()
        +changePassword()
    }
    class AnalysisViewModel {
        <<Control>>
        +processDocument()
        +loadHistory()
    }
    class FarmersViewModel {
        <<Control>>
        +loadLinkedFarmers()
        +linkFarmer()
    }
    class UserFormViewModel {
        <<Control>>
        +createUser()
        +deleteUser()
    }

    %% ==========================================
    %% ACESSO A DADOS (SERVICES / REPOSITORIES)
    %% ==========================================
    class AuthRepository {
        <<Service>>
        +signIn()
        +reauthenticateUser()
        +registerUser()
    }
    class ProfileRepository {
        <<Service>>
        +getUserData()
        +updateUserData()
        +linkUserByEmail()
    }
    class DocumentRepository {
        <<Service>>
        +uploadDocument()
    }
    class SoilAnalysisRepository {
        <<Service>>
        +saveAnalysis()
        +getHistory()
    }
    class ExtractionService {
        <<Service>>
        +extractText()
    }

    %% ==========================================
    %% ENTIDADES (ENTITY) - Domínio
    %% ==========================================
    class User {
        <<Entity>>
        +String id
        +String name
        +String email
        +ProfileType profileType
    }
    class Document {
        <<Entity>>
        +String id
        +String url
    }
    class SoilAnalysis {
        <<Entity>>
        +String id
        +DateTime createdAt
        +List parameters
    }
    class ProfileType {
        <<enumeration>>
        farmer
        consultant
        admin
    }

    %% Relacionamentos
    LoginPage --> AuthViewModel
    ProfilePage --> ProfileViewModel
    AnalysisPage --> AnalysisViewModel
    FarmersListPage --> FarmersViewModel
    
    AuthViewModel --> AuthRepository
    ProfileViewModel --> ProfileRepository
    ProfileViewModel --> AuthRepository
    AnalysisViewModel --> DocumentRepository
    AnalysisViewModel --> SoilAnalysisRepository
    AnalysisViewModel --> ExtractionService
    FarmersViewModel --> ProfileRepository
    UserFormViewModel --> AuthRepository
    UserFormViewModel --> ProfileRepository

    User --> ProfileType
```

2. Diagramas de Sequência (Casos de Uso)

Os diagramas abaixo ilustram a troca de mensagens entre os objetos do sistema durante a execução de cada funcionalidade chave, demonstrando a interação entre a Interface (Boundary), a Regra de Negócio (Control) e a Persistência de Dados (Services/Repository).

UC01: Importar Documento

```mermaid
sequenceDiagram
    autonumber
    actor A as Agricultor/Consultor
    participant UI as <<Boundary>><br>DocumentsPage
    participant VM as <<Control>><br>AnalysisViewModel
    participant File as <<Service>><br>FilePicker
    participant Repo as <<Service>><br>DocumentRepository

    A->>UI: Clica em "Importar Documento"
    UI->>File: Abrir seletor de arquivos
    File-->>UI: Retorna arquivo selecionado
    UI->>VM: uploadDocument(file)
    
    alt Arquivo Inválido
        VM-->>UI: Retorna Erro
        UI-->>A: Exibe alerta "Formato Inválido"
    else Arquivo Válido
        VM->>Repo: uploadDocument(file, userId)
        Repo-->>VM: Sucesso (URL)
        VM->>VM: disparar processDocument() (Inicia UC02)
        VM-->>UI: Notifica conclusão
        UI-->>A: Redireciona para Dashboard
    end
```

UC02: Gerar Análise

```mermaid
sequenceDiagram
    autonumber
    participant UI as <<Boundary>><br>AnalysisPage
    participant VM as <<Control>><br>AnalysisViewModel
    participant Ext as <<Service>><br>ExtractionService
    participant Repo as <<Service>><br>SoilAnalysisRepository

    note over VM: Acionado após upload (UC01)
    VM->>Ext: extractText(fileUrl)
    Ext-->>VM: rawData
    VM->>VM: applyAgronomicRules(rawData)
    
    opt Parâmetros Ausentes
        VM->>VM: Adiciona "Aviso de dados omitidos" ao objeto
    end

    VM->>Repo: saveAnalysis(soilAnalysis)
    Repo-->>VM: Sucesso
    VM-->>UI: Atualiza Estado (State = Loaded)
    UI-->>A: Renderiza Gráficos (Dashboard)
```

UC03: Consultar Histórico

```mermaid
sequenceDiagram
    autonumber
    actor A as Agricultor/Consultor
    participant UI as <<Boundary>><br>HistoryPage
    participant VM as <<Control>><br>AnalysisViewModel
    participant Repo as <<Service>><br>SoilAnalysisRepository

    A->>UI: Acessa aba "Histórico"
    UI->>VM: loadHistory(userId)
    
    opt Filtro por Período
        UI->>VM: Aplica range de datas
    end

    VM->>Repo: getHistory(userId, filters)
    Repo-->>VM: List<SoilAnalysis>
    
    alt Lista Vazia
        VM-->>UI: State = Empty
        UI-->>A: Exibe ilustração de convite para upload
    else Dados Encontrados
        VM-->>UI: State = Success(List)
        UI-->>A: Renderiza lista em ordem decrescente
    end
```

UC04: Gerenciar Agricultores

```mermaid
sequenceDiagram
    autonumber
    actor C as Consultor
    participant UI as <<Boundary>><br>FarmersListPage
    participant VM as <<Control>><br>FarmersViewModel
    participant Repo as <<Service>><br>ProfileRepository

    C->>UI: Digita e-mail e clica "Vincular"
    UI->>VM: linkFarmer(email)
    VM->>Repo: linkUserByEmail(consultantId, email)
    
    alt Agricultor Não Encontrado
        Repo-->>VM: Exception(UserNotFound)
        VM-->>UI: Retorna Erro
        UI-->>C: Exibe alerta "Agricultor não encontrado"
    else Agricultor Encontrado
        Repo-->>VM: Vínculo Confirmado
        VM-->>UI: Atualiza a lista
        UI-->>C: Exibe "Vínculo criado com sucesso!"
    end
```

UC05: Gerenciar Perfil

```mermaid
sequenceDiagram
    autonumber
    actor A as Usuário Logado
    participant UI as <<Boundary>><br>ProfilePage
    participant VM as <<Control>><br>ProfileViewModel
    participant Auth as <<Service>><br>AuthRepository
    participant Repo as <<Service>><br>ProfileRepository

    opt Alterar Dados Cadastrais
        A->>UI: Edita telefone/nome e salva
        UI->>VM: updateProfile(userData)
        VM->>Repo: updateUserData(userData)
        Repo-->>VM: Sucesso
        VM-->>UI: Status de Sucesso
    end

    opt Alterar Senha (Sensível)
        A->>UI: Preenche Senha Atual e Nova
        UI->>VM: changePassword(currentPass, newPass)
        VM->>Auth: reauthenticateUser(currentPass)
        
        alt Senha Atual Incorreta
            Auth-->>VM: Exception
            VM-->>UI: Erro de Autenticação
        else Reautenticação Sucesso
            VM->>Auth: updatePassword(newPass)
            Auth-->>VM: Sucesso
            VM-->>UI: Notifica sucesso
        end
    end
```

UC06: Gerenciar Usuários (Administrador)

```mermaid
sequenceDiagram
    autonumber
    actor Ad as Administrador
    participant UI as <<Boundary>><br>UserFormPage
    participant VM as <<Control>><br>UserFormViewModel
    participant Auth as <<Service>><br>AuthRepository
    participant Repo as <<Service>><br>ProfileRepository

    Ad->>UI: Preenche formulário de novo usuário
    UI->>VM: createUser(email, pass, role)
    VM->>Auth: registerUser(email, pass)
    
    alt E-mail Duplicado
        Auth-->>VM: Exception(EmailAlreadyInUse)
        VM-->>UI: Retorna Erro
        UI-->>Ad: Exibe alerta de erro
    else Credencial Criada
        Auth-->>VM: UID Gerado
        VM->>Repo: saveUserData(UID, role)
        Repo-->>VM: Sucesso no Banco de Dados
        VM-->>UI: Notifica conclusão
        UI-->>Ad: Exibe sucesso e retorna para a listagem
    end
```
