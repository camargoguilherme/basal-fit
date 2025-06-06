import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:intl/intl.dart';
import '../../models/exercise.dart' as exercise_model;
import '../../models/exercise_record.dart';
import '../../services/firebase_service.dart';
import 'exercise_record_screen.dart';

class ExerciseHistoryScreen extends StatelessWidget {
  const ExerciseHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Atividades'),
      ),
      body: StreamBuilder<List<ExerciseRecord>>(
        stream: Modular.get<FirebaseService>().getExerciseRecords(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Erro ao carregar histórico: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final records = snapshot.data!;
          if (records.isEmpty) {
            return const Center(
              child: Text('Nenhum registro encontrado'),
            );
          }

          return ListView.builder(
            itemCount: records.length,
            itemBuilder: (context, index) {
              final record = records[index];
              return FutureBuilder<exercise_model.Exercise?>(
                future: _getExercise(context, record.exerciseId),
                builder: (context, exerciseSnapshot) {
                  if (!exerciseSnapshot.hasData) {
                    return const SizedBox.shrink();
                  }

                  final exercise = exerciseSnapshot.data!;
                  final calories =
                      exercise.caloriesPerMinute * record.durationMinutes;

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: ListTile(
                      title: Text(exercise.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('dd/MM/yyyy').format(record.date),
                          ),
                          Text(
                            '${record.durationMinutes} minutos - ${calories.toStringAsFixed(1)} calorias',
                          ),
                          if (record.note != null) Text(record.note!),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ExerciseRecordScreen(
                                record: record,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<exercise_model.Exercise?> _getExercise(
    BuildContext context,
    String exerciseId,
  ) async {
    final exercises = await Modular.get<FirebaseService>().getExercises().first;
    return exercises.firstWhere(
      (exercise) => exercise.id == exerciseId,
      orElse: () => throw Exception('Exercício não encontrado'),
    );
  }
}
