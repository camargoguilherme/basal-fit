import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:intl/intl.dart';
import '../../models/tmb_record.dart';
import '../../services/firebase_service.dart';

class TMBCalculatorScreen extends StatefulWidget {
  const TMBCalculatorScreen({super.key});

  @override
  State<TMBCalculatorScreen> createState() => _TMBCalculatorScreenState();
}

class _TMBCalculatorScreenState extends State<TMBCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _ageController = TextEditingController();
  String _selectedGender = 'Masculino';
  double? _tmb;
  String? _recommendation;
  bool _isLoading = false;

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _calculateTMB() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final weight = double.parse(_weightController.text);
        final height = double.parse(_heightController.text);
        final age = int.parse(_ageController.text);

        // Fórmula de Harris-Benedict
        if (_selectedGender == 'Masculino') {
          _tmb = 66 + (13.7 * weight) + (5 * height) - (6.8 * age);
        } else {
          _tmb = 655 + (9.6 * weight) + (1.8 * height) - (4.7 * age);
        }

        // Gerar recomendações baseadas no TMB
        if (_tmb! < 1200) {
          _recommendation =
              'Seu metabolismo está muito baixo. Considere consultar um profissional de saúde.';
        } else if (_tmb! < 1500) {
          _recommendation =
              'Seu metabolismo está abaixo da média. Considere aumentar sua atividade física.';
        } else if (_tmb! < 2000) {
          _recommendation =
              'Seu metabolismo está normal. Mantenha seus hábitos saudáveis.';
        } else if (_tmb! < 2500) {
          _recommendation =
              'Seu metabolismo está acima da média. Continue com sua rotina de exercícios.';
        } else {
          _recommendation =
              'Seu metabolismo está muito alto. Certifique-se de consumir calorias suficientes.';
        }

        // Salvar o registro
        final record = TMBRecord(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          date: DateTime.now(),
          weight: weight,
          height: height,
          age: age,
          gender: _selectedGender,
          tmb: _tmb!,
        );

        await Modular.get<FirebaseService>().addTMBRecord(record);

        if (mounted) {
          setState(() {});
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao calcular TMB: ${e.toString()}')),
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
        title: const Text('Calculadora TMB'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: const InputDecoration(
                  labelText: 'Sexo',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                      value: 'Masculino', child: Text('Masculino')),
                  DropdownMenuItem(value: 'Feminino', child: Text('Feminino')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _weightController,
                decoration: const InputDecoration(
                  labelText: 'Peso (kg)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira seu peso';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Por favor, insira um número válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _heightController,
                decoration: const InputDecoration(
                  labelText: 'Altura (cm)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira sua altura';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Por favor, insira um número válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(
                  labelText: 'Idade',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira sua idade';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Por favor, insira um número válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _calculateTMB,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Calcular TMB'),
              ),
              if (_tmb != null) ...[
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sua Taxa Metabólica Basal (TMB) é:',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_tmb!.toStringAsFixed(2)} calorias/dia',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Recomendação:',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(_recommendation!),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
