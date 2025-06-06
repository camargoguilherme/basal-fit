import '../exceptions/app_exceptions.dart';

/// Padrão Result para encapsular sucesso ou erro
sealed class Result<T> {
  const Result();

  /// Cria um resultado de sucesso
  factory Result.success(T data) = Success<T>;

  /// Cria um resultado de erro
  factory Result.error(AppException exception) = Error<T>;

  /// Verifica se é sucesso
  bool get isSuccess => this is Success<T>;

  /// Verifica se é erro
  bool get isError => this is Error<T>;

  /// Obtém os dados (apenas se for sucesso)
  T? get data => isSuccess ? (this as Success<T>).data : null;

  /// Obtém a exceção (apenas se for erro)
  AppException? get exception => isError ? (this as Error<T>).exception : null;

  /// Executa uma função se for sucesso
  Result<R> map<R>(R Function(T data) mapper) {
    return switch (this) {
      Success<T>(data: final data) => Result.success(mapper(data)),
      Error<T>(exception: final error) => Result.error(error),
    };
  }

  /// Executa uma função se for sucesso (pode retornar Result)
  Result<R> flatMap<R>(Result<R> Function(T data) mapper) {
    return switch (this) {
      Success<T>(data: final data) => mapper(data),
      Error<T>(exception: final error) => Result.error(error),
    };
  }

  /// Executa uma função para cada caso
  R when<R>({
    required R Function(T data) success,
    required R Function(AppException exception) error,
  }) {
    return switch (this) {
      Success<T>(data: final data) => success(data),
      Error<T>(exception: final exception) => error(exception),
    };
  }

  /// Obtém o valor ou lança uma exceção
  T getOrThrow() {
    return switch (this) {
      Success<T>(data: final data) => data,
      Error<T>(exception: final exception) => throw exception,
    };
  }

  /// Obtém o valor ou retorna um valor padrão
  T getOrElse(T defaultValue) {
    return switch (this) {
      Success<T>(data: final data) => data,
      Error<T>() => defaultValue,
    };
  }

  /// Obtém o valor ou executa uma função
  T getOrElseGet(T Function() defaultValueProvider) {
    return switch (this) {
      Success<T>(data: final data) => data,
      Error<T>() => defaultValueProvider(),
    };
  }
}

/// Resultado de sucesso
final class Success<T> extends Result<T> {
  final T data;

  const Success(this.data);

  @override
  String toString() => 'Success($data)';

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is Success<T> && data == other.data);
  }

  @override
  int get hashCode => data.hashCode;
}

/// Resultado de erro
final class Error<T> extends Result<T> {
  final AppException exception;

  const Error(this.exception);

  @override
  String toString() => 'Error(${exception.message})';

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is Error<T> && exception == other.exception);
  }

  @override
  int get hashCode => exception.hashCode;
}

/// Extensions para facilitar o uso
extension ResultExtensions<T> on Result<T> {
  /// Executa uma ação apenas se for sucesso
  void onSuccess(void Function(T data) action) {
    if (isSuccess) {
      action(data!);
    }
  }

  /// Executa uma ação apenas se for erro
  void onError(void Function(AppException exception) action) {
    if (isError) {
      action(exception!);
    }
  }

  /// Combina dois resultados
  Result<R> combine<U, R>(
    Result<U> other,
    R Function(T first, U second) combiner,
  ) {
    return flatMap((first) => other.map((second) => combiner(first, second)));
  }
}

/// Utility functions para trabalhar com Result
class ResultUtils {
  /// Executa uma função que pode lançar exceção e retorna Result
  static Result<T> tryExecute<T>(T Function() function) {
    try {
      return Result.success(function());
    } catch (error) {
      final exception = error is AppException
          ? error
          : ExceptionMapper.mapGenericException(error);
      return Result.error(exception);
    }
  }

  /// Executa uma função assíncrona que pode lançar exceção e retorna Result
  static Future<Result<T>> tryExecuteAsync<T>(
      Future<T> Function() function) async {
    try {
      final result = await function();
      return Result.success(result);
    } catch (error) {
      final exception = error is AppException
          ? error
          : ExceptionMapper.mapGenericException(error);
      return Result.error(exception);
    }
  }

  /// Combina uma lista de resultados em um único resultado
  static Result<List<T>> combine<T>(List<Result<T>> results) {
    final List<T> successResults = [];

    for (final result in results) {
      if (result.isError) {
        return Result.error(result.exception!);
      }
      successResults.add(result.data!);
    }

    return Result.success(successResults);
  }
}
