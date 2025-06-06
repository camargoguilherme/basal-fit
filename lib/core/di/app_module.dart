import 'package:flutter_modular/flutter_modular.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../interfaces/repositories.dart';
import '../../repositories/firebase_user_repository.dart';
import '../../use_cases/user_use_cases.dart';
import '../../services/firebase_service.dart';
import '../../providers/auth_provider.dart' as app_providers;

/// Módulo principal de dependency injection do app
class AppDependencyModule extends Module {
  @override
  void exportedBinds(Injector i) {
    // Firebase instances (Singletons)
    i.addSingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
    i.addSingleton<FirebaseAuth>(() => FirebaseAuth.instance);

    // Repositories (Singletons)
    i.addSingleton<IUserRepository>(() => FirebaseUserRepository(
          firestore: i.get<FirebaseFirestore>(),
          auth: i.get<FirebaseAuth>(),
        ));

    // Legacy Firebase Service (para compatibilidade gradual)
    i.addSingleton<FirebaseService>(() => FirebaseService());

    // Use Cases (Singletons)
    i.addSingleton<UserUseCases>(() => UserUseCases(
          userRepository: i.get<IUserRepository>(),
          authRepository: i.get<IAuthRepository>(),
        ));

    // Providers (Singletons)
    i.addSingleton<app_providers.AuthProvider>(
        () => app_providers.AuthProvider());
  }
}

/// Extensões para facilitar o acesso às dependências
extension ModularExtensions on IModularNavigator {
  /// Obtém o repository de usuário
  IUserRepository get userRepository => Modular.get<IUserRepository>();

  /// Obtém os use cases de usuário
  UserUseCases get userUseCases => Modular.get<UserUseCases>();

  /// Obtém o provider de autenticação
  app_providers.AuthProvider get authProvider =>
      Modular.get<app_providers.AuthProvider>();

  /// Obtém o serviço Firebase (legacy)
  FirebaseService get firebaseService => Modular.get<FirebaseService>();
}

/// Utility para facilitar acesso às dependências
class DI {
  static T get<T extends Object>() => Modular.get<T>();

  // Getters específicos para facilitar o uso
  static IUserRepository get userRepository => get<IUserRepository>();
  static UserUseCases get userUseCases => get<UserUseCases>();
  static app_providers.AuthProvider get authProvider =>
      get<app_providers.AuthProvider>();
  static FirebaseService get firebaseService => get<FirebaseService>();
  static FirebaseAuth get firebaseAuth => get<FirebaseAuth>();
  static FirebaseFirestore get firestore => get<FirebaseFirestore>();
}

/// Mixin para facilitar o uso de dependências em widgets
mixin DependencyMixin {
  IUserRepository get userRepository => DI.userRepository;
  UserUseCases get userUseCases => DI.userUseCases;
  app_providers.AuthProvider get authProvider => DI.authProvider;
  FirebaseService get firebaseService => DI.firebaseService;
}
