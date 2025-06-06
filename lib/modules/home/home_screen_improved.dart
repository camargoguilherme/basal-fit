import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/ui_components.dart';
import '../../services/firebase_service.dart';
import '../../models/user_profile.dart';
import '../auth/login_screen.dart';

// Importações das telas
import 'tmb_calculator_screen.dart';
import 'weight_record_screen.dart';
import 'exercise_list_screen.dart';
import 'exercise_management_screen.dart';
import 'tmb_history_screen.dart';
import 'exercise_history_screen.dart';
import 'profile_screen.dart';

class HomeScreenImproved extends StatefulWidget {
  const HomeScreenImproved({super.key});

  @override
  State<HomeScreenImproved> createState() => _HomeScreenImprovedState();
}

class _HomeScreenImprovedState extends State<HomeScreenImproved> {
  final FirebaseService _firebaseService = Modular.get<FirebaseService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverPadding(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildWelcomeCard(),
                const SizedBox(height: AppTheme.spacingL),
                _buildQuickStats(),
                const SizedBox(height: AppTheme.spacingL),
                const SectionHeader(
                  title: 'Principais Ações',
                  subtitle: 'Gerencie seu fitness e saúde',
                ),
                const SizedBox(height: AppTheme.spacingM),
                _buildMainActions(),
                const SizedBox(height: AppTheme.spacingL),
                const SectionHeader(
                  title: 'Histórico e Dados',
                  subtitle: 'Acompanhe seu progresso',
                ),
                const SizedBox(height: AppTheme.spacingM),
                _buildSecondaryActions(),
                const SizedBox(height: AppTheme.spacingXXL),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: AppTheme.primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Basal Fit',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.primaryLinearGradient,
          ),
        ),
      ),
      actions: [
        StreamBuilder<UserProfile?>(
          stream: _firebaseService.getUserProfileStream(),
          builder: (context, snapshot) {
            final profile = snapshot.data;
            return Padding(
              padding: const EdgeInsets.only(right: AppTheme.spacingM),
              child: UserAvatar(
                imageUrl: profile?.profileImageUrl,
                name: profile?.name,
                size: 40,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                ),
              ),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.white),
          onPressed: _handleLogout,
        ),
      ],
    );
  }

  Widget _buildWelcomeCard() {
    return StreamBuilder<UserProfile?>(
      stream: _firebaseService.getUserProfileStream(),
      builder: (context, snapshot) {
        final profile = snapshot.data;
        final name = profile?.name ??
            _firebaseService.currentUser?.displayName ??
            'Usuário';

        final firstName = name.split(' ').first;
        final timeOfDay = _getTimeOfDay();

        return GradientCard(
          gradientColors: AppTheme.primaryGradient,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$timeOfDay, $firstName! 👋',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: AppTheme.spacingXS),
                        Text(
                          'Pronto para cuidar da sua saúde hoje?',
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Colors.white70,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.favorite,
                    color: Colors.white,
                    size: 32,
                  ),
                ],
              ),
              if (profile != null && _isProfileIncomplete(profile)) ...[
                const SizedBox(height: AppTheme.spacingM),
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacingS),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppTheme.radiusS),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: AppTheme.spacingS),
                      Expanded(
                        child: Text(
                          'Complete seu perfil para cálculos mais precisos',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.white,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickStats() {
    return StreamBuilder<UserProfile?>(
      stream: _firebaseService.getUserProfileStream(),
      builder: (context, snapshot) {
        final profile = snapshot.data;

        return Row(
          children: [
            Expanded(
              child: StatCard(
                label: 'TMB Estimada',
                value: profile?.weight != null &&
                        profile?.height != null &&
                        profile?.age != null &&
                        profile?.gender != null
                    ? '${_calculateTMB(profile!).toStringAsFixed(0)} kcal'
                    : '--',
                icon: Icons.local_fire_department,
                color: AppTheme.warningColor,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TMBCalculatorScreen(),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: StatCard(
                label: 'Peso Atual',
                value: profile?.weight != null
                    ? '${profile!.weight!.toStringAsFixed(1)} kg'
                    : '--',
                icon: Icons.monitor_weight,
                color: AppTheme.successColor,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WeightRecordScreen(),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMainActions() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: AppTheme.spacingM,
      mainAxisSpacing: AppTheme.spacingM,
      children: [
        MenuCard(
          title: 'Calcular TMB',
          subtitle: 'Taxa Metabólica Basal',
          icon: Icons.calculate,
          gradientColors: AppTheme.primaryGradient,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TMBCalculatorScreen(),
            ),
          ),
        ),
        MenuCard(
          title: 'Registrar Exercício',
          subtitle: 'Nova atividade',
          icon: Icons.fitness_center,
          gradientColors: AppTheme.successGradient,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ExerciseListScreen(),
            ),
          ),
        ),
        MenuCard(
          title: 'Peso Corporal',
          subtitle: 'Acompanhar peso',
          icon: Icons.monitor_weight,
          gradientColors: AppTheme.warningGradient,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const WeightRecordScreen(),
            ),
          ),
        ),
        MenuCard(
          title: 'Meu Perfil',
          subtitle: 'Dados pessoais',
          icon: Icons.person,
          gradientColors: const [
            Color(0xFF673AB7),
            Color(0xFF9C27B0),
          ],
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ProfileScreen(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSecondaryActions() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: MenuCard(
                title: 'Histórico TMB',
                icon: Icons.history,
                gradientColors: const [
                  Color(0xFF2196F3),
                  Color(0xFF03DAC6),
                ],
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TMBHistoryScreen(),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: MenuCard(
                title: 'Exercícios',
                icon: Icons.timeline,
                gradientColors: const [
                  Color(0xFF4CAF50),
                  Color(0xFF8BC34A),
                ],
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ExerciseHistoryScreen(),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingM),
        SizedBox(
          width: double.infinity,
          child: MenuCard(
            title: 'Gerenciar Tipos de Exercício',
            subtitle: 'Criar e editar exercícios',
            icon: Icons.settings,
            gradientColors: const [
              Color(0xFFFF5722),
              Color(0xFFFF8A65),
            ],
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ExerciseManagementScreen(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Bom dia';
    } else if (hour < 18) {
      return 'Boa tarde';
    } else {
      return 'Boa noite';
    }
  }

  bool _isProfileIncomplete(UserProfile profile) {
    return profile.weight == null ||
        profile.height == null ||
        profile.age == null ||
        profile.gender == null ||
        profile.activityLevel == null;
  }

  double _calculateTMB(UserProfile profile) {
    if (profile.weight == null ||
        profile.height == null ||
        profile.age == null ||
        profile.gender == null) {
      return 0;
    }

    // Fórmula Mifflin-St Jeor
    double tmb;
    if (profile.gender == 'Masculino') {
      tmb = 88.362 +
          (13.397 * profile.weight!) +
          (4.799 * profile.height!) -
          (5.677 * profile.age!);
    } else {
      tmb = 447.593 +
          (9.247 * profile.weight!) +
          (3.098 * profile.height!) -
          (4.330 * profile.age!);
    }

    return tmb;
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Saída'),
        content: const Text('Tem certeza que deseja sair?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sair'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _firebaseService.signOut();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }
}
