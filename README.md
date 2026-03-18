<p align="center">
  <img src="assets/logo.png" alt="Logo UniEventos" width="180" />
</p>

<h1 align="center">UniEventos</h1>

<p align="center">
  Aplicativo Flutter para autenticação, gestão de usuários e publicação de eventos institucionais.
</p>

<p align="center">
  <img alt="Flutter" src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white" />
  <img alt="Dart" src="https://img.shields.io/badge/Dart-3.3+-0175C2?logo=dart&logoColor=white" />
  <img alt="Status" src="https://img.shields.io/badge/status-em%20desenvolvimento-E65100" />
</p>

## Visão Geral

O UniEventos é um app com foco em ambiente acadêmico para:

- autenticar usuários com token JWT;
- exibir feed paginado de eventos;
- buscar eventos por texto;
- cadastrar eventos com imagem;
- gerenciar usuários (fluxos administrativos);
- manter sessão com armazenamento seguro local.

O projeto também inclui uma pasta web auxiliar (`HtmlUniEventos`) com templates HTML para comunicação institucional.

## Funcionalidades Implementadas

- Login com opção "permanecer conectado".
- Validação de sessão em `FlutterSecureStorage`.
- Feed de eventos com paginação infinita.
- Busca de eventos com debounce.
- Cadastro de eventos com período (início/fim) e upload de imagem.
- Resolução automática de categoria por curso no cadastro de eventos.
- Perfil do usuário com atualização via pull-to-refresh.
- Logout com limpeza completa de sessão.
- Navegação por perfil (admin vs usuário comum).
- Área administrativa para cadastro de usuários.
- Área administrativa para listagem e busca de usuários ativos.
- Área administrativa para listagem e busca de usuários desativados.
- Área administrativa para ativação e desativação de usuários.

## Stack Técnica

- Flutter (Material)
- Dart
- `http`
- `flutter_secure_storage`
- `infinite_scroll_pagination`
- `cached_network_image`
- `image_picker`
- `chopper` + geração via Swagger
- `intl`

## Estrutura do Projeto

```text
.
├── lib/
│   ├── config/                 # Tema e configuração de API
│   ├── models/                 # Modelos de domínio (Evento, Usuário etc.)
│   ├── services/               # Camada de serviços para gestão de usuários
│   ├── widgets/                # Componentes reutilizáveis (ex.: card de evento)
│   ├── login.dart              # Tela de login
│   ├── home.dart               # Navegação principal e feed
│   ├── eventRegister.dart      # Cadastro de eventos
│   ├── UserRegister.dart       # Gestão administrativa
│   └── main.dart               # Bootstrap do app
├── tool/
│   └── dev_proxy.dart          # Proxy local para Flutter Web (CORS)
├── HtmlUniEventos/             # Templates HTML (Tailwind) de comunicação
└── pubspec.yaml
```

## Pré-requisitos

- Flutter SDK instalado
- Dart SDK compatível com o projeto (`>= 3.3.0 < 4.0.0`)
- Android Studio / Xcode (para mobile) ou Chrome (para Web)
- Backend da API em execução

## Configuração da API

Por padrão, a aplicação usa:

```txt
http://172.171.192.14:8081/unieventos
```

Você pode sobrescrever a URL base com `--dart-define`:

```bash
flutter run --dart-define=BASE_URL=http://SEU_HOST:PORTA/unieventos
```

## Como Executar

1. Instale as dependências:

```bash
flutter pub get
```

2. Execute no dispositivo desejado:

```bash
flutter run
```

### Execução no Flutter Web (com proxy local)

Se houver bloqueio de CORS/mixed content no navegador:

1. Rode o proxy:

```bash
dart run tool/dev_proxy.dart
```

2. Rode o app apontando para o proxy:

```bash
flutter run -d chrome --dart-define=BASE_URL=http://127.0.0.1:8085/unieventos
```

## Geração de Código (Swagger/Chopper)

O projeto possui geração de cliente a partir de `lib/api/swagger/api-docs.json`.

Para regenerar arquivos:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Módulo Web Auxiliar (`HtmlUniEventos`)

A pasta contém templates HTML para relatório institucional e recuperação de senha.

Comandos úteis:

```bash
cd HtmlUniEventos
npm install
npm run build
```

> O script atual usa `tailwindcss --watch` para gerar `dist/output.css`.

## Observações

- O app depende de autenticação para a maior parte das rotas de API.
- Em ambiente Web, verifique CORS e protocolo (`http/https`) para evitar bloqueios de mixed content.
- Os fluxos administrativos são habilitados conforme a role persistida em storage.

## Próximas Melhorias Sugeridas

- Adicionar testes automatizados para telas e serviços.
- Criar `.env.example`/documentação central de ambientes.
- Configurar CI para lint, análise estática e testes.

---

Desenvolvido para o ecossistema de eventos da UNISAGRADO.
