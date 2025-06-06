import 'package:flutter_modular/flutter_modular.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

class AuthModule extends Module {
  @override
  void routes(RouteManager r) {
    r.child('/', child: (context) => const LoginScreen());
    r.child('/register', child: (context) => const RegisterScreen());
    r.child('/forgot-password',
        child: (context) => const ForgotPasswordScreen());
  }
}
