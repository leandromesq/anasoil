# 📁 Estrutura do Projeto AnaSoil Mobile

## 📋 Visão Geral

Projeto Flutter seguindo a **App Architecture do Google/Flutter** com padrão **MVVM**.

## 🗂️ Estrutura de Diretórios

```
anasoil_mobile/
├── lib/
│   ├── utils/                          # 🛠️ Utilitários compartilhados
│   │   ├── command.dart               # Commands para operações reativas
│   │   └── result.dart                # Result para tratamento de erros
│   │
│   ├── data/                          # 💾 Camada de dados
│   │   ├── repositories/              # Repositórios por feature
│   │   │   └── auth/
│   │   │       ├── auth_repository.dart              # Interface
│   │   │       └── auth_repository_remote.dart       # Implementação
│   │   │
│   │   └── services/                  # Serviços externos
│   │       ├── anasoil_api.dart      # Cliente HTTP centralizado
│   │       └── storage_service.dart   # SharedPreferences wrapper
│   │
│   ├── domain/                        # 🏢 Camada de domínio
│   │   ├── models/                    # Modelos de negócio
│   │   │   ├── user.dart
│   │   │   ├── profile_type.dart
│   │   │   ├── login_credentials.dart
│   │   │   └── register_data.dart
│   │   │
│   │   └── usecases/                  # Casos de uso (quando necessário)
│   │
│   ├── ui/                            # 🎨 Camada de apresentação
│   │   ├── auth/                      # Feature: Autenticação
│   │   │   ├── auth_viewmodel.dart   # ViewModel
│   │   │   ├── splash_page.dart      # Tela inicial
│   │   │   ├── login_page.dart       # Tela de login
│   │   │   ├── register_page.dart    # Tela de cadastro
│   │   │   └── reset_password_page.dart # Recuperação de senha
│   │   │
│   │   └── home/                      # Feature: Home
│   │       └── home_page.dart        # Tela principal
│   │
│   ├── core/                          # ⚙️ Configurações centrais
│   │   ├── dependency_injection.dart  # Injeção de dependências (GetIt)
│   │   └── router_config.dart        # Configuração de rotas (GoRouter)
│   │
│   └── main.dart                      # 🚀 Entry point do app
│
├── assets/                            # 📦 Assets
│   ├── images/                        # Imagens
│   └── fonts/                         # Fontes customizadas
│
├── docs/                              # 📚 Documentação
│   ├── PROJECT.md                     # Documento de contextualização
│   ├── ARCHITECTURE.md                # Documentação de arquitetura
│   └── ARCHITECTURE_RULES.md          # Regras de arquitetura
│
├── pubspec.yaml                       # Dependências e configurações
├── analysis_options.yaml              # Regras de lint
├── README.md                          # Documentação principal
└── .gitignore                         # Arquivos ignorados pelo Git
```

## 🔧 Componentes Principais

### Utils Layer

- **`command.dart`**: Implementa `Command0<T>` e `Command1<T, A>` para operações assíncronas reativas
- **`result.dart`**: Define `Result<T>`, `Ok<T>` e `Error<T>` para tratamento funcional de erros

### Data Layer

- **Repositories**: Fonte única da verdade, estendem `ChangeNotifier`
  - Interface abstrata define o contrato
  - Implementação concreta (`*Remote`) contém a lógica
- **Services**: Acesso a APIs e storage
  - `AnaSoilApi`: Cliente HTTP centralizado com Dio
  - `StorageService`: Wrapper para SharedPreferences

### Domain Layer

- **Models**: POJOs com `fromJson`, `toJson` e `copyWith`
- **UseCases**: Apenas quando necessário (lógica complexa, múltiplos repos, reutilização)

### UI Layer

- **ViewModels**:
  - Estendem `ChangeNotifier`
  - Usam Commands para operações
  - Escutam mudanças no Repository
- **Pages**:
  - Widgets stateless/stateful
  - Usam `ListenableBuilder` para reatividade
  - Recebem ViewModel via construtor

### Core

- **`dependency_injection.dart`**: Configura GetIt com todos os services, repositories e viewmodels
- **`router_config.dart`**: Define rotas com GoRouter e proteção de autenticação

## 📊 Fluxo de Dados

```
UI (Page)
  ↓ chama
ViewModel (Command.execute)
  ↓ chama
Repository
  ↓ chama
Service (API/Storage)
  ↓ retorna
Result<T> (Ok/Error)
  ↓ propaga
Repository notifyListeners()
  ↓ atualiza
ViewModel notifyListeners()
  ↓ reage
UI (ListenableBuilder)
```

## 🎯 Convenções de Nomenclatura

### Arquivos

- ViewModels: `*_viewmodel.dart` (não `*_controller.dart`)
- Pages: `*_page.dart`
- Repositories: `*_repository.dart` (interface) e `*_repository_remote.dart` (implementação)
- Models: `*.dart` (singular)

### Classes

- ViewModels: `*ViewModel extends ChangeNotifier`
- Repositories: `*Repository extends ChangeNotifier`
- Models: Classes simples com construtores const quando possível

### Commands

```dart
late final Command0<T> nomeOperacao;
late final Command1<T, A> nomeOperacao;
```

## 🚦 Fluxo de Autenticação

1. **Splash** → Verifica autenticação
2. Se autenticado → **Home**
3. Se não autenticado → **Login**
4. Login → **Register** ou **Reset Password**
5. Após login/registro bem-sucedido → **Home**

## ✅ Regras Arquiteturais

1. ✅ ViewModels (não Controllers)
2. ✅ Commands para operações assíncronas
3. ✅ ReactiveBuilder na UI (não StateBuilder)
4. ✅ Repositórios isolados (não dependem de outros repositórios)
5. ✅ API Service centralizado (AnaSoilApi)
6. ✅ Injeção de dependências via GetIt
7. ✅ Result<T> para tratamento de erros
8. ✅ UseCases apenas quando necessário

## 🔐 Autenticação

### Storage

- Token: `auth_token` (String)
- User: `user` (JSON serializado)

### Repository

- `AuthRepository` mantém o `currentUser` em memória
- Notifica listeners quando o estado de autenticação muda
- Sincroniza com `StorageService` para persistência

### ViewModel

- `AuthViewModel` expõe Commands:
  - `loginCommand`: Login
  - `registerCommand`: Cadastro
  - `resetPasswordCommand`: Recuperação de senha
  - `loadUserCommand`: Carrega usuário do storage
  - `logoutCommand`: Logout

## 🎨 UI Components

### Cores

- Primary: `Colors.green[700]`
- Background: `Colors.white`
- Cards: `Colors.grey[100]`

### Componentes

- Cards com bordas arredondadas (12px)
- Inputs com preenchimento leve
- Botões com padding consistente
- Icons do Material Design

## 📱 Features Implementadas

### ✅ Autenticação

- [x] Splash screen
- [x] Login
- [x] Cadastro (Agricultor/Consultor)
- [x] Recuperação de senha
- [x] Logout

### ✅ Infraestrutura

- [x] MVVM Architecture
- [x] Commands reativos
- [x] Result para erros
- [x] Routing com proteção
- [x] Dependency Injection

## 🚀 Próximas Features

### 📄 Documentos

- [ ] Importar PDF/XLSX
- [ ] Visualizar documento
- [ ] Galeria de documentos

### 🧪 Análise de Solo

- [ ] Processar documento
- [ ] Gerar relatório
- [ ] Exibir gráficos
- [ ] Histórico de análises

### 👤 Perfil

- [ ] Visualizar perfil
- [ ] Editar dados
- [ ] Alterar senha
- [ ] Configurações

### 👥 Consultores (futuro)

- [ ] Carteira de agricultores
- [ ] Visualizar histórico de clientes

## 🧪 Testing

### Estrutura de Testes (a implementar)

```
test/
├── unit/
│   ├── viewmodels/
│   ├── repositories/
│   └── usecases/
├── widget/
└── integration/
```

## 📚 Referências

- [PROJECT.md](docs/PROJECT.md) - Documento de contextualização do projeto
- [ARCHITECTURE.md](docs/ARCHITECTURE.md) - Documentação detalhada da arquitetura
- [ARCHITECTURE_RULES.md](docs/ARCHITECTURE_RULES.md) - Regras obrigatórias de arquitetura
