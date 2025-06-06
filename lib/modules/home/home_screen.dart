import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'dart:convert';
import '../../services/firebase_service.dart';
import '../../modules/auth/login_screen.dart';
import '../../models/user_profile.dart';
import 'tmb_calculator_screen.dart';
import 'weight_record_screen.dart';
import 'exercise_record_screen.dart';
import 'exercise_list_screen.dart';
import 'exercise_management_screen.dart';
import 'tmb_history_screen.dart';
import 'exercise_history_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Widget _buildProfileImage(String imageUrl) {
    try {
      if (imageUrl.startsWith('data:image')) {
        // É uma imagem base64
        final base64String = imageUrl.split(',')[1];
        final bytes = base64Decode(base64String);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.person, color: Colors.white),
        );
      } else if (imageUrl.startsWith('http')) {
        // É uma URL normal (para compatibilidade com dados antigos)
        return Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.person, color: Colors.white),
        );
      } else {
        return const Icon(Icons.person, color: Colors.white);
      }
    } catch (e) {
      return const Icon(Icons.person, color: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    final firebaseService = Modular.get<FirebaseService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Basal Fit'),
        actions: [
          StreamBuilder<UserProfile?>(
            stream: firebaseService.getUserProfileStream(),
            builder: (context, snapshot) {
              final profile = snapshot.data;
              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ProfileScreen()),
                ),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: profile?.profileImageUrl != null
                        ? _buildProfileImage(profile!.profileImageUrl!)
                        : const Icon(Icons.person, color: Colors.white),
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await firebaseService.signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Saudação personalizada
            StreamBuilder<UserProfile?>(
              stream: firebaseService.getUserProfileStream(),
              builder: (context, snapshot) {
                final profile = snapshot.data;
                final name = profile?.name ??
                    firebaseService.currentUser?.displayName ??
                    'Usuário';

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade400, Colors.blue.shade600],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Olá, ${name.split(' ').first}! 👋',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Bem-vindo ao Basal Fit',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Grid de opções
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildMenuCard(
                    context,
                    'Calcular TMB',
                    Icons.calculate,
                    Colors.blue,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TMBCalculatorScreen(),
                      ),
                    ),
                  ),
                  _buildMenuCard(
                    context,
                    'Histórico TMB',
                    Icons.history,
                    Colors.green,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TMBHistoryScreen(),
                      ),
                    ),
                  ),
                  _buildMenuCard(
                    context,
                    'Registrar Peso',
                    Icons.monitor_weight,
                    Colors.orange,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const WeightRecordScreen(),
                      ),
                    ),
                  ),
                  _buildMenuCard(
                    context,
                    'Registrar Exercício',
                    Icons.add_box,
                    Colors.purple,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ExerciseListScreen(),
                      ),
                    ),
                  ),
                  _buildMenuCard(
                    context,
                    'Gerenciar Exercícios',
                    Icons.fitness_center,
                    Colors.red,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ExerciseManagementScreen(),
                      ),
                    ),
                  ),
                  _buildMenuCard(
                    context,
                    'Histórico de Exercícios',
                    Icons.timeline,
                    Colors.teal,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ExerciseHistoryScreen(),
                      ),
                    ),
                  ),
                  _buildMenuCard(
                    context,
                    'Meu Perfil',
                    Icons.person,
                    Colors.indigo,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfileScreen(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.8),
                color.withOpacity(0.6),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: Colors.white,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
