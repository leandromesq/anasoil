# 🌱 AnaSoil

**Plataforma para interpretação de análises de solo no agronegócio.**

O AnaSoil é um monorepo com dois aplicativos Flutter + um package compartilhado: um **app mobile** para o produtor/técnico enviar documentos de análise de solo (PDF) e visualizar a interpretação com gráficos, e um **painel admin web** para gestão de usuários, documentos e análises.

> Projeto desenvolvido em estágio profissional — arquitetura voltada para produção, não apenas para demo.

---

## 📦 Estrutura do monorepo

```
anasoil/
├── anasoil_mobile/          # App Flutter (Android/iOS) — produtor & técnico
├── anasoil_admin/           # Painel administrativo (Flutter Web)
├── packages/
│   └── anasoil_shared/      # Package compartilhado: schema Firestore, Result, Command, tokens de tema
├── docs/                    # Documentação de arquitetura
└── tool/                    # Scripts de apoio
```

## ✨ Funcionalidades

### Mobile (`anasoil_mobile`)
- 🔐 **Autenticação** — login, recuperação de senha e sessão persistente (Firebase Auth)
- 📄 **Upload de documentos** — importação de PDFs de análise de solo via file picker
- 🔎 **Extração de texto de PDF** — leitura automática do conteúdo da análise (Syncfusion)
- 📊 **Interpretação visual** — gráficos e leitura dos resultados da análise (fl_chart)
- 👤 **Perfil** — avatar via câmera/galeria, dados do usuário

### Admin (`anasoil_admin`)
- 👥 **Gestão de usuários** — criação, edição, ativação/desativação e vínculo de usuários
- 📁 **Gestão de documentos e análises** — listagem, visualização e exclusão
- 🏗️ **Shell de navegação** — módulos de auth, documentos, análises, usuários e configurações

## 🏛️ Arquitetura

- **Clean Architecture** com camadas `ui → ViewModel → Repository (interface) → Adapter Firebase`
- **Injeção de dependência** com GetIt (composition roots separados por app)
- **Schema compartilhado** em `anasoil_shared` — os dois apps consomem as mesmas constantes de collections/fields do Firestore
- **Seams bem definidos** — repositórios expõem interfaces; implementações Firebase ficam isoladas como adapters
- **Result / Command** como padrão de retorno em toda a camada de dados

```
UI (ViewModels) → Repository (Interface) → Implementation Remote → Adapter (Firebase) 
                        ↓
            anasoil_shared (schema + Result + Command)
```

## 🧰 Stack

| Camada | Tecnologia |
|---|---|
| Framework | Flutter (mobile + web admin) |
| Estado | ChangeNotifier + ViewModels |
| Navegação | go_router |
| DI | get_it |
| Backend | Firebase (Auth, Firestore, Storage) |
| PDF | syncfusion_flutter_pdf, flutter_pdfview |
| Gráficos | fl_chart |
| HTTP | dio |
| Local | shared_preferences |

## 🚀 Como rodar

```bash
# Mobile
cd anasoil_mobile
flutter pub get
flutter run

# Admin
cd anasoil_admin
flutter pub get
flutter run -d chrome
```

> Requer um projeto Firebase configurado (Auth, Firestore e Storage) e os arquivos `firebase_options.dart` dos respectivos apps.
