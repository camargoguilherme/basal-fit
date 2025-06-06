import 'package:flutter_test/flutter_test.dart';
import 'package:basal_fit_flutter/core/utils/result.dart';
import 'package:basal_fit_flutter/core/exceptions/app_exceptions.dart';

void main() {
  group('Result', () {
    group('Success', () {
      test('deve criar Result de sucesso com dados', () {
        // Arrange & Act
        const data = 'dados de teste';
        final result = Result.success(data);

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.isError, isFalse);
        expect(result.data, equals(data));
        expect(result.exception, isNull);
      });

      test('deve criar Result de sucesso com dados nulos', () {
        // Arrange & Act
        final result = Result<String?>.success(null);

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.isError, isFalse);
        expect(result.data, isNull);
        expect(result.exception, isNull);
      });
    });

    group('Error', () {
      test('deve criar Result de erro com exceção', () {
        // Arrange & Act
        final exception = const ValidationException('Erro de validação');
        final result = Result<String>.error(exception);

        // Assert
        expect(result.isSuccess, isFalse);
        expect(result.isError, isTrue);
        expect(result.data, isNull);
        expect(result.exception, equals(exception));
      });

      test('deve criar Result de erro com diferentes tipos de exceção', () {
        // Arrange & Act
        final networkError = Result<int>.error(NetworkException.noConnection());
        final authError = Result<bool>.error(AuthException.userNotFound());
        final dataError =
            Result<String>.error(DataException.notFound('Usuário'));

        // Assert
        expect(networkError.isError, isTrue);
        expect(networkError.exception, isA<NetworkException>());

        expect(authError.isError, isTrue);
        expect(authError.exception, isA<AuthException>());

        expect(dataError.isError, isTrue);
        expect(dataError.exception, isA<DataException>());
      });
    });

    group('ResultUtils', () {
      test('tryExecute deve retornar sucesso para função que não lança exceção',
          () {
        // Arrange & Act
        final result = ResultUtils.tryExecute(() {
          return 'resultado de sucesso';
        });

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.data, equals('resultado de sucesso'));
      });

      test('tryExecute deve capturar exceções e retornar erro', () {
        // Arrange & Act
        final result = ResultUtils.tryExecute<String>(() {
          throw const ValidationException('Erro de teste');
        });

        // Assert
        expect(result.isError, isTrue);
        expect(result.exception, isA<ValidationException>());
        expect(result.exception!.message, equals('Erro de teste'));
      });

      test('tryExecuteAsync deve retornar sucesso para função async', () async {
        // Arrange & Act
        final result = await ResultUtils.tryExecuteAsync(() async {
          await Future.delayed(const Duration(milliseconds: 10));
          return 42;
        });

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.data, equals(42));
      });

      test('tryExecuteAsync deve capturar exceções em funções async', () async {
        // Arrange & Act
        final result = await ResultUtils.tryExecuteAsync<String>(() async {
          await Future.delayed(const Duration(milliseconds: 10));
          throw NetworkException.timeout();
        });

        // Assert
        expect(result.isError, isTrue);
        expect(result.exception, isA<NetworkException>());
      });
    });

    group('Pattern Matching', () {
      test('when deve executar callback de sucesso', () {
        // Arrange
        final result = Result.success('dados');
        String? receivedData;
        AppException? receivedException;

        // Act
        result.when(
          success: (data) => receivedData = data,
          error: (exception) => receivedException = exception,
        );

        // Assert
        expect(receivedData, equals('dados'));
        expect(receivedException, isNull);
      });

      test('when deve executar callback de erro', () {
        // Arrange
        final exception = const ValidationException('Erro');
        final result = Result<String>.error(exception);
        String? receivedData;
        AppException? receivedException;

        // Act
        result.when(
          success: (data) => receivedData = data,
          error: (ex) => receivedException = ex,
        );

        // Assert
        expect(receivedData, isNull);
        expect(receivedException, equals(exception));
      });
    });

    group('Transformations', () {
      test('map deve transformar dados de sucesso', () {
        // Arrange
        final result = Result.success(5);

        // Act
        final mapped = result.map((data) => data * 2);

        // Assert
        expect(mapped.isSuccess, isTrue);
        expect(mapped.data, equals(10));
      });

      test('map deve preservar erro', () {
        // Arrange
        final exception = const ValidationException('Erro');
        final result = Result<int>.error(exception);

        // Act
        final mapped = result.map((data) => data * 2);

        // Assert
        expect(mapped.isError, isTrue);
        expect(mapped.exception, equals(exception));
      });

      test('flatMap deve permitir chain de Results', () {
        // Arrange
        final result = Result.success(5);

        // Act
        final chained = result.flatMap((data) {
          if (data > 0) {
            return Result.success('Positivo: $data');
          } else {
            return Result.error(const ValidationException('Número inválido'));
          }
        });

        // Assert
        expect(chained.isSuccess, isTrue);
        expect(chained.data, equals('Positivo: 5'));
      });

      test('flatMap deve propagar erro', () {
        // Arrange
        final exception = const ValidationException('Erro inicial');
        final result = Result<int>.error(exception);

        // Act
        final chained = result.flatMap((data) {
          return Result.success('Transformado: $data');
        });

        // Assert
        expect(chained.isError, isTrue);
        expect(chained.exception, equals(exception));
      });
    });

    group('Utility Methods', () {
      test('getOrThrow deve retornar dados para sucesso', () {
        // Arrange
        final result = Result.success('dados');

        // Act & Assert
        expect(result.getOrThrow(), equals('dados'));
      });

      test('getOrThrow deve lançar exceção para erro', () {
        // Arrange
        final exception = const ValidationException('Erro');
        final result = Result<String>.error(exception);

        // Act & Assert
        expect(() => result.getOrThrow(), throwsA(exception));
      });

      test('getOrElse deve retornar dados para sucesso', () {
        // Arrange
        final result = Result.success('dados');

        // Act
        final value = result.getOrElse('padrão');

        // Assert
        expect(value, equals('dados'));
      });

      test('getOrElse deve retornar valor padrão para erro', () {
        // Arrange
        final result = Result<String>.error(const ValidationException('Erro'));

        // Act
        final value = result.getOrElse('padrão');

        // Assert
        expect(value, equals('padrão'));
      });
    });

    group('Extensions', () {
      test('onSuccess deve executar ação para sucesso', () {
        // Arrange
        final result = Result.success('dados');
        String? executedValue;

        // Act
        result.onSuccess((data) => executedValue = data);

        // Assert
        expect(executedValue, equals('dados'));
      });

      test('onSuccess não deve executar ação para erro', () {
        // Arrange
        final result = Result<String>.error(const ValidationException('Erro'));
        String? executedValue;

        // Act
        result.onSuccess((data) => executedValue = data);

        // Assert
        expect(executedValue, isNull);
      });

      test('onError deve executar ação para erro', () {
        // Arrange
        final exception = const ValidationException('Erro');
        final result = Result<String>.error(exception);
        AppException? executedException;

        // Act
        result.onError((ex) => executedException = ex);

        // Assert
        expect(executedException, equals(exception));
      });

      test('onError não deve executar ação para sucesso', () {
        // Arrange
        final result = Result.success('dados');
        AppException? executedException;

        // Act
        result.onError((ex) => executedException = ex);

        // Assert
        expect(executedException, isNull);
      });
    });

    group('Equality', () {
      test('Results de sucesso com mesmos dados devem ser iguais', () {
        // Arrange
        final result1 = Result.success('dados');
        final result2 = Result.success('dados');

        // Act & Assert
        expect(result1, equals(result2));
        expect(result1.hashCode, equals(result2.hashCode));
      });

      test('Results de erro com mesma exceção devem ser iguais', () {
        // Arrange
        const exception = ValidationException('Erro', code: 'test');
        final result1 = Result<String>.error(exception);
        final result2 = Result<String>.error(exception);

        // Act & Assert
        expect(result1, equals(result2));
        expect(result1.hashCode, equals(result2.hashCode));
      });

      test('Results diferentes devem ser diferentes', () {
        // Arrange
        final success = Result.success('dados');
        final error = Result<String>.error(const ValidationException('Erro'));

        // Act & Assert
        expect(success, isNot(equals(error)));
        expect(success.hashCode, isNot(equals(error.hashCode)));
      });
    });
  });
}
