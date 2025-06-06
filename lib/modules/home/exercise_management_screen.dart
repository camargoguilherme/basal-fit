import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import '../../models/exercise.dart' as exercise_model;
import '../../services/firebase_service.dart';

class ExerciseManagementScreen extends StatefulWidget {
  const ExerciseManagementScreen({super.key});

  @override
  State<ExerciseManagementScreen> createState() =>
      _ExerciseManagementScreenState();
}

class _ExerciseManagementScreenState extends State<ExerciseManagementScreen> {
  final _firebaseService = Modular.get<FirebaseService>();

  void _showAddExerciseDialog() {
    _showExerciseDialog();
  }

  void _showEditExerciseDialog(exercise_model.Exercise exercise) {
    _showExerciseDialog(exercise: exercise);
  }

  void _showExerciseDialog({exercise_model.Exercise? exercise}) {
    final nameController = TextEditingController(text: exercise?.name);
    final categoryController = TextEditingController(text: exercise?.category);
    final caloriesController = TextEditingController(
      text: exercise?.caloriesPerMinute.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(exercise == null ? 'Novo Exercício' : 'Editar Exercício'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Exercício',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(
                  labelText: 'Categoria',
                  border: OutlineInputBorder(),
                  hintText: 'Ex: Cardio, Força, Flexibilidade',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: caloriesController,
                decoration: const InputDecoration(
                  labelText: 'Calorias por Minuto',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty ||
                  categoryController.text.trim().isEmpty ||
                  caloriesController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Preencha todos os campos')),
                );
                return;
              }

              final calories = double.tryParse(caloriesController.text);
              if (calories == null || calories <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Calorias devem ser um número positivo')),
                );
                return;
              }

              final newExercise = exercise_model.Exercise(
                id: exercise?.id ??
                    DateTime.now().millisecondsSinceEpoch.toString(),
                name: nameController.text.trim(),
                category: categoryController.text.trim(),
                caloriesPerMinute: calories,
              );

              try {
                if (exercise == null) {
                  await _firebaseService.addExercise(newExercise);
                } else {
                  await _firebaseService.updateExercise(newExercise);
                }

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(exercise == null
                          ? 'Exercício adicionado com sucesso!'
                          : 'Exercício atualizado com sucesso!'),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro: ${e.toString()}')),
                  );
                }
              }
            },
            child: Text(exercise == null ? 'Adicionar' : 'Salvar'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteExercise(exercise_model.Exercise exercise) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Tem certeza que deseja excluir "${exercise.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              try {
                await _firebaseService.deleteExercise(exercise.id);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Exercício excluído com sucesso!')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro ao excluir: ${e.toString()}')),
                  );
                }
              }
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  void _addDefaultExercises() async {
    final defaultExercises = [
      exercise_model.Exercise(
        id: 'corrida',
        name: 'Corrida',
        category: 'Cardio',
        caloriesPerMinute: 10.0,
      ),
      exercise_model.Exercise(
        id: 'caminhada',
        name: 'Caminhada',
        category: 'Cardio',
        caloriesPerMinute: 5.0,
      ),
      exercise_model.Exercise(
        id: 'natacao',
        name: 'Natação',
        category: 'Cardio',
        caloriesPerMinute: 12.0,
      ),
      exercise_model.Exercise(
        id: 'musculacao',
        name: 'Musculação',
        category: 'Força',
        caloriesPerMinute: 8.0,
      ),
      exercise_model.Exercise(
        id: 'yoga',
        name: 'Yoga',
        category: 'Flexibilidade',
        caloriesPerMinute: 4.0,
      ),
      exercise_model.Exercise(
        id: 'ciclismo',
        name: 'Ciclismo',
        category: 'Cardio',
        caloriesPerMinute: 9.0,
      ),
    ];

    try {
      for (final exercise in defaultExercises) {
        await _firebaseService.addExercise(exercise);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Exercícios padrão adicionados com sucesso!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erro ao adicionar exercícios: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Exercícios'),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'add_defaults',
                child: Row(
                  children: [
                    Icon(Icons.add_circle_outline),
                    SizedBox(width: 8),
                    Text('Adicionar Exercícios Padrão'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'add_defaults') {
                _addDefaultExercises();
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<List<exercise_model.Exercise>>(
        stream: _firebaseService.getExercises(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Erro ao carregar exercícios',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(snapshot.error.toString()),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: const Text('Tentar Novamente'),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final exercises = snapshot.data!;

          if (exercises.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.fitness_center,
                      size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhum exercício cadastrado',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  const Text('Adicione alguns exercícios para começar'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _addDefaultExercises,
                    child: const Text('Adicionar Exercícios Padrão'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: _showAddExerciseDialog,
                    child: const Text('Criar Exercício Personalizado'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: exercises.length,
            itemBuilder: (context, index) {
              final exercise = exercises[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getCategoryColor(exercise.category),
                    child: Icon(
                      _getCategoryIcon(exercise.category),
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    exercise.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${exercise.category} • ${exercise.caloriesPerMinute.toStringAsFixed(1)} cal/min',
                  ),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: 8),
                            Text('Editar'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Excluir',
                                style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showEditExerciseDialog(exercise);
                      } else if (value == 'delete') {
                        _confirmDeleteExercise(exercise);
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddExerciseDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'cardio':
        return Colors.red;
      case 'força':
        return Colors.blue;
      case 'flexibilidade':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'cardio':
        return Icons.favorite;
      case 'força':
        return Icons.fitness_center;
      case 'flexibilidade':
        return Icons.self_improvement;
      default:
        return Icons.sports;
    }
  }
}
