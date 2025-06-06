import 'package:flutter_test/flutter_test.dart';
import 'package:basal_fit_flutter/models/user_profile.dart';

void main() {
  group('UserProfile', () {
    late UserProfile userProfile;

    setUp(() {
      userProfile = UserProfile(
        id: 'test-id',
        name: 'João Silva',
        email: 'joao@teste.com',
        age: 30,
        weight: 75.0,
        height: 175.0,
        gender: 'masculino',
        activityLevel: 'moderado',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );
    });

    group('Cálculo TMB', () {
      test('deve calcular TMB corretamente para homem', () {
        // Act
        final tmb = userProfile.calculateTmb();

        // Assert
        // Fórmula Mifflin-St Jeor para homens: (10 × peso) + (6.25 × altura) - (5 × idade) + 5
        // (10 × 75) + (6.25 × 175) - (5 × 30) + 5 = 750 + 1093.75 - 150 + 5 = 1698.75
        expect(tmb, equals(1698.75));
      });

      test('deve calcular TMB corretamente para mulher', () {
        // Arrange
        final mulher = userProfile.copyWith(gender: 'feminino');

        // Act
        final tmb = mulher.calculateTmb();

        // Assert
        // Fórmula Mifflin-St Jeor para mulheres: (10 × peso) + (6.25 × altura) - (5 × idade) - 161
        // (10 × 75) + (6.25 × 175) - (5 × 30) - 161 = 750 + 1093.75 - 150 - 161 = 1532.75
        expect(tmb, equals(1532.75));
      });

      test('deve retornar 0 quando dados são inválidos', () {
        // Arrange
        final invalidProfile = UserProfile(
          id: 'test-id',
          name: 'João Silva',
          email: 'joao@teste.com',
          age: null,
          weight: null,
          height: null,
          gender: null,
          activityLevel: null,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );

        // Act
        final tmb = invalidProfile.calculateTmb();

        // Assert
        expect(tmb, equals(0.0));
      });
    });

    group('Cálculo GET', () {
      test('deve calcular GET corretamente para atividade moderada', () {
        // Act
        final get = userProfile.calculateGet();

        // Assert
        final expectedTmb = 1698.75;
        final expectedGet = expectedTmb * 1.55; // Fator para atividade moderada
        expect(get, equals(expectedGet));
      });

      test('deve calcular GET corretamente para sedentário', () {
        // Arrange
        final sedentario = userProfile.copyWith(activityLevel: 'sedentario');

        // Act
        final get = sedentario.calculateGet();

        // Assert
        final expectedTmb = 1698.75;
        final expectedGet = expectedTmb * 1.2; // Fator para sedentário
        expect(get, equals(expectedGet));
      });

      test('deve calcular GET corretamente para muito ativo', () {
        // Arrange
        final muitoAtivo = userProfile.copyWith(activityLevel: 'muitoativo');

        // Act
        final get = muitoAtivo.calculateGet();

        // Assert
        final expectedTmb = 1698.75;
        final expectedGet = expectedTmb * 1.725; // Fator para muito ativo
        expect(get, equals(expectedGet));
      });

      test('deve calcular GET corretamente para extremamente ativo', () {
        // Arrange
        final extremamenteAtivo =
            userProfile.copyWith(activityLevel: 'extremamenteativo');

        // Act
        final get = extremamenteAtivo.calculateGet();

        // Assert
        final expectedTmb = 1698.75;
        final expectedGet = expectedTmb * 1.9; // Fator para extremamente ativo
        expect(get, equals(expectedGet));
      });
    });

    group('Serialização', () {
      test('deve converter para Map corretamente', () {
        // Act
        final map = userProfile.toMap();

        // Assert
        expect(map['id'], equals('test-id'));
        expect(map['name'], equals('João Silva'));
        expect(map['email'], equals('joao@teste.com'));
        expect(map['age'], equals(30));
        expect(map['weight'], equals(75.0));
        expect(map['height'], equals(175.0));
        expect(map['gender'], equals('masculino'));
        expect(map['activityLevel'], equals('moderado'));
        expect(map['createdAt'], isA<String>());
        expect(map['updatedAt'], isA<String>());
      });

      test('deve criar UserProfile de Map corretamente', () {
        // Arrange
        final map = {
          'id': 'test-id-2',
          'name': 'Maria Santos',
          'email': 'maria@teste.com',
          'age': 25,
          'weight': 60.0,
          'height': 165.0,
          'gender': 'feminino',
          'activityLevel': 'ativo',
          'createdAt': '2024-01-01T00:00:00.000',
          'updatedAt': '2024-01-01T00:00:00.000',
        };

        // Act
        final profile = UserProfile.fromMap(map);

        // Assert
        expect(profile.id, equals('test-id-2'));
        expect(profile.name, equals('Maria Santos'));
        expect(profile.email, equals('maria@teste.com'));
        expect(profile.age, equals(25));
        expect(profile.weight, equals(60.0));
        expect(profile.height, equals(165.0));
        expect(profile.gender, equals('feminino'));
        expect(profile.activityLevel, equals('ativo'));
      });

      test('deve lidar com Map incompleto', () {
        // Arrange
        final map = {
          'id': 'test-id-3',
          'name': 'Pedro Costa',
          'email': 'pedro@teste.com',
          'createdAt': '2024-01-01T00:00:00.000',
          'updatedAt': '2024-01-01T00:00:00.000',
        };

        // Act
        final profile = UserProfile.fromMap(map);

        // Assert
        expect(profile.id, equals('test-id-3'));
        expect(profile.name, equals('Pedro Costa'));
        expect(profile.email, equals('pedro@teste.com'));
        expect(profile.age, isNull);
        expect(profile.weight, isNull);
        expect(profile.height, isNull);
        expect(profile.gender, isNull);
        expect(profile.activityLevel, isNull);
      });
    });

    group('CopyWith', () {
      test('deve criar cópia com mudanças específicas', () {
        // Act
        final newProfile = userProfile.copyWith(
          name: 'Novo Nome',
          age: 35,
          weight: 80.0,
        );

        // Assert
        expect(newProfile.name, equals('Novo Nome'));
        expect(newProfile.age, equals(35));
        expect(newProfile.weight, equals(80.0));
        // Deve manter outros valores
        expect(newProfile.id, equals('test-id'));
        expect(newProfile.email, equals('joao@teste.com'));
        expect(newProfile.height, equals(175.0));
        expect(newProfile.gender, equals('masculino'));
      });

      test('deve manter valores originais quando não especificados', () {
        // Act
        final newProfile = userProfile.copyWith();

        // Assert
        expect(newProfile.id, equals(userProfile.id));
        expect(newProfile.name, equals(userProfile.name));
        expect(newProfile.email, equals(userProfile.email));
        expect(newProfile.age, equals(userProfile.age));
        expect(newProfile.weight, equals(userProfile.weight));
        expect(newProfile.height, equals(userProfile.height));
        expect(newProfile.gender, equals(userProfile.gender));
        expect(newProfile.activityLevel, equals(userProfile.activityLevel));
      });
    });

    group('Validações', () {
      test('deve identificar perfil completo', () {
        // Act & Assert
        expect(userProfile.isProfileComplete, isTrue);
      });

      test('deve identificar perfil incompleto', () {
        // Arrange
        final incompleteProfile = UserProfile(
          id: 'test-id',
          name: 'João Silva',
          email: 'joao@teste.com',
          age: null, // Campo obrigatório ausente
          weight: null, // Campo obrigatório ausente
          height: 175.0,
          gender: 'masculino',
          activityLevel: 'moderado',
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );

        // Act & Assert
        expect(incompleteProfile.isProfileComplete, isFalse);
      });

      test('deve validar idade mínima e máxima', () {
        // Arrange
        final idadeMinima = userProfile.copyWith(age: 13);
        final idadeMaxima = userProfile.copyWith(age: 120);
        final idadeMuitoBaixa = userProfile.copyWith(age: 12);
        final idadeMuitoAlta = userProfile.copyWith(age: 121);

        // Act & Assert
        expect(idadeMinima.isProfileComplete, isTrue);
        expect(idadeMaxima.isProfileComplete, isTrue);
        expect(idadeMuitoBaixa.isProfileComplete, isFalse);
        expect(idadeMuitoAlta.isProfileComplete, isFalse);
      });

      test('deve validar peso mínimo e máximo', () {
        // Arrange
        final pesoMinimo = userProfile.copyWith(weight: 15.0);
        final pesoMaximo = userProfile.copyWith(weight: 450.0);
        final pesoMuitoBaixo = userProfile.copyWith(weight: 14.9);
        final pesoMuitoAlto = userProfile.copyWith(weight: 450.1);

        // Act & Assert
        expect(pesoMinimo.isProfileComplete, isTrue);
        expect(pesoMaximo.isProfileComplete, isTrue);
        expect(pesoMuitoBaixo.isProfileComplete, isFalse);
        expect(pesoMuitoAlto.isProfileComplete, isFalse);
      });

      test('deve validar altura mínima e máxima', () {
        // Arrange
        final alturaMinima = userProfile.copyWith(height: 45.0);
        final alturaMaxima = userProfile.copyWith(height: 295.0);
        final alturaMuitoBaixa = userProfile.copyWith(height: 44.9);
        final alturaMuitoAlta = userProfile.copyWith(height: 295.1);

        // Act & Assert
        expect(alturaMinima.isProfileComplete, isTrue);
        expect(alturaMaxima.isProfileComplete, isTrue);
        expect(alturaMuitoBaixa.isProfileComplete, isFalse);
        expect(alturaMuitoAlta.isProfileComplete, isFalse);
      });
    });

    group('Equality', () {
      test('deve ser igual para mesmo conteúdo', () {
        // Arrange
        final profile1 = UserProfile(
          id: 'test-id',
          name: 'João Silva',
          email: 'joao@teste.com',
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );

        final profile2 = UserProfile(
          id: 'test-id',
          name: 'João Silva',
          email: 'joao@teste.com',
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );

        // Act & Assert
        expect(profile1, equals(profile2));
        expect(profile1.hashCode, equals(profile2.hashCode));
      });

      test('deve ser diferente para conteúdo diferente', () {
        // Arrange
        final profile1 = userProfile;
        final profile2 = userProfile.copyWith(name: 'Nome Diferente');

        // Act & Assert
        expect(profile1, isNot(equals(profile2)));
        expect(profile1.hashCode, isNot(equals(profile2.hashCode)));
      });
    });
  });
}
