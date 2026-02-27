# 🚀 Guia de Comandos - AnaSoil Mobile

## 📦 Instalação Inicial

### 1. Instalar Dependências

```bash
cd anasoil_mobile
flutter pub get
```

### 2. Verificar Instalação Flutter

```bash
flutter doctor
```

## 🏃 Executar o App

### Executar em Modo Debug

```bash
flutter run
```

### Executar em Dispositivo Específico

```bash
# Listar dispositivos
flutter devices

# Executar em dispositivo específico
flutter run -d <device_id>
```

### Executar no Chrome (Web)

```bash
flutter run -d chrome
```

### Executar no Emulador Android

```bash
flutter run -d emulator-5554
```

## 🔧 Desenvolvimento

### Limpar Build

```bash
flutter clean
flutter pub get
```

### Analisar Código

```bash
flutter analyze
```

### Formatar Código

```bash
flutter format .
```

### Gerar Build

```bash
# Android APK
flutter build apk

# Android App Bundle
flutter build appbundle

# iOS
flutter build ios
```

## 🧪 Testes (a implementar)

### Executar Todos os Testes

```bash
flutter test
```

### Executar Testes com Cobertura

```bash
flutter test --coverage
```

### Executar Testes de Widget

```bash
flutter test test/widget/
```

## 📱 Plataformas

### Android

#### Assinar APK (Produção)

```bash
flutter build apk --release
```

#### Instalar APK no Dispositivo

```bash
flutter install
```

### iOS

#### Abrir no Xcode

```bash
open ios/Runner.xcworkspace
```

#### Build para Produção

```bash
flutter build ios --release
```

## 🔍 Debug

### Logs em Tempo Real

```bash
flutter logs
```

### DevTools

```bash
flutter pub global activate devtools
flutter pub global run devtools
```

### Hot Reload

- Durante execução: pressione `r`
- Hot Restart: pressione `R`

## 📊 Análise de Performance

### Profile Mode

```bash
flutter run --profile
```

### Release Mode

```bash
flutter run --release
```

## 🛠️ Utilitários

### Atualizar Dependências

```bash
flutter pub upgrade
```

### Verificar Dependências Desatualizadas

```bash
flutter pub outdated
```

### Adicionar Nova Dependência

```bash
flutter pub add <package_name>
```

### Adicionar Dev Dependency

```bash
flutter pub add --dev <package_name>
```

## 🔄 Git Workflow

### Iniciar Repositório (se ainda não iniciado)

```bash
git init
git add .
git commit -m "Initial commit: AnaSoil mobile basic structure"
```

### Workflow de Desenvolvimento

```bash
# Criar branch de feature
git checkout -b feature/nome-da-feature

# Adicionar mudanças
git add .
git commit -m "feat: descrição da feature"

# Push
git push origin feature/nome-da-feature
```

## 📝 Convenções de Commit

- `feat:` Nova feature
- `fix:` Correção de bug
- `refactor:` Refatoração de código
- `docs:` Mudanças na documentação
- `style:` Formatação, lint
- `test:` Adicionar/modificar testes
- `chore:` Tarefas de manutenção

## 🔐 Configuração de API

### Desenvolvimento Local

Edite o arquivo `lib/core/dependency_injection.dart`:

```dart
const baseUrl = 'http://localhost:3000'; // ou sua URL de desenvolvimento
```

### Produção

```dart
const baseUrl = 'https://api.anasoil.com';
```

## 🎨 Assets

### Adicionar Imagens

1. Coloque a imagem em `assets/images/`
2. Use no código:

```dart
Image.asset('assets/images/nome_da_imagem.png')
```

### Adicionar Fontes

1. Coloque a fonte em `assets/fonts/`
2. Registre no `pubspec.yaml`:

```yaml
fonts:
  - family: MinhaFonte
    fonts:
      - asset: assets/fonts/minha_fonte.ttf
```

## 🐛 Solução de Problemas Comuns

### Erro de Dependências

```bash
flutter clean
flutter pub get
```

### Erro de Build Android

```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

### Erro de Permissões (Linux/Mac)

```bash
chmod +x android/gradlew
```

### Cache do Pub

```bash
flutter pub cache repair
```

## 📚 Recursos Úteis

- [Flutter Docs](https://docs.flutter.dev/)
- [Dart Docs](https://dart.dev/guides)
- [GoRouter Docs](https://pub.dev/packages/go_router)
- [Dio Docs](https://pub.dev/packages/dio)

## 🎯 Checklist Antes de Deploy

- [ ] Testes passando
- [ ] Sem warnings no `flutter analyze`
- [ ] Código formatado (`flutter format .`)
- [ ] Version bump no `pubspec.yaml`
- [ ] Changelog atualizado
- [ ] API URL configurada para produção
- [ ] Build testado em dispositivos reais
- [ ] Screenshots atualizados (se necessário)

## 📞 Comandos de Produtividade

### Criar Nova Feature Completa

```bash
# Estrutura de pastas para nova feature
mkdir -p lib/ui/nova_feature
mkdir -p lib/data/repositories/nova_feature
mkdir -p lib/domain/models
```

### Watch Mode para Análise

```bash
# Terminal 1: App rodando
flutter run

# Terminal 2: Análise contínua
watch -n 5 flutter analyze
```

## 🔥 Tips

- Use `const` sempre que possível para melhor performance
- Prefira `ListenableBuilder` para reatividade localizada
- Mantenha ViewModels leves, delegando lógica complexa para UseCases
- Sempre retorne `Result<T>` em operações assíncronas
- Teste em múltiplos tamanhos de tela
