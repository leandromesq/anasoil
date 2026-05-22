# Documentação Técnica: Projeto AnaSoil

Este documento descreve a arquitetura e os fluxos de comportamento do sistema **AnaSoil**, utilizando a notação UML via Mermaid.js. A documentação segue as diretrizes do **RUP (Rational Unified Process)** e adota o padrão de design **EBC (Entity-Boundary-Control)**.

---

## 1. Diagrama de Classes (Modelo de Projeto)

Este diagrama representa a estrutura estática do sistema, dividida em camadas de Fronteira (Boundary), Controle (Control), Entidade (Entity) e Serviços de integração. O modelo reflete a implementação **RBAC (Role-Based Access Control)** conforme o código-fonte atual.

```mermaid
classDiagram
    %% ========== MOBILE BOUNDARY ==========
    class LoginPage {
        <<Boundary>>
        +build(BuildContext context)
    }
    class ResetPasswordPage {
        <<Boundary>>
        +build(BuildContext context)
    }
    class SplashPage {
        <<Boundary>>
        +build(BuildContext context)
    }
    class HomePage {
        <<Boundary>>
        +build(BuildContext context)
    }
    class HistoryPage {
        <<Boundary>>
        +build(BuildContext context)
    }
    class AnalysisPage {
        <<Boundary>>
        +build(BuildContext context)
    }
    class AnalysisDetailPage {
        <<Boundary>>
        +build(BuildContext context)
    }
    class ProfilePage {
        <<Boundary>>
        +build(BuildContext context)
    }
    class EditProfilePage {
        <<Boundary>>
        +build(BuildContext context)
    }
    class ChangePasswordPage {
        <<Boundary>>
        +build(BuildContext context)
    }
    class FarmersListPage {
        <<Boundary>>
        +build(BuildContext context)
    }
    class FarmerAnalysesPage {
        <<Boundary>>
        +build(BuildContext context)
    }
    class DocumentsPage {
        <<Boundary>>
        +build(BuildContext context)
    }
    class PdfPreviewPage {
        <<Boundary>>
        +build(BuildContext context)
    }

    %% ========== MOBILE CONTROL ==========
    class AuthViewModel {
        <<Control>>
        +login(LoginCredentials)
        +logout()
        +resetPassword(String)
        +loadCurrentUser()
    }
    class AnalysisViewModel {
        <<Control>>
        +uploadDocumentCommand
        +extractPdfCommand
        +saveAllExtractedAnalyses()
        +loadAnalysesCommand
    }
    class UploadFlow {
        <<Control>>
        +upload(File)
        +extract(File)
        +saveAll()
        +intakeState
    }
    class ProfileViewModel {
        <<Control>>
        +loadProfileCommand
        +updateProfileCommand
        +changePasswordCommand
    }
    class FarmersViewModel {
        <<Control>>
        +loadFarmers(String)
        +loadFarmerAnalyses(String)
        +loadAllFarmersAnalyses(String)
    }

    %% ========== MOBILE SERVICES / REPOSITORIES ==========
    class AuthRepository {
        <<Interface>>
        +login(LoginCredentials) Result~User~
        +logout() Result~void~
        +resetPassword(String) Result~void~
        +loadCurrentUser() Result~User?~
    }
    class ProfileRepository {
        <<Interface>>
        +getProfile() Result~UserProfile~
        +updateProfile(ProfileUpdateData) Result~void~
        +changePassword(PasswordUpdateData) Result~void~
    }
    class DocumentRepository {
        <<Interface>>
        +uploadDocument(File, String) Result~SoilDocument~
        +getDocuments() Result~List~
        +deleteDocument(String) Result~void~
    }
    class SoilAnalysisRepository {
        <<Interface>>
        +extractFromPdf(File) Result~List~
        +saveAnalysis(SoilAnalysis) Result~SoilAnalysis~
        +getAnalyses() Result~List~
        +deleteAnalysis(String) Result~void~
    }

    %% ========== MOBILE ENTITIES ==========
    class User {
        <<Entity>>
        +String id
        +String name
        +String email
        +ProfileType profileType
        +String? phone
        +String? avatarUrl
    }
    class SoilDocument {
        <<Entity>>
        +String id
        +String userId
        +String fileName
        +String fileUrl
        +DateTime createdAt
        +bool active
    }
    class SoilAnalysis {
        <<Entity>>
        +String id
        +String labNumber
        +String propertyName
        +DateTime analysisDate
        +double? organicMatter
        +double? phCacl2
        +double? al3Plus, ca2Plus, mg2Plus, kPlus
        +double? ctcEfetiva, ctcPh7
        +double? vPercent, pst, mPercent
        +bool active
    }
    class AnalysisIntakeState {
        <<Entity>>
        +AnalysisIntakeStep step
        +String? fileName
        +String? documentId
        +int extractedCount
    }
    class ProfileType {
        <<enumeration>>
        farmer
        consultant
        admin
    }

    %% ========== ADMIN BOUNDARY ==========
    class AdminLoginPage {
        <<Boundary>>
        +build(BuildContext context)
    }
    class UserListPage {
        <<Boundary>>
        +build(BuildContext context)
    }
    class UserFormPage {
        <<Boundary>>
        +build(BuildContext context)
    }
    class UserRelationPage {
        <<Boundary>>
        +build(BuildContext context)
    }
    class AdminAnalysisListPage {
        <<Boundary>>
        +build(BuildContext context)
    }
    class AdminAnalysisDetailPage {
        <<Boundary>>
        +build(BuildContext context)
    }
    class AdminDocumentListPage {
        <<Boundary>>
        +build(BuildContext context)
    }
    class AdminDocumentDetailPage {
        <<Boundary>>
        +build(BuildContext context)
    }

    %% ========== ADMIN CONTROL ==========
    class UserListViewModel {
        <<Control>>
        +fetchUsersCommand
        +deleteUserCommand
        +updateUserStatusCommand
    }
    class UserFormViewModel {
        <<Control>>
        +createUser(String, String, String)
        +updateUser(String, UserModel)
    }
    class UserRelationViewModel {
        <<Control>>
        +linkFarmerToConsultant(String, String)
        +unlinkFarmerFromConsultant(String, String)
    }
    class AdminAnalysisListViewModel {
        <<Control>>
        +fetchAnalysesCommand
        +deleteAnalysisCommand
    }
    class AdminDocumentListViewModel {
        <<Control>>
        +fetchDocumentsCommand
        +deleteDocumentCommand
    }

    %% ========== ADMIN SERVICES / REPOSITORIES ==========
    class AdminSession {
        <<Service>>
        +isAuthenticated
        +email
        +signOut()
    }
    class AuthService {
        <<Service>>
        +signIn(String, String)
        +signOut()
        +createAuthUser(String)
    }
    class FirestoreService {
        <<Service>>
        +getUsers() Stream~List~
        +getDocuments() Stream~List~
        +getAnalyses() Stream~List~
        +addUser(String, UserModel)
        +linkFarmerToConsultant(String, String)
        +unlinkFarmerFromConsultant(String, String)
    }
    class UserRepository {
        <<Repository>>
        +getUsers() Future~List~
        +deleteUser(String)
        +updateUserStatus(String, bool)
    }
    class AnalysisRepository {
        <<Repository>>
        +getAnalyses() Future~List~
        +getById(String) Future~SoilAnalysisModel?~
        +deleteAnalysis(String)
    }
    class DocumentRepository_Admin {
        <<Repository>>
        +getDocuments() Future~List~
        +getById(String) Future~DocumentModel?~
        +deleteDocument(String)
    }

    %% ========== SHARED ==========
    class ParameterClassifier {
        <<Shared>>
        +classifyAll(AnalysisParameterValues) List~ParameterClassification~
    }
    class ParameterClassification {
        <<Shared>>
        +String label
        +double value
        +ClassificationLevel level
        +double lowThreshold
        +double highThreshold
    }
    class ClassificationLevel {
        <<enumeration>>
        low
        medium
        high
    }

    %% ========== MOBILE RELATIONS ==========
    LoginPage --> AuthViewModel : aciona
    ResetPasswordPage --> AuthViewModel : aciona
    SplashPage --> AuthViewModel : aciona
    HomePage --> AuthViewModel : aciona
    HomePage --> ProfileViewModel : aciona
    HistoryPage --> AnalysisViewModel : aciona
    AnalysisPage --> AnalysisViewModel : aciona
    AnalysisDetailPage --> SoilAnalysis : exibe
    ProfilePage --> ProfileViewModel : aciona
    EditProfilePage --> ProfileViewModel : aciona
    ChangePasswordPage --> ProfileViewModel : aciona
    FarmersListPage --> FarmersViewModel : aciona
    FarmerAnalysesPage --> FarmersViewModel : aciona
    DocumentsPage --> AnalysisViewModel : aciona
    PdfPreviewPage --> SoilDocument : exibe

    AuthViewModel --> AuthRepository : delega
    ProfileViewModel --> ProfileRepository : delega
    AnalysisViewModel --> UploadFlow : delega
    AnalysisViewModel --> DocumentRepository : delega
    AnalysisViewModel --> SoilAnalysisRepository : delega
    UploadFlow --> DocumentRepository : delega
    UploadFlow --> SoilAnalysisRepository : delega
    FarmersViewModel --> FirestoreService : delega

    AuthRepository ..> User : manipula
    ProfileRepository ..> User : manipula
    DocumentRepository ..> SoilDocument : manipula
    SoilAnalysisRepository ..> SoilAnalysis : manipula
    UploadFlow ..> AnalysisIntakeState : gerencia
    UploadFlow ..> SoilAnalysis : manipula

    User --> ProfileType : possui
    SoilAnalysis --> ParameterClassifier : classifica
    ParameterClassifier --> ParameterClassification : produz
    ParameterClassification --> ClassificationLevel : contém

    %% ========== ADMIN RELATIONS ==========
    AdminLoginPage --> AuthService : aciona
    UserListPage --> UserListViewModel : aciona
    UserFormPage --> UserFormViewModel : aciona
    UserRelationPage --> UserRelationViewModel : aciona
    AdminAnalysisListPage --> AdminAnalysisListViewModel : aciona
    AdminAnalysisDetailPage --> AnalysisRepository : consulta
    AdminDocumentListPage --> AdminDocumentListViewModel : aciona
    AdminDocumentDetailPage --> DocumentRepository_Admin : consulta

    UserListViewModel --> UserRepository : delega
    UserFormViewModel --> AuthService : delega
    UserFormViewModel --> FirestoreService : delega
    UserRelationViewModel --> FirestoreService : delega
    AdminAnalysisListViewModel --> AnalysisRepository : delega
    AdminDocumentListViewModel --> DocumentRepository_Admin : delega

    AdminSession --> AuthService : encapsula
    UserListPage --> AdminSession : consulta
```

---

## 2. Diagramas de Sequência (Casos de Uso)

### UC01: Importar Documento

```mermaid
sequenceDiagram
    autonumber
    actor A as Usuário Mobile
    participant UI as <<Boundary>><br>AnalysisPage
    participant VM as <<Control>><br>AnalysisViewModel
    participant UF as <<Control>><br>UploadFlow
    participant FP as <<Service>><br>FilePicker
    participant Repo as <<Service>><br>DocumentRepository

    A->>UI: Clica em "Importar Documento"
    UI->>FP: Abrir seletor de arquivos (.pdf)
    FP-->>UI: Retorna File selecionado
    UI->>VM: setSelectedFileName(name)
    VM->>UF: setSelectedFile(name)
    UF-->>VM: estado = fileSelected
    UI-->>A: Exibe nome do arquivo selecionado

    A->>UI: Clica em "Iniciar"
    UI->>VM: uploadDocumentCommand.execute(file)
    VM->>UF: upload(file)
    UF-->>UF: estado = uploadingDocument
    UF->>Repo: uploadDocument(file, fileName)
    
    alt Upload falha
        Repo-->>UF: Result.error
        UF-->>UF: estado = failed
        UF-->>VM: Result.error
        VM-->>UI: Erro
        UI-->>A: Exibe mensagem de erro
    else Upload sucesso
        Repo-->>UF: Result.ok(SoilDocument)
        UF-->>UF: estado = documentUploaded
        UF-->>VM: Result.ok(doc)
        VM-->>UI: Sucesso
    end
```

### UC02: Extrair e Salvar Análises

```mermaid
sequenceDiagram
    autonumber
    participant UI as <<Boundary>><br>AnalysisPage
    participant VM as <<Control>><br>AnalysisViewModel
    participant UF as <<Control>><br>UploadFlow
    participant Repo as <<Service>><br>SoilAnalysisRepository
    participant Classif as <<Shared>><br>ParameterClassifier

    note over VM: Acionado automaticamente após upload (UC01)
    VM->>UF: extract(file)
    UF-->>UF: estado = extracting
    UF->>Repo: extractFromPdf(file, documentId)
    Repo-->>UF: Result.ok(List<SoilAnalysis>)
    UF-->>UF: estado = extracted
    UF-->>VM: List<SoilAnalysis>

    VM-->>UI: Exibe cards de preview com classificação
    UI->>Classif: classifyAll(analysis)
    Classif-->>UI: List<ParameterClassification>

    A->>UI: Clica em "Salvar Dados"
    UI->>VM: saveAllExtractedAnalyses()
    VM->>UF: saveAll()

    loop Para cada análise extraída
        UF->>Repo: saveAnalysis(analysis)
        Repo-->>UF: Result.ok(saved)
    end

    UF-->>UF: estado = complete
    UF-->>VM: Result.ok(count)

    alt Apenas uma análise
        VM-->>UI: Exibe card de sucesso + botão "Ver análise"
        UI-->>A: Navega para AnalysisDetailPage
    else Múltiplas análises
        VM-->>UI: Exibe card de sucesso + botão "Ver histórico"
        UI-->>A: Navega para HistoryPage
    end
```

### UC03: Consultar Histórico de Análises

```mermaid
sequenceDiagram
    autonumber
    actor A as Usuário Mobile
    participant UI as <<Boundary>><br>HistoryPage
    participant VM as <<Control>><br>AnalysisViewModel
    participant Repo as <<Service>><br>SoilAnalysisRepository

    A->>UI: Acessa aba "Histórico"
    UI->>VM: loadAnalysesCommand.execute()
    VM->>Repo: getAnalyses()
    Repo-->>VM: Result.ok(List<SoilAnalysis>)
    VM-->>VM: Ordena por createdAt decrescente
    
    alt Lista Vazia
        VM-->>UI: Lista vazia
        UI-->>A: Exibe estado vazio
    else Dados Encontrados
        VM-->>UI: List<SoilAnalysis>
        UI-->>A: Renderiza cards em ordem decrescente
    end

    A->>UI: Toca em uma análise
    UI-->>A: Navega para AnalysisDetailPage(analysis)
```

### UC04: Gerenciar Relações (Administrador)

```mermaid
sequenceDiagram
    autonumber
    actor Ad as Administrador
    participant UI as <<Boundary>><br>UserRelationPage
    participant VM as <<Control>><br>UserRelationViewModel
    participant FS as <<Service>><br>FirestoreService

    Ad->>UI: Acessa página de relações de um usuário

    Ad->>UI: Seleciona agricultor e consultor para vincular
    UI->>VM: linkFarmerToConsultant(agricultorId, consultorId)
    VM->>FS: linkFarmerToConsultant(agricultorId, consultorId)
    
    alt Vínculo inválido
        FS-->>VM: Exception
        VM-->>UI: Erro
        UI-->>Ad: Exibe alerta de erro
    else Vínculo válido
        FS-->>VM: Sucesso (transação Firestore)
        VM-->>UI: Atualiza lista
        UI-->>Ad: Exibe confirmação
    end

    opt Desvincular
        Ad->>UI: Clica para remover vínculo
        UI->>VM: unlinkFarmerFromConsultant(agricultorId, consultorId)
        VM->>FS: unlinkFarmerFromConsultant(...)
        FS-->>VM: Sucesso
        VM-->>UI: Atualiza lista
    end
```

### UC05: Gerenciar Perfil (Mobile)

```mermaid
sequenceDiagram
    autonumber
    actor A as Usuário Logado
    participant UI as <<Boundary>><br>ProfilePage
    participant VM as <<Control>><br>ProfileViewModel
    participant Repo as <<Service>><br>ProfileRepository

    A->>UI: Acessa aba "Perfil"
    UI->>VM: loadProfileCommand.execute()
    VM->>Repo: getProfile()
    Repo-->>VM: UserProfile
    VM-->>UI: Renderiza dados do perfil

    opt Alterar Dados Cadastrais
        A->>UI: Edita nome/telefone e salva
        UI->>VM: updateProfileCommand.execute(data)
        VM->>Repo: updateProfile(ProfileUpdateData)
        Repo-->>VM: Sucesso
        VM-->>UI: Notifica sucesso
    end

    opt Alterar Senha
        A->>UI: Acessa ChangePasswordPage
        UI->>VM: changePasswordCommand.execute(data)
        VM->>Repo: changePassword(PasswordUpdateData)
        
        alt Senha atual incorreta
            Repo-->>VM: Result.error
            VM-->>UI: Erro de autenticação
        else Sucesso
            Repo-->>VM: Result.ok
            VM-->>UI: Notifica sucesso
        end
    end
```

### UC06: Gerenciar Usuários (Administrador)

```mermaid
sequenceDiagram
    autonumber
    actor Ad as Administrador
    participant UI as <<Boundary>><br>UserFormPage
    participant VM as <<Control>><br>UserFormViewModel
    participant Auth as <<Service>><br>AuthService
    participant FS as <<Service>><br>FirestoreService

    Ad->>UI: Clica em "Novo Usuário"
    Ad->>UI: Preenche formulário (email, nome, role)
    UI->>VM: createUser(email, name, role)
    VM->>Auth: createAuthUser(email)
    
    alt Email já existe
        Auth-->>VM: Exception(EMAIL_EXISTS)
        VM-->>UI: Retorna Erro
        UI-->>Ad: Exibe alerta "Email já possui uma conta"
    else Conta criada
        Auth-->>VM: UID gerado
        VM->>FS: addUser(uid, userData)
        FS-->>VM: Sucesso
        VM-->>UI: Notifica conclusão
        UI-->>Ad: Exibe sucesso e redireciona para listagem
    end

    opt Editar/Desativar usuário
        Ad->>UI: Seleciona usuário na lista
        UI-->>Ad: Abre UserFormPage em modo edição
        Ad->>UI: Altera dados ou desativa usuário
        UI->>VM: updateUser(id, data) / updateStatus(id, false)
        VM->>FS: updateUser(...) / updateUserStatus(...)
        FS-->>VM: Sucesso
        VM-->>UI: Atualiza listagem
    end
```

---

## 3. Arquitetura de Camadas

```
┌─────────────────────────────────────────────────────┐
│                    UI (Boundary)                     │
│  mobile: ui/auth, ui/home, ui/profile, ui/farmers   │
│  admin:  features/*/pages, shared/widgets           │
├─────────────────────────────────────────────────────┤
│                 Control (ViewModels)                 │
│  mobile: ui/*/   *_viewmodel.dart                   │
│          domain/  upload_flow.dart                  │
│  admin:  features/*/viewmodels/                     │
├─────────────────────────────────────────────────────┤
│            Services & Repositories (Adapter)         │
│  mobile: data/repositories/  (interfaces)           │
│          data/repositories/*_remote.dart (impl)     │
│          data/services/       (Firebase adapters)    │
│  admin:  core/repositories/   (concrete repos)      │
│          core/services/       (Firebase adapters)    │
├─────────────────────────────────────────────────────┤
│                 Domain (Entity)                      │
│  mobile: domain/models/                             │
│  admin:  core/models/                               │
│  shared: packages/anasoil_shared/lib/src/           │
│          (ParameterClassifier, FirestoreSchema,     │
│           Command, Result, ThemeTokens)              │
└─────────────────────────────────────────────────────┘
```

---

## 4. Diagrama de Caso de Uso

O AnaSoil possui três atores e seis casos de uso principais, distribuídos
entre o aplicativo móvel e a plataforma web administrativa.

```mermaid
graph TD
    A1((Agricultor))
    A2((Consultor))
    A3((Administrador))

    subgraph "Aplicativo Móvel"
        UC01["Importar Documento"]
        UC02["Extrair e Salvar Análises"]
        UC03["Consultar Histórico"]
        UC05["Gerenciar Perfil"]
    end

    subgraph "Plataforma Web Administrativa"
        UC04["Gerenciar Relações"]
        UC06["Gerenciar Usuários"]
    end

    A1 --> UC01
    A1 --> UC02
    A1 --> UC03
    A1 --> UC05

    A2 --> UC01
    A2 --> UC02
    A2 --> UC03
    A2 --> UC05

    A3 --> UC04
    A3 --> UC06
```

## 5. Diagrama de Implantação

O AnaSoil é implantado em dispositivos Android, navegadores web e serviços
Firebase hospedados na Google Cloud Platform.

```mermaid
graph TD
    subgraph "Dispositivo do Usuário"
        Phone["Smartphone Android\n(APK Flutter)"]
        Browser["Navegador Web\n(Flutter Web)"]
    end

    subgraph "Google Cloud Platform"
        AuthSvc["Firebase\nAuthentication"]
        FirestoreSvc["Cloud Firestore\n(NoSQL)"]
        StorageSvc["Firebase Storage\n(PDFs)"]
    end

    Phone -->|REST/gRPC| AuthSvc
    Phone -->|REST/gRPC| FirestoreSvc
    Phone -->|Upload| StorageSvc

    Browser -->|REST/gRPC| AuthSvc
    Browser -->|REST/gRPC| FirestoreSvc
    Browser -->|REST| AuthSvc

    Phone -.->|Armazenamento local| PhoneLocal["SharedPreferences\n(sessão)"]
```

---

## 6. Diagramas de Estado

### 6.1 Ciclo de Vida do Usuário

Usuários são criados pela plataforma administrativa e transitam entre os
estados ativo e inativo por decisão do administrador.

```mermaid
stateDiagram-v2
    [*] --> Criado : Administrador cria usuário
    Criado --> Ativo : Credencial gerada\n+ perfil atribuído
    
    Ativo --> Inativo : Administrador desativa
    Inativo --> Ativo : Administrador reativa
    
    Ativo --> Atualizado : Dados editados
    Atualizado --> Ativo
    
    note right of Inativo
        Usuário permanece no Firestore.\nConta Firebase mantida.\nLogin bloqueado via campo active.
    end note
```

### 6.2 Upload Flow (Máquina de Estados)

O fluxo de importação e extração no aplicativo móvel é governado por uma
máquina de estados com nove passos, implementada no módulo `UploadFlow`.

```mermaid
stateDiagram-v2
    [*] --> idle : Tela de análise aberta

    idle --> fileSelected : Arquivo PDF selecionado

    fileSelected --> uploadingDocument : Usuário inicia análise
    fileSelected --> idle : Arquivo removido

    uploadingDocument --> documentUploaded : Upload no Storage concluído
    uploadingDocument --> failed : Erro no upload

    documentUploaded --> extracting : Extração iniciada

    extracting --> extracted : Dados extraídos do PDF
    extracting --> failed : Erro na extração

    extracted --> saving : Usuário salva análises
    extracted --> documentUploaded : Análises descartadas

    saving --> complete : Todas as análises salvas
    saving --> failed : Erro ao salvar

    complete --> idle : Iniciar nova importação

    failed --> idle : Reiniciar fluxo
```
