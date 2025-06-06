import 'package:flutter_test/flutter_test.dart';
import 'package:basal_fit_flutter/models/exercise.dart';

void main() {
  group('Exercise', () {
    late Exercise exercise;

    setUp(() {
      exercise = Exercise(
        id: 'test-exercise-id',
        name: 'Corrida',
        description: 'Corrida em ritmo moderado',
        category: 'Cardio',
        caloriesPerMinute: 10.5,
        isDefault: true,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );
    });

    group('Criação do Exercício', () {
      test('deve criar exercício com todos os campos', () {
        // Assert
        expect(exercise.id, equals('test-exercise-id'));
        expect(exercise.name, equals('Corrida'));
        expect(exercise.description, equals('Corrida em ritmo moderado'));
        expect(exercise.category, equals('Cardio'));
        expect(exercise.caloriesPerMinute, equals(10.5));
        expect(exercise.isDefault, isTrue);
        expect(exercise.createdAt, equals(DateTime(2024, 1, 1)));
        expect(exercise.updatedAt, equals(DateTime(2024, 1, 1)));
      });

      test('deve criar exercício com campos opcionais nulos', () {
        // Arrange
        final minimalExercise = Exercise(
          id: 'minimal-id',
          name: 'Exercício Simples',
          category: 'Geral',
          caloriesPerMinute: 5.0,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );

        // Assert
        expect(minimalExercise.id, equals('minimal-id'));
        expect(minimalExercise.name, equals('Exercício Simples'));
        expect(minimalExercise.description, isNull);
        expect(minimalExercise.category, equals('Geral'));
        expect(minimalExercise.caloriesPerMinute, equals(5.0));
        expect(minimalExercise.isDefault, isFalse); // Default value
      });
    });

    group('Cálculo de Calorias', () {
      test('deve calcular calorias corretamente para duração específica', () {
        // Act
        final calories30min = exercise.calculateCalories(30);
        final calories60min = exercise.calculateCalories(60);
        final calories15min = exercise.calculateCalories(15);

        // Assert
        expect(calories30min, equals(315.0)); // 10.5 * 30
        expect(calories60min, equals(630.0)); // 10.5 * 60
        expect(calories15min, equals(157.5)); // 10.5 * 15
      });

      test('deve retornar 0 para duração 0 ou negativa', () {
        // Act
        final caloriesZero = exercise.calculateCalories(0);
        final caloriesNegative = exercise.calculateCalories(-10);

        // Assert
        expect(caloriesZero, equals(0.0));
        expect(caloriesNegative, equals(0.0));
      });

      test('deve lidar com calorias por minuto 0', () {
        // Arrange
        final exerciseWithZeroCalories =
            exercise.copyWith(caloriesPerMinute: 0.0);

        // Act
        final calories = exerciseWithZeroCalories.calculateCalories(30);

        // Assert
        expect(calories, equals(0.0));
      });
    });

    group('Serialização', () {
      test('deve converter para Map corretamente', () {
        // Act
        final map = exercise.toMap();

        // Assert
        expect(map['id'], equals('test-exercise-id'));
        expect(map['name'], equals('Corrida'));
        expect(map['description'], equals('Corrida em ritmo moderado'));
        expect(map['category'], equals('Cardio'));
        expect(map['caloriesPerMinute'], equals(10.5));
        expect(map['isDefault'], isTrue);
        expect(map['createdAt'], isA<String>());
        expect(map['updatedAt'], isA<String>());
      });

      test('deve criar Exercise de Map corretamente', () {
        // Arrange
        final map = {
          'id': 'test-exercise-2',
          'name': 'Musculação',
          'description': 'Treino de força',
          'category': 'Força',
          'caloriesPerMinute': 8.0,
          'isDefault': false,
          'createdAt': '2024-01-01T00:00:00.000',
          'updatedAt': '2024-01-01T00:00:00.000',
        };

        // Act
        final exerciseFromMap = Exercise.fromMap(map);

        // Assert
        expect(exerciseFromMap.id, equals('test-exercise-2'));
        expect(exerciseFromMap.name, equals('Musculação'));
        expect(exerciseFromMap.description, equals('Treino de força'));
        expect(exerciseFromMap.category, equals('Força'));
        expect(exerciseFromMap.caloriesPerMinute, equals(8.0));
        expect(exerciseFromMap.isDefault, isFalse);
      });

      test('deve lidar com Map incompleto', () {
        // Arrange
        final map = {
          'id': 'incomplete-exercise',
          'name': 'Exercício Incompleto',
          'category': 'Geral',
          'caloriesPerMinute': 5.0,
          'createdAt': '2024-01-01T00:00:00.000',
          'updatedAt': '2024-01-01T00:00:00.000',
        };

        // Act
        final exerciseFromMap = Exercise.fromMap(map);

        // Assert
        expect(exerciseFromMap.id, equals('incomplete-exercise'));
        expect(exerciseFromMap.name, equals('Exercício Incompleto'));
        expect(exerciseFromMap.description, isNull);
        expect(exerciseFromMap.category, equals('Geral'));
        expect(exerciseFromMap.caloriesPerMinute, equals(5.0));
        expect(exerciseFromMap.isDefault, isFalse);
      });
    });

    group('CopyWith', () {
      test('deve criar cópia com mudanças específicas', () {
        // Act
        final newExercise = exercise.copyWith(
          name: 'Corrida Intensa',
          caloriesPerMinute: 15.0,
          isDefault: false,
        );

        // Assert
        expect(newExercise.name, equals('Corrida Intensa'));
        expect(newExercise.caloriesPerMinute, equals(15.0));
        expect(newExercise.isDefault, isFalse);
        // Deve manter outros valores
        expect(newExercise.id, equals('test-exercise-id'));
        expect(newExercise.description, equals('Corrida em ritmo moderado'));
        expect(newExercise.category, equals('Cardio'));
      });

      test('deve manter valores originais quando não especificados', () {
        // Act
        final newExercise = exercise.copyWith();

        // Assert
        expect(newExercise.id, equals(exercise.id));
        expect(newExercise.name, equals(exercise.name));
        expect(newExercise.description, equals(exercise.description));
        expect(newExercise.category, equals(exercise.category));
        expect(
            newExercise.caloriesPerMinute, equals(exercise.caloriesPerMinute));
        expect(newExercise.isDefault, equals(exercise.isDefault));
      });
    });

    group('Validações', () {
      test('deve validar exercício completo', () {
        // Act & Assert
        expect(exercise.isValid, isTrue);
      });

      test('deve invalidar exercício com nome vazio', () {
        // Arrange
        final invalidExercise = exercise.copyWith(name: '');

        // Act & Assert
        expect(invalidExercise.isValid, isFalse);
      });

      test('deve invalidar exercício com categoria vazia', () {
        // Arrange
        final invalidExercise = exercise.copyWith(category: '');

        // Act & Assert
        expect(invalidExercise.isValid, isFalse);
      });

      test('deve invalidar exercício com calorias negativas', () {
        // Arrange
        final invalidExercise = exercise.copyWith(caloriesPerMinute: -1.0);

        // Act & Assert
        expect(invalidExercise.isValid, isFalse);
      });

      test('deve validar exercício com calorias zero', () {
        // Arrange
        final validExercise = exercise.copyWith(caloriesPerMinute: 0.0);

        // Act & Assert
        expect(validExercise.isValid, isTrue);
      });
    });

    group('Categorias Padrão', () {
      test('deve identificar exercícios de cardio', () {
        // Arrange
        final cardio = exercise.copyWith(category: 'Cardio');
        final corrida = exercise.copyWith(category: 'cardio');

        // Act & Assert
        expect(cardio.isCardio, isTrue);
        expect(corrida.isCardio, isTrue);
      });

      test('deve identificar exercícios de força', () {
        // Arrange
        final forca = exercise.copyWith(category: 'Força');
        final musculacao = exercise.copyWith(category: 'força');

        // Act & Assert
        expect(forca.isStrength, isTrue);
        expect(musculacao.isStrength, isTrue);
      });

      test('deve identificar exercícios de flexibilidade', () {
        // Arrange
        final flexibilidade = exercise.copyWith(category: 'Flexibilidade');
        final yoga = exercise.copyWith(category: 'flexibilidade');

        // Act & Assert
        expect(flexibilidade.isFlexibility, isTrue);
        expect(yoga.isFlexibility, isTrue);
      });
    });

    group('Equality', () {
      test('deve ser igual para mesmo conteúdo', () {
        // Arrange
        final exercise1 = Exercise(
          id: 'same-id',
          name: 'Mesmo Exercício',
          category: 'Cardio',
          caloriesPerMinute: 10.0,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );

        final exercise2 = Exercise(
          id: 'same-id',
          name: 'Mesmo Exercício',
          category: 'Cardio',
          caloriesPerMinute: 10.0,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );

        // Act & Assert
        expect(exercise1, equals(exercise2));
        expect(exercise1.hashCode, equals(exercise2.hashCode));
      });

      test('deve ser diferente para conteúdo diferente', () {
        // Arrange
        final exercise1 = exercise;
        final exercise2 = exercise.copyWith(name: 'Nome Diferente');

        // Act & Assert
        expect(exercise1, isNot(equals(exercise2)));
        expect(exercise1.hashCode, isNot(equals(exercise2.hashCode)));
      });
    });

    group('Comparação e Ordenação', () {
      test('deve comparar exercícios por nome', () {
        // Arrange
        final exerciseA = exercise.copyWith(name: 'Aeróbica');
        final exerciseB = exercise.copyWith(name: 'Boxe');
        final exerciseC = exercise.copyWith(name: 'Corrida');

        // Act
        final sorted = [exerciseC, exerciseA, exerciseB]..sort();

        // Assert
        expect(sorted[0].name, equals('Aeróbica'));
        expect(sorted[1].name, equals('Boxe'));
        expect(sorted[2].name, equals('Corrida'));
      });

      test('deve comparar exercícios por categoria e depois por nome', () {
        // Arrange
        final cardio1 = exercise.copyWith(name: 'Corrida', category: 'Cardio');
        final cardio2 = exercise.copyWith(name: 'Aeróbica', category: 'Cardio');
        final forca1 = exercise.copyWith(name: 'Supino', category: 'Força');

        // Act
        final sorted = [forca1, cardio1, cardio2]..sort();

        // Assert
        expect(sorted[0].category, equals('Cardio'));
        expect(sorted[0].name, equals('Aeróbica'));
        expect(sorted[1].category, equals('Cardio'));
        expect(sorted[1].name, equals('Corrida'));
        expect(sorted[2].category, equals('Força'));
        expect(sorted[2].name, equals('Supino'));
      });
    });
  });
}
