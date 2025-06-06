import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:basal_fit_flutter/use_cases/user_use_cases.dart';
import 'package:basal_fit_flutter/models/user_profile.dart';
import 'package:basal_fit_flutter/core/interfaces/repositories.dart';
import 'package:basal_fit_flutter/core/utils/result.dart';
import 'package:basal_fit_flutter/core/exceptions/app_exceptions.dart';

// Gerará os mocks automaticamente com build_runner
@GenerateMocks([IUserRepository, IAuthRepository])
import 'user_use_cases_test.mocks.dart';

void main() {
  group('UserUseCases', () {
    late UserUseCases useCase;
    late MockIUserRepository mockUserRepository;
    late MockIAuthRepository mockAuthRepository;

    setUp(() {
      mockUserRepository = MockIUserRepository();
      mockAuthRepository = MockIAuthRepository();
      useCase = UserUseCases(
        userRepository: mockUserRepository,
        authRepository: mockAuthRepository,
      );
    });

    group('Cálculo de TMB', () {
      test('deve calcular TMB com sucesso para perfil completo masculino',
          () async {
        // Arrange
        final userProfile = UserProfile(
          id: 'user-id',
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

        when(mockUserRepository.getCurrentUserProfile())
            .thenAnswer((_) async => userProfile);

        // Act
        final result = await useCase.calculateTMB();

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.data,
            equals(1698.75)); // TMB esperado para os dados de teste

        verify(mockUserRepository.getCurrentUserProfile()).called(1);
      });

      test('deve calcular TMB para mulher corretamente', () async {
        // Arrange
        final userProfile = UserProfile(
          id: 'user-id',
          name: 'Maria Santos',
          email: 'maria@teste.com',
          age: 25,
          weight: 60.0,
          height: 165.0,
          gender: 'feminino',
          activityLevel: 'ativo',
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );

        when(mockUserRepository.getCurrentUserProfile())
            .thenAnswer((_) async => userProfile);

        // Act
        final result = await useCase.calculateTMB();

        // Assert
        expect(result.isSuccess, isTrue);
        // TMB = (10 × 60) + (6.25 × 165) - (5 × 25) - 161 = 600 + 1031.25 - 125 - 161 = 1345.25
        expect(result.data, equals(1345.25));
      });

      test('deve retornar erro quando perfil não está completo', () async {
        // Arrange
        final incompleteProfile = UserProfile(
          id: 'user-id',
          name: 'João Silva',
          email: 'joao@teste.com',
          age: null, // Campo obrigatório ausente
          weight: 75.0,
          height: 175.0,
          gender: 'masculino',
          activityLevel: 'moderado',
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );

        when(mockUserRepository.getCurrentUserProfile())
            .thenAnswer((_) async => incompleteProfile);

        // Act
        final result = await useCase.calculateTMB();

        // Assert
        expect(result.isError, isTrue);
        expect(result.exception, isA<ValidationException>());
      });

      test('deve retornar erro quando usuário não encontrado', () async {
        // Arrange
        when(mockUserRepository.getCurrentUserProfile())
            .thenAnswer((_) async => null);

        // Act
        final result = await useCase.calculateTMB();

        // Assert
        expect(result.isError, isTrue);
        expect(result.exception, isA<DataException>());
      });
    });

    group('Cálculo de GET', () {
      test('deve calcular GET com sucesso para atividade moderada', () async {
        // Arrange
        final userProfile = UserProfile(
          id: 'user-id',
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

        when(mockUserRepository.getCurrentUserProfile())
            .thenAnswer((_) async => userProfile);

        // Act
        final result = await useCase.calculateGET();

        // Assert
        expect(result.isSuccess, isTrue);
        final expectedTmb = 1698.75;
        final expectedGet = expectedTmb * 1.55; // Fator para moderado
        expect(result.data, equals(expectedGet));
      });

      test('deve calcular GET para sedentário', () async {
        // Arrange
        final userProfile = UserProfile(
          id: 'user-id',
          name: 'João Silva',
          email: 'joao@teste.com',
          age: 30,
          weight: 75.0,
          height: 175.0,
          gender: 'masculino',
          activityLevel: 'sedentário',
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );

        when(mockUserRepository.getCurrentUserProfile())
            .thenAnswer((_) async => userProfile);

        // Act
        final result = await useCase.calculateGET();

        // Assert
        expect(result.isSuccess, isTrue);
        final expectedTmb = 1698.75;
        final expectedGet = expectedTmb * 1.2; // Fator para sedentário
        expect(result.data, equals(expectedGet));
      });

      test('deve retornar erro quando nível de atividade é nulo', () async {
        // Arrange
        final userProfile = UserProfile(
          id: 'user-id',
          name: 'João Silva',
          email: 'joao@teste.com',
          age: 30,
          weight: 75.0,
          height: 175.0,
          gender: 'masculino',
          activityLevel: null, // Nível de atividade ausente
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );

        when(mockUserRepository.getCurrentUserProfile())
            .thenAnswer((_) async => userProfile);

        // Act
        final result = await useCase.calculateGET();

        // Assert
        expect(result.isError, isTrue);
        expect(result.exception, isA<ValidationException>());
      });
    });

    group('Verificação de Perfil Completo', () {
      test('deve identificar perfil completo', () async {
        // Arrange
        final completeProfile = UserProfile(
          id: 'user-id',
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

        when(mockUserRepository.getCurrentUserProfile())
            .thenAnswer((_) async => completeProfile);

        // Act
        final result = await useCase.isProfileComplete();

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.data, isTrue);
      });

      test('deve identificar perfil incompleto', () async {
        // Arrange
        final incompleteProfile = UserProfile(
          id: 'user-id',
          name: 'João Silva',
          email: 'joao@teste.com',
          age: null, // Campo ausente
          weight: 75.0,
          height: 175.0,
          gender: 'masculino',
          activityLevel: 'moderado',
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );

        when(mockUserRepository.getCurrentUserProfile())
            .thenAnswer((_) async => incompleteProfile);

        // Act
        final result = await useCase.isProfileComplete();

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.data, isFalse);
      });

      test('deve retornar false quando usuário não encontrado', () async {
        // Arrange
        when(mockUserRepository.getCurrentUserProfile())
            .thenAnswer((_) async => null);

        // Act
        final result = await useCase.isProfileComplete();

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.data, isFalse);
      });
    });

    group('Gerenciamento de Perfil', () {
      test('deve obter perfil atual com sucesso', () async {
        // Arrange
        final userProfile = UserProfile(
          id: 'user-id',
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

        when(mockUserRepository.getCurrentUserProfile())
            .thenAnswer((_) async => userProfile);

        // Act
        final result = await useCase.getCurrentUserProfile();

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.data!.id, equals('user-id'));
        expect(result.data!.name, equals('João Silva'));
      });

      test('deve criar perfil com sucesso', () async {
        // Arrange
        when(mockAuthRepository.currentUserId).thenReturn('user-id');
        when(mockUserRepository.createUserProfile(any))
            .thenAnswer((_) async {});

        // Act
        final result = await useCase.createUserProfile(
          name: 'João Silva',
          email: 'joao@teste.com',
          age: 30,
          gender: 'masculino',
          height: 175.0,
          weight: 75.0,
          activityLevel: 'moderado',
        );

        // Assert
        expect(result.isSuccess, isTrue);
        verify(mockUserRepository.createUserProfile(any)).called(1);
      });

      test('deve atualizar perfil com sucesso', () async {
        // Arrange
        final currentProfile = UserProfile(
          id: 'user-id',
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

        when(mockUserRepository.getCurrentUserProfile())
            .thenAnswer((_) async => currentProfile);
        when(mockUserRepository.updateUserProfile(any))
            .thenAnswer((_) async {});

        // Act
        final result = await useCase.updateUserProfile(
          name: 'João Santos',
          age: 31,
        );

        // Assert
        expect(result.isSuccess, isTrue);
        verify(mockUserRepository.updateUserProfile(any)).called(1);
      });
    });

    group('Casos de Erro', () {
      test('deve lidar com erro de rede', () async {
        // Arrange
        when(mockUserRepository.getCurrentUserProfile())
            .thenThrow(NetworkException.noConnection());

        // Act
        final result = await useCase.getCurrentUserProfile();

        // Assert
        expect(result.isError, isTrue);
        expect(result.exception, isA<NetworkException>());
      });

      test('deve lidar com dados corrompidos', () async {
        // Arrange
        when(mockUserRepository.getCurrentUserProfile())
            .thenThrow(DataException.corruptedData());

        // Act
        final result = await useCase.calculateTMB();

        // Assert
        expect(result.isError, isTrue);
        expect(result.exception, isA<DataException>());
      });
    });
  });
}
