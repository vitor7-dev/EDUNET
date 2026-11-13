# 🎓 EDUNET

### Sistema de gerenciamento e comercialização de serviços de Internet

O **EDUNET** é uma aplicação desenvolvida como projeto acadêmico e de portfólio, com o objetivo de simular uma plataforma para **comercialização de planos de Internet, gerenciamento de contratos, atendimento ao cliente e acompanhamento de solicitações**.

O projeto é composto por uma aplicação mobile desenvolvida em **Flutter**, uma **API REST desenvolvida em C# com .NET** e uma interface web para gerenciamento administrativo.

---

## 🚀 Tecnologias utilizadas

### 📱 Aplicação Mobile

- **Flutter**
- **Dart**
- Android
- Windows
- Web
- Gerenciamento de estado
- Consumo de API REST

### ⚙️ Backend

- **C#**
- **.NET**
- **ASP.NET Core**
- **Entity Framework Core**
- **REST API**
- **JWT / autenticação**
- SQL Server
- Estrutura baseada em Controllers, Models, DTOs e Services

### 🌐 Frontend Web

- HTML5
- CSS3
- JavaScript
- Integração com a API REST

### 🗄️ Banco de dados

- **Microsoft SQL Server**
- Scripts SQL para criação e configuração do banco
- Entity Framework Core para comunicação entre a API e o banco de dados

### 🛠️ Ferramentas

- Git
- GitHub
- Visual Studio / VS Code
- Flutter SDK
- .NET SDK

---

# 📌 Funcionalidades

## 👤 Autenticação e usuários

- Cadastro de usuários
- Login
- Autenticação através da API
- Controle de sessão
- Perfil do usuário

## 📡 Planos de Internet

O sistema permite visualizar os planos disponíveis e suas respectivas informações.

Exemplo de planos utilizados no projeto:

| Plano | Velocidade | Valor |
|---|---:|---:|
| Essencial | 200 Mbps | R$ 89,90 |
| Premium | 500 Mbps | R$ 129,90 |
| Ultra | 1 Gbps | R$ 199,90 |

## 📄 Contratos

O sistema possui funcionalidades relacionadas ao gerenciamento dos contratos dos clientes, permitindo consultar informações do serviço contratado.

## 🎫 Suporte e solicitações

A aplicação possui recursos para abertura e acompanhamento de solicitações de suporte.

## 📊 Relatórios

O backend possui estrutura para gerenciamento de informações e geração de dados relacionados ao sistema.

## 🛠️ Área administrativa

A interface web possui páginas voltadas para gerenciamento administrativo, incluindo:

- Login
- Administração
- Planos
- Solicitações
- Integração com a API

---

# 🏗️ Arquitetura do projeto

O projeto está organizado em diferentes componentes:

```text
EDUNET/
│
├── 📁 InternetApi/
│   ├── Controllers/
│   ├── Data/
│   ├── Models/
│   ├── Services/
│   ├── Dtos.cs
│   ├── Program.cs
│   └── InternetApi.csproj
│
├── 📁 edunet_app/
│   ├── lib/
│   │   ├── models/
│   │   ├── screens/
│   │   ├── services/
│   │   ├── state/
│   │   └── main.dart
│   ├── android/
│   ├── ios/
│   ├── web/
│   ├── windows/
│   └── pubspec.yaml
│
├── 📁 frontend/
│   ├── admin.html
│   ├── index.html
│   ├── login.html
│   ├── planos.html
│   ├── solicitacoes.html
│   ├── api.js
│   ├── script.js
│   └── styles.css
│
├── 📄 script.sql
├── 📄 .gitignore
└── 📄 README.md
```

---

# 🔄 Comunicação entre as aplicações

A arquitetura do EDUNET utiliza a API como camada intermediária entre as aplicações e o banco de dados.

```text
                  ┌─────────────────────┐
                  │    Aplicação Flutter │
                  │      edunet_app      │
                  └──────────┬──────────┘
                             │
                             │ HTTP / REST
                             ▼
                  ┌─────────────────────┐
                  │      InternetApi    │
                  │    ASP.NET Core     │
                  └──────────┬──────────┘
                             │
                             │ Entity Framework
                             ▼
                  ┌─────────────────────┐
                  │    SQL Server       │
                  │      Banco de Dados │
                  └─────────────────────┘

                  ┌─────────────────────┐
                  │   Frontend Web      │
                  │ HTML / CSS / JS     │
                  └──────────┬──────────┘
                             │
                             │ HTTP / REST
                             ▼
                  ┌─────────────────────┐
                  │      InternetApi    │
                  └─────────────────────┘
```

Essa estrutura permite separar a interface da aplicação das regras de negócio e do acesso aos dados.

---

# 🔐 Segurança

O backend possui estrutura voltada para autenticação e proteção das operações
