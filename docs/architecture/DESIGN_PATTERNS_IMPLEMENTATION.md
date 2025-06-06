# Implementação de Padrões de Projeto - Basal Fit

## 📋 Visão Geral

Este documento descreve os padrões de projeto implementados para melhorar a arquitetura, manutenibilidade e qualidade do código do aplicativo Basal Fit.

## 🏗️ Arquitetura Implementada

### **Clean Architecture + MVVM**

```
┌─────────────────────────────────────────────────────────────┐
│                     PRESENTATION LAYER                      │
├─────────────────────────────────────────────────────────────┤
│  Widgets/Screens  │  Providers  │  ViewModels              │
└─────────────────────────────────────────────────────────────┘
                                │
┌─────────────────────────────────────────────────────────────┐
│                      DOMAIN LAYER                          │
├─────────────────────────────────────────────────────────────┤
│  Use Cases  │  Interfaces  │  Entities  │  Value Objects   │
└─────────────────────────────────────────────────────────────┘
                                │
┌─────────────────────────────────────────────────────────────┐
│                       DATA LAYER                           │
├─────────────────────────────────────────────────────────────┤
│  Repositories  │  Data Sources  │  Models  │  Mappers      │
└─────────────────────────────────────────────────────────────┘
```

## 🎯 Padrões Implementados

### 1. **Repository Pattern**

**Localização:** `lib/core/interfaces/repositories.dart`

**Objetivo:** Abstrair acesso a dados e centralizar lógica de persistência.

```dart
abstract class IUserRepository {
  Future<UserProfile?> getCurrentUserProfile();
  Future<void> updateUserProfile(UserProfile profile);
  Stream<UserProfile?> watchCurrentUserProfile();
  // ...
}

class FirebaseUserRepository implements IUserRepository {
  // Implementação específica do Firebase
}
```

**Benefícios:**

- ✅ Separação de responsabilidades
- ✅ Facilita testes unitários
- ✅ Permite trocar implementações facilmente
- ✅ Interface clara e consistente

### 2. **Use Case Pattern (Interactors)**

**Localização:** `lib/use_cases/user_use_cases.dart`

**Objetivo:** Encapsular lógica de negócio específica.

```dart
class UserUseCases {
  Future<Result<double>> calculateTMB() async {
    // Lógica específica para calcular TMB
    // Validações, regras de negócio, etc.
  }

  Future<Result<UserRecommendations>> getUserRecommendations() async {
    // Lógica para gerar recomendações personalizadas
  }
}
```

**Benefícios:**

- ✅ Lógica de negócio centralizada
- ✅ Reutilização entre diferentes telas
- ✅ Testabilidade melhorada
- ✅ Single Responsibility Principle

### 3. **Result Pattern**

**Localização:** `lib/core/utils/result.dart`

**Objetivo:** Melhor tratamento de sucesso/erro sem exceptions.

```dart
sealed class Result<T> {
  factory Result.success(T data) = Success<T>;
  factory Result.error(AppException exception) = Error<T>;

  R when<R>({
    required R Function(T data) success,
    required R Function(AppException exception) error,
  });
}

// Uso:
final result = await userUseCases.calculateTMB();
result.when(
  success: (tmb) => showTMBResult(tmb),
  error: (error) => showErrorMessage(error.message),
);
```

**Benefícios:**

- ✅ Tratamento explícito de erros
- ✅ Evita exceptions não tratadas
- ✅ Código mais legível e previsível
- ✅ Composição de operações

### 4. **Factory Pattern para Exceptions**

**Localização:** `lib/core/exceptions/app_exceptions.dart`

**Objetivo:** Criar exceções tipadas e específicas.

```dart
class AuthException extends AppException {
  factory AuthException.invalidCredentials() {
    return const AuthException('Credenciais inválidas', code: 'invalid-credentials');
  }

  factory AuthException.userNotFound() {
    return const AuthException('Usuário não encontrado', code: 'user-not-found');
  }
}

// Uso:
throw AuthException.invalidCredentials();
```

**Benefícios:**

- ✅ Exceções bem definidas
- ✅ Mensagens consistentes
- ✅ Facilita tratamento específico
- ✅ Melhor debugging

### 5. **Dependency Injection**

**Localização:** `lib/core/di/app_module.dart`

**Objetivo:** Gerenciar dependências de forma centralizada.

```dart
class AppDependencyModule extends Module {
  @override
  void exportedBinds(Injector i) {
    i.addSingleton<IUserRepository>(() => FirebaseUserRepository(
      firestore: i.get<FirebaseFirestore>(),
      auth: i.get<FirebaseAuth>(),
    ));
  }
}

// Uso facilitado:
class DI {
  static IUserRepository get userRepository => get<IUserRepository>();
  static UserUseCases get userUseCases => get<UserUseCases>();
}
```

**Benefícios:**

- ✅ Baixo acoplamento
- ✅ Facilita testes
- ✅ Configuração centralizada
- ✅ Lifetime management

### 6. **Constants Pattern**

**Localização:** `lib/core/constants/app_constants.dart`

**Objetivo:** Centralizar constantes e configurações.

```dart
class AppConstants {
  static const String usersCollection = 'users';
  static const int minPasswordLength = 6;
  static const double defaultPadding = 16.0;
}

enum ExerciseCategory {
  cardio('Cardio'),
  strength('Força'),
  flexibility('Flexibilidade');

  const ExerciseCategory(this.displayName);
  final String displayName;
}
```

**Benefícios:**

- ✅ Evita magic numbers/strings
- ✅ Facilita manutenção
- ✅ Configuração centralizada
- ✅ Type safety com enums

### 7. **Mixin Pattern**

**Localização:** `lib/core/di/app_module.dart`

**Objetivo:** Facilitar acesso a dependências.

```dart
mixin DependencyMixin {
  IUserRepository get userRepository => DI.userRepository;
  UserUseCases get userUseCases => DI.userUseCases;
  FirebaseService get firebaseService => DI.firebaseService;
}

// Uso em widgets:
class ProfileScreen extends StatefulWidget with DependencyMixin {
  void _loadProfile() async {
    final result = await userUseCases.getCurrentUserProfile();
    // ...
  }
}
```

**Benefícios:**

- ✅ Reduz boilerplate
- ✅ Acesso consistente
- ✅ Reutilização de código
- ✅ Interface limpa

## 🔧 Estrutura de Arquivos

```
lib/
├── core/
│   ├── constants/
│   │   └── app_constants.dart          # Constantes centralizadas
│   ├── exceptions/
│   │   └── app_exceptions.dart         # Exceções customizadas
│   ├── interfaces/
│   │   └── repositories.dart           # Interfaces dos repositories
│   ├── utils/
│   │   └── result.dart                 # Result pattern
│   └── di/
│       └── app_module.dart             # Dependency injection
├── repositories/
│   └── firebase_user_repository.dart   # Implementação repositories
├── use_cases/
│   └── user_use_cases.dart             # Lógica de negócio
├── models/                             # Entities/Models
├── providers/                          # State management
├── modules/                            # UI/Presentation
└── services/                           # External services
```

## 📊 Princípios SOLID Aplicados

### **S - Single Responsibility Principle**

- ✅ Cada classe tem uma responsabilidade específica
- ✅ Use cases encapsulam uma funcionalidade específica
- ✅ Repositories lidam apenas com persistência

### **O - Open/Closed Principle**

- ✅ Interfaces permitem extensão sem modificação
- ✅ Novos repositories podem ser adicionados facilmente
- ✅ Result pattern permite novos tipos de resultado

### **L - Liskov Substitution Principle**

- ✅ Implementações de repositories são intercambiáveis
- ✅ Qualquer AppException pode ser usada onde esperada

### **I - Interface Segregation Principle**

- ✅ Interfaces específicas para cada tipo de repository
- ✅ Clients dependem apenas do que precisam

### **D - Dependency Inversion Principle**

- ✅ Use cases dependem de abstrações (interfaces)
- ✅ Implementações concretas são injetadas
- ✅ Alto nível não depende de baixo nível

## 🚀 Benefícios Alcançados

### **Manutenibilidade**

- ✅ Código organizado em camadas
- ✅ Responsabilidades bem definidas
- ✅ Baixo acoplamento entre componentes

### **Testabilidade**

- ✅ Dependências podem ser mockadas
- ✅ Lógica de negócio isolada
- ✅ Interfaces facilitam testes unitários

### **Escalabilidade**

- ✅ Novos features seguem padrões estabelecidos
- ✅ Fácil adição de novos repositories
- ✅ Arquitetura permite crescimento

### **Legibilidade**

- ✅ Código autodocumentado
- ✅ Padrões consistentes
- ✅ Separação clara de responsabilidades

### **Confiabilidade**

- ✅ Tratamento robusto de erros
- ✅ Validações centralizadas
- ✅ Result pattern previne crashes

## 📝 Próximos Passos

### **Curto Prazo**

1. Implementar repositories para outras entidades
2. Adicionar mais use cases específicos
3. Criar testes unitários para use cases

### **Médio Prazo**

1. Implementar cache pattern
2. Adicionar logging estruturado
3. Observer pattern para notificações

### **Longo Prazo**

1. Implementar offline-first strategy
2. Adicionar analytics estruturados
3. Feature flags system

---

**Status:** ✅ Implementado com Sucesso
**Cobertura:** Arquitetura base estabelecida
**Próximo:** Migração gradual de código legado
