import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:intl/intl.dart';
import '../../models/exercise.dart' as exercise_model;
import '../../models/exercise_record.dart';
import '../../services/firebase_service.dart';

class ExerciseRecordScreen extends StatefulWidget {
  final ExerciseRecord? record;
  final exercise_model.Exercise? exercise;

  const ExerciseRecordScreen({
    super.key,
    this.record,
    this.exercise,
  });

  @override
  State<ExerciseRecordScreen> createState() => _ExerciseRecordScreenState();
}

class _ExerciseRecordScreenState extends State<ExerciseRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _durationController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  exercise_model.Exercise? _selectedExercise;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedExercise = widget.exercise;
    if (widget.record != null) {
      _durationController.text = widget.record!.durationMinutes.toString();
      _noteController.text = widget.record!.note ?? '';
      _selectedDate = widget.record!.date;
    }
  }

  @override
  void dispose() {
    _durationController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveRecord() async {
    if (_formKey.currentState!.validate() && _selectedExercise != null) {
      setState(() => _isLoading = true);
      try {
        final record = ExerciseRecord(
          id: widget.record?.id ??
              DateTime.now().millisecondsSinceEpoch.toString(),
          exerciseId: _selectedExercise!.id,
          date: _selectedDate,
          durationMinutes: int.parse(_durationController.text),
          note: _noteController.text.isEmpty ? null : _noteController.text,
        );

        if (widget.record == null) {
          await Modular.get<FirebaseService>().addExerciseRecord(record);
        } else {
          await Modular.get<FirebaseService>().updateExerciseRecord(record);
        }

        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao salvar: ${e.toString()}')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.record == null ? 'Nova Atividade' : 'Editar Atividade'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.exercise == null)
                StreamBuilder<List<exercise_model.Exercise>>(
                  stream: Modular.get<FirebaseService>().getExercises(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Text('Erro ao carregar exercícios');
                    }

                    if (!snapshot.hasData) {
                      return const CircularProgressIndicator();
                    }

                    final exercises = snapshot.data!;
                    return DropdownButtonFormField<exercise_model.Exercise>(
                      value: _selectedExercise,
                      decoration: const InputDecoration(
                        labelText: 'Exercício',
                        border: OutlineInputBorder(),
                      ),
                      items: exercises.map((exercise) {
                        return DropdownMenuItem(
                          value: exercise,
                          child: Text(exercise.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedExercise = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Por favor, selecione um exercício';
                        }
                        return null;
                      },
                    );
                  },
                ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _durationController,
                decoration: const InputDecoration(
                  labelText: 'Duração (minutos)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a duração';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Por favor, insira um número válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Data',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    DateFormat('dd/MM/yyyy').format(_selectedDate),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'Observação (opcional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              if (_selectedExercise != null) ...[
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Informações do Exercício',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text('Categoria: ${_selectedExercise!.category}'),
                        Text(
                            'Calorias por minuto: ${_selectedExercise!.caloriesPerMinute.toStringAsFixed(1)}'),
                        if (_durationController.text.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Calorias totais: ${(_selectedExercise!.caloriesPerMinute * double.parse(_durationController.text)).toStringAsFixed(1)}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveRecord,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : Text(widget.record == null ? 'Salvar' : 'Atualizar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
