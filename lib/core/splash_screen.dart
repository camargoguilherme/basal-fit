import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/app_routes.dart';
import '../services/firebase_service.dart';
import '../models/user_profile.dart';
import '../providers/auth_provider.dart' as app_auth;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _checkAuthStatus();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _animationController.forward();
  }

  Future<void> _checkAuthStatus() async {
    // Aguarda um mínimo de 2 segundos para mostrar a splash
    await Future.delayed(const Duration(seconds: 2));

    try {
      final authProvider = Modular.get<app_auth.AuthProvider>();

      // Aguarda a inicialização do AuthProvider se necessário
      if (!authProvider.isInitialized) {
        await Future.delayed(const Duration(milliseconds: 500));
      }

      if (authProvider.isAuthenticated && authProvider.user != null) {
        // Usuário está logado, verifica se tem perfil
        final firebaseService = Modular.get<FirebaseService>();
        final profile = await firebaseService.getUserProfile();

        if (profile == null) {
          // Cria perfil inicial se não existir
          await _createInitialProfile(authProvider.user!, firebaseService);
        }

        // Redireciona para home
        if (mounted) {
          Modular.to.pushReplacementNamed(AppRoutes.home);
        }
      } else {
        // Usuário não está logado, vai para tela de login
        if (mounted) {
          Modular.to.pushReplacementNamed(AppRoutes.login);
        }
      }
    } catch (e) {
      // Em caso de erro, vai para tela de login
      debugPrint('Erro ao verificar autenticação: $e');
      if (mounted) {
        Modular.to.pushReplacementNamed(AppRoutes.login);
      }
    }
  }

  Future<void> _createInitialProfile(
      User user, FirebaseService firebaseService) async {
    try {
      final profile = UserProfile(
        id: user.uid,
        name: user.displayName ?? '',
        email: user.email ?? '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await firebaseService.createUserProfile(profile);
    } catch (e) {
      debugPrint('Erro ao criar perfil inicial: $e');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.blue.shade400,
                  Colors.blue.shade600,
                  Colors.blue.shade800,
                ],
              ),
            ),
            child: Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo/Ícone do app
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.fitness_center,
                          size: 60,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Nome do app
                      const Text(
                        'Basal Fit',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Subtítulo
                      const Text(
                        'Seu companheiro fitness',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      const SizedBox(height: 48),

                      // Indicador de carregamento
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white.withOpacity(0.8),
                          ),
                          strokeWidth: 3,
                        ),
                      ),
                      const SizedBox(height: 16),

                      const Text(
                        'Verificando conta...',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
