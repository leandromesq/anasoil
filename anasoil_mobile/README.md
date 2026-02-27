# AnaSoil Mobile

App mobile do AnaSoil para interpretação de análises de solo.

## Arquitetura

O projeto segue a **App Architecture** do Google/Flutter com padrão **MVVM**:

- **Utils**: Command e Result para operações reativas
- **Data Layer**: Repositories e Services
- **Domain Layer**: Models e UseCases
- **UI Layer**: ViewModels e Pages

## Estrutura

```
lib/
├── utils/              # Command, Result
├── data/
│   ├── repositories/   # Auth, etc
│   └── services/       # API, Storage
├── domain/
│   ├── models/         # User, ProfileType, etc
│   └── usecases/       # Lógica de negócio complexa
├── ui/
│   ├── auth/           # Login, Register, etc
│   └── home/           # Home
└── core/               # DI, Router
```

## Executar

```bash
flutter pub get
flutter run
```

## Tecnologias

- Flutter 3.32.7
- Dart 3.8.1
- go_router para navegação
- get_it para DI
- dio para HTTP
- shared_preferences para storage local

## Funcionalidades Implementadas

- ✅ Autenticação (Login, Cadastro, Recuperação de senha)
- ✅ MVVM com Commands reativos
- ✅ Navegação com proteção de rotas
- ✅ Injeção de dependências

## Próximos Passos

- [ ] Implementar importação de documentos
- [ ] Criar análise de solo
- [ ] Histórico de análises
- [ ] Perfil do usuário
- [ ] Gráficos e visualizações
