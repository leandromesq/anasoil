# AnaSoil Mobile - Arquitetura Atual

Este documento descreve a arquitetura atual do app mobile. Os documentos antigos `ARCHITECTURE.md`, `ARCHITECTURE_RULES.md`, `SUMMARY.md` e `ROADMAP.md` podem conter exemplos legados de outro domínio ou de fases iniciais do projeto.

## Fluxo de dependências

```text
UI Page/Widget
  -> ViewModel + Command
  -> Repository Interface
  -> Remote Implementation
  -> Service Adapter
  -> Firebase / Storage / PDF extraction / SharedPreferences
```

## Módulos principais

### Core

- `lib/core/dependency_injection.dart`: composition root GetIt.
- `lib/core/router_config.dart`: GoRouter, rotas públicas/privadas e redirect por auth.
- `lib/core/theme/app_theme.dart`: tema mobile.

### UI

- `lib/ui/auth`: login, splash, reset password e `AuthViewModel`.
- `lib/ui/profile`: perfil, edição e senha.
- `lib/ui/home`: home, histórico, workflow de análise e `AnalysisViewModel`.
- `lib/ui/documents`: galeria e preview de documentos.
- `lib/ui/farmers`: visualização de agricultores vinculados para consultores.

### Domain

- `lib/domain/models`: modelos como `User`, `SoilDocument`, `SoilAnalysis`, `AnalysisIntakeState`.
- `lib/domain/upload_flow.dart`: Módulo atual do workflow de Analysis Intake.

### Data

- `lib/data/repositories`: Interfaces e Implementations remotas.
- `lib/data/services`: Adapters concretos para Firebase Auth, Firestore, Firebase Storage, PDF extraction e local storage.

### Shared package

`packages/anasoil_shared` fornece:

- `Command`
- `Result`
- schema Firestore
- roles de usuário
- tokens/widgets compartilhados

## Analysis Intake

O workflow central do mobile é a importação e persistência de análises de solo:

```text
select file -> upload document -> extract PDF analyses -> save analyses
```

Arquivos envolvidos:

- `lib/domain/upload_flow.dart`
- `lib/domain/models/analysis_intake_state.dart`
- `lib/ui/home/analysis_viewmodel.dart`
- `lib/data/repositories/document/*`
- `lib/data/repositories/soil_analysis/*`

### Fricção atual

- O Módulo ainda se chama `UploadFlow`, mas o conceito é maior: **Analysis Intake**.
- `UploadFlow` ainda estende `ChangeNotifier`, então o workflow de domínio permanece Flutter-shaped.
- Estado do workflow está dividido entre `AnalysisIntakeState` e getters separados (`selectedFileName`, `uploadedDocumentId`, `extractedAnalyses`, `lastSavedAnalyses`).

### Arquitetura alvo do deepening

O Módulo deve ser nomeado pelo conceito de domínio, não pelo detalhe operacional de upload:

```dart
class AnalysisIntake extends ChangeNotifier {
  AnalysisIntakeState get state;

  List<SoilAnalysis> get extractedAnalyses;
  List<SoilAnalysis> get lastSavedAnalyses;

  void selectFile(String name);
  Future<Result<SoilDocument>> upload(File file);
  Future<Result<List<SoilAnalysis>>> extract(File file);
  Future<Result<SoilAnalysis>> saveOne(SoilAnalysis analysis);
  Future<Result<int>> saveAll();
  void discardExtracted();
  void clear();
}
```

A Interface deve esconder dos callers:

- como o `documentId` é guardado entre upload e extração;
- quando extração/salvamento são permitidos;
- como o save em lote itera e trata falhas;
- como estados `failed`, `complete` e `extracted` são montados;
- quais repositories e Adapters participam do workflow.

`AnalysisViewModel` deve continuar fino: Commands, exposição de estado para a UI, listas não pertencentes ao workflow e seleção de documento existente.

### Próximo deepening recomendado

1. Renomear `UploadFlow` para `AnalysisIntake`.
2. Renomear operações para linguagem de workflow: `selectFile`, `clear`, `discardExtracted`, `saveOne`.
3. Concentrar mais estado em `AnalysisIntakeState` ou em um snapshot único.
4. Adicionar testes com fake repositories.
5. Só depois considerar remover `ChangeNotifier` do Módulo.

## Fricções arquiteturais conhecidas

1. `FirestoreService` é um Adapter amplo: users, relações, documentos, análises e mappers.
2. Repositories misturam cache, notify, auth lookup e chamadas aos Adapters.
3. ViewModels são registrados como singletons no GetIt, o que pode vazar estado de tela.
4. Router redirect lê auth via locator global, dificultando testes de rota.
5. Modelos de domínio ainda são duplicados entre mobile e admin.

## Regras práticas atuais

- Use `Command` para operações assíncronas chamadas pela UI.
- Use `Result<T>` para retorno esperado de falhas, evitando exceptions atravessando camadas.
- ViewModels dependem de repository Interfaces, não de Firebase direto.
- Services são Adapters concretos; regras de workflow devem ficar em Módulos mais altos.
- Antes de criar um novo seam, confirme se haverá mais de um Adapter real ou se o seam melhora testes de forma clara.
