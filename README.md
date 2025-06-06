# 💪 Basal Fit - Calculadora de Taxa Metabólica Basal

Um aplicativo Flutter moderno e profissional para calcular a Taxa Metabólica Basal (TMB), gerenciar exercícios e acompanhar seu progresso de fitness.

## 🤖 Desenvolvimento Assistido por IA

> **Importante:** Este projeto foi desenvolvido utilizando **IA (Claude Sonnet) + Cursor** como ferramenta de desenvolvimento assistido.

### 🚀 **Tecnologias Utilizadas:**

- **IA:** Claude Sonnet para arquitetura, código e documentação
- **Editor:** Cursor para desenvolvimento acelerado
- **Framework:** Flutter com Dart
- **Backend:** Firebase (Firestore + Auth)

### 💡 **Benefícios da Abordagem IA-First:**

- ✅ **Arquitetura robusta** implementada desde o início
- ✅ **Documentação completa** gerada automaticamente
- ✅ **Padrões de código** consistentes e profissionais
- ✅ **Desenvolvimento acelerado** com qualidade mantida
- ✅ **Best practices** aplicadas em toda a codebase

### 📚 **Para Desenvolvedores:**

Este projeto serve como **exemplo prático** de como a IA pode ser utilizada para:

1. **Arquitetar aplicações** complexas com Clean Architecture
2. **Implementar features** completas e bem documentadas
3. **Criar UI/UX** moderna com sistema de design consistente
4. **Gerar documentação** técnica detalhada e organizada
5. **Aplicar padrões** de código profissionais

> **Dica:** Consulte a [documentação completa](./docs/) para entender como cada parte foi estruturada e implementada.

## ✨ Funcionalidades

### 🔐 **Autenticação Robusta**

- Login com email/senha
- Autenticação Google e Facebook
- Recuperação de senha
- Sessão persistente

### 📊 **Gestão de Saúde**

- Cálculo preciso da TMB (fórmula Mifflin-St Jeor)
- Registro e histórico de peso corporal
- Sistema completo de exercícios
- Recomendações personalizadas

### 👤 **Perfil Completo**

- Dados pessoais (idade, altura, peso, nível de atividade)
- Upload de foto de perfil (armazenamento em base64)
- Cálculo automático de GET (Gasto Energético Total)

### 🎨 **Interface Moderna**

- Design System completo com Material 3
- Componentes reutilizáveis
- Animações suaves e feedback visual
- Layout responsivo e intuitivo

## 📚 Documentação

Toda a documentação técnica foi organizada na pasta [`docs/`](./docs/):

- 🏗️ **[Arquitetura](./docs/architecture/)** - Padrões de projeto e estrutura do código
- ⚡ **[Funcionalidades](./docs/features/)** - Documentação de features específicas
- 🎨 **[UI/UX](./docs/ui-ux/)** - Design system e melhorias de interface
- 🔧 **[Troubleshooting](./docs/troubleshooting/)** - Guias de solução de problemas

**📖 [Consulte o README da documentação](./docs/README.md) para navegação completa.**

## 🔥 Configuração Firebase

O projeto utiliza Firebase com regras de segurança robustas:

- 🔐 **[Regras Firestore](./firebase/firestore.rules)** - Validações completas e segurança aprimorada
- 📱 **[Configuração Firebase](./firebase/README.md)** - Guia completo de setup e deploy
- 🚀 **Deploy automático:** `firebase deploy --only firestore:rules`

**⚠️ Importante:** O projeto não usa Firebase Storage (imagens em base64 no Firestore).

## Requisitos

- Flutter SDK
- Firebase project
- Google Cloud project (para autenticação com Google)
- Facebook Developer account (para autenticação com Facebook)

## Configuração

1. Clone o repositório:

```bash
git clone https://github.com/seu-usuario/basal_fit.git
cd basal_fit
```

2. Instale as dependências:

```bash
flutter pub get
```

3. Configure o Firebase:

   - Crie um projeto no [Firebase Console](https://console.firebase.google.com)
   - Adicione um aplicativo Android/iOS/Web
   - Baixe o arquivo de configuração (`google-services.json` para Android ou `GoogleService-Info.plist` para iOS)
   - Coloque o arquivo na pasta apropriada do projeto
   - Atualize o arquivo `lib/firebase_options.dart` com suas credenciais do Firebase

4. Configure a autenticação com Google:

   - No Firebase Console, vá para Authentication > Sign-in method
   - Habilite o provedor Google
   - Configure o OAuth consent screen no Google Cloud Console
   - Adicione os SHA-1 e SHA-256 do seu projeto

5. Configure a autenticação com Facebook:
   - Crie um app no [Facebook Developers](https://developers.facebook.com)
   - Configure o Facebook Login
   - Adicione o ID do app e o segredo do app no Firebase Console

## Executando o aplicativo

```bash
flutter run
```

## 🏗️ Estrutura do Projeto

```
basal_fit_flutter/
├── lib/
│   ├── core/                      # Arquitetura e componentes base
│   │   ├── constants/             # Constantes da aplicação
│   │   ├── di/                    # Dependency Injection
│   │   ├── exceptions/            # Tratamento de exceções
│   │   ├── interfaces/            # Interfaces e contratos
│   │   ├── theme/                 # Sistema de tema
│   │   ├── utils/                 # Utilitários (Result pattern)
│   │   └── widgets/               # Componentes reutilizáveis
│   ├── models/                    # Modelos de dados
│   ├── modules/                   # Funcionalidades por módulo
│   │   ├── auth/                  # Autenticação
│   │   └── home/                  # Tela principal e features
│   ├── providers/                 # State management
│   ├── repositories/              # Camada de dados
│   ├── services/                  # Serviços externos (Firebase)
│   ├── use_cases/                 # Regras de negócio
│   └── main.dart
├── docs/                          # 📚 Documentação organizada
│   ├── architecture/              # Padrões e arquitetura
│   ├── features/                  # Funcionalidades específicas
│   ├── ui-ux/                     # Design e melhorias visuais
│   ├── troubleshooting/           # Resolução de problemas
│   └── README.md                  # Índice da documentação
├── firebase/                      # 🔥 Configurações Firebase
│   ├── firestore.rules           # Regras de segurança atualizadas
│   ├── storage.rules              # Regras de Storage (referência)
│   ├── firestore_rules_legacy.txt # Regras antigas (backup)
│   ├── storage_rules_legacy.txt   # Regras antigas (backup)
│   └── README.md                  # Guia de configuração
├── firebase.json                  # Configuração de deploy
└── README.md                      # Este arquivo
```

### 🎯 **Arquitetura Implementada**

- **Clean Architecture** com separação clara de responsabilidades
- **MVVM Pattern** para gerenciamento de estado
- **Repository Pattern** para abstração de dados
- **Use Cases** para regras de negócio
- **Dependency Injection** para desacoplamento
- **Result Pattern** para tratamento de erros

## 🤝 Contribuindo

### **Desenvolvimento Tradicional:**

1. Faça um fork do projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

### **Desenvolvimento com IA/Cursor:**

Se você está utilizando IA para desenvolvimento:

1. **📚 Consulte a documentação** em `docs/` antes de implementar
2. **🏗️ Mantenha os padrões** arquiteturais já estabelecidos
3. **📝 Documente mudanças** seguindo o formato dos arquivos existentes
4. **✅ Teste thoroughly** - IA acelera desenvolvimento, mas testes são essenciais
5. **🔄 Revise o código** - valide se a IA seguiu as convenções do projeto

### **Guidelines para IA:**

- Mantenha a **Clean Architecture** implementada
- Siga o **Design System** estabelecido em `lib/core/theme/`
- Use os **componentes reutilizáveis** de `lib/core/widgets/`
- Documente em **português** seguindo os padrões existentes
- Aplique o **Result Pattern** para tratamento de erros

## Licença

Este projeto está licenciado sob a licença MIT - veja o arquivo [LICENSE](LICENSE) para detalhes.
