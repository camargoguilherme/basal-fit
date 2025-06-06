import 'package:flutter_modular/flutter_modular.dart';
import 'core/app_routes.dart';
import 'core/splash_screen.dart';
import 'services/firebase_service.dart';
import 'providers/auth_provider.dart';
import 'modules/auth/auth_module.dart';
import 'modules/home/home_module.dart';

class AppModule extends Module {
  @override
  void binds(Injector i) {
    // Serviços globais
    i.addSingleton<FirebaseService>(FirebaseService.new);
    i.addSingleton<AuthProvider>(AuthProvider.new);
  }

  @override
  void routes(RouteManager r) {
    // Rota inicial - Splash Screen
    r.child(AppRoutes.initial, child: (context) => const SplashScreen());

    // Módulos da aplicação
    r.module(AppRoutes.auth, module: AuthModule());
    r.module(AppRoutes.home, module: HomeModule());
  }
}
