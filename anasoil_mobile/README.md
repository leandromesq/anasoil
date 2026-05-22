# AnaSoil Mobile

App Flutter do AnaSoil para importar laudos de análise de solo, extrair parâmetros do PDF, salvar análises e consultar histórico.

## Arquitetura atual

O app segue MVVM com `ChangeNotifier`, `Command` e `Result`, usando Firebase como backend principal.

```text
UI Page/Widget
  -> ViewModel + Command
  -> Repository Interface
  -> Remote Implementation
  -> Firebase/PDF/Storage Adapter
```

Principais Módulos:

- `lib/core/`
  - `dependency_injection.dart`: composição GetIt.
  - `router_config.dart`: rotas GoRouter e auth redirect.
- `lib/ui/`
  - páginas, widgets e ViewModels por área.
- `lib/domain/`
  - modelos de domínio e o workflow atual de Analysis Intake em `upload_flow.dart`.
- `lib/data/repositories/`
  - Interfaces e Implementations remotas para auth, perfil, documentos e análises.
- `lib/data/services/`
  - Adapters Firebase Auth, Firestore, Firebase Storage, SharedPreferences e extração de PDF.
- `../packages/anasoil_shared/`
  - `Command`, `Result`, schema Firestore, roles, tokens e widgets compartilhados.

## Workflow principal: Analysis Intake

O fluxo de análise fica concentrado em `lib/domain/upload_flow.dart`:

```text
select file -> upload document -> extract PDF analyses -> save one/all analyses
```

`AnalysisViewModel` delega esse fluxo para `UploadFlow` e mantém Commands/listas para a UI.

Fricção conhecida: o Módulo ainda se chama `UploadFlow`, embora represente o conceito maior de **Analysis Intake**. Também ainda é `ChangeNotifier` e divide estado entre `AnalysisIntakeState` e getters separados.

## Estrutura

```text
lib/
├── core/                 # DI, router, theme
├── data/
│   ├── repositories/     # Interfaces + Implementations remotas
│   └── services/         # Firebase, Storage, PDF extraction, local storage
├── domain/
│   ├── models/           # User, SoilDocument, SoilAnalysis, intake state
│   └── upload_flow.dart  # Analysis Intake workflow atual
├── ui/                   # Pages, ViewModels, widgets
├── utils/                # Reexports de Command/Result compartilhados
└── main.dart
```

## Funcionalidades implementadas

- Autenticação Firebase com usuário ativo no Firestore.
- Perfil e alteração de senha.
- Importação/upload de PDF.
- Extração de análises de solo via PDF.
- Salvamento e histórico de análises.
- Galeria de documentos e preview de PDF.
- Fluxo consultor/agricultor para visualizar agricultores vinculados.

## Executar

```bash
cd anasoil_mobile
flutter pub get
flutter run
```

## Testes

```bash
cd anasoil_mobile
flutter test
```

Testes atuais focam regras de domínio pequenas. Próximo alvo recomendado: testes do workflow de Analysis Intake com repositories fake.

## Documentação relacionada

- `../CONTEXT.md`: mapa arquitetural mais atualizado do monorepo.
- `docs/ARCHITECTURE_CURRENT.md`: resumo da arquitetura mobile atual.
- `docs/COMMANDS.md`: comandos úteis.
