/// Base class para exceções da aplicação
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const AppException(this.message, {this.code, this.originalError});

  @override
  String toString() => 'AppException: $message';
}

/// Exceção genérica da aplicação
class GenericAppException extends AppException {
  const GenericAppException(super.message, {super.code, super.originalError});
}

/// Exceções relacionadas à autenticação
class AuthException extends AppException {
  const AuthException(super.message, {super.code, super.originalError});

  factory AuthException.invalidCredentials() {
    return const AuthException('Credenciais inválidas',
        code: 'invalid-credentials');
  }

  factory AuthException.userNotFound() {
    return const AuthException('Usuário não encontrado',
        code: 'user-not-found');
  }

  factory AuthException.emailAlreadyInUse() {
    return const AuthException('Este email já está em uso',
        code: 'email-already-in-use');
  }

  factory AuthException.weakPassword() {
    return const AuthException('Senha muito fraca', code: 'weak-password');
  }

  factory AuthException.userDisabled() {
    return const AuthException('Usuário desabilitado', code: 'user-disabled');
  }

  factory AuthException.tooManyRequests() {
    return const AuthException('Muitas tentativas. Tente novamente mais tarde',
        code: 'too-many-requests');
  }
}

/// Exceções relacionadas a validação
class ValidationException extends AppException {
  const ValidationException(super.message, {super.code});

  factory ValidationException.required(String field) {
    return ValidationException('$field é obrigatório', code: 'required-field');
  }

  factory ValidationException.invalidFormat(String field) {
    return ValidationException('$field tem formato inválido',
        code: 'invalid-format');
  }

  factory ValidationException.outOfRange(String field, num min, num max) {
    return ValidationException('$field deve estar entre $min e $max',
        code: 'out-of-range');
  }

  factory ValidationException.tooShort(String field, int minLength) {
    return ValidationException(
        '$field deve ter pelo menos $minLength caracteres',
        code: 'too-short');
  }

  factory ValidationException.tooLong(String field, int maxLength) {
    return ValidationException(
        '$field deve ter no máximo $maxLength caracteres',
        code: 'too-long');
  }
}

/// Exceções relacionadas à rede
class NetworkException extends AppException {
  const NetworkException(super.message, {super.code, super.originalError});

  factory NetworkException.noConnection() {
    return const NetworkException('Sem conexão com a internet',
        code: 'no-connection');
  }

  factory NetworkException.timeout() {
    return const NetworkException('Tempo de conexão esgotado', code: 'timeout');
  }

  factory NetworkException.serverError() {
    return const NetworkException('Erro no servidor', code: 'server-error');
  }

  factory NetworkException.notFound() {
    return const NetworkException('Recurso não encontrado', code: 'not-found');
  }
}

/// Exceções relacionadas a dados
class DataException extends AppException {
  const DataException(super.message, {super.code, super.originalError});

  factory DataException.notFound(String entity) {
    return DataException('$entity não encontrado(a)', code: 'not-found');
  }

  factory DataException.alreadyExists(String entity) {
    return DataException('$entity já existe', code: 'already-exists');
  }

  factory DataException.invalidData(String details) {
    return DataException('Dados inválidos: $details', code: 'invalid-data');
  }

  factory DataException.corruptedData() {
    return const DataException('Dados corrompidos', code: 'corrupted-data');
  }
}

/// Exceções relacionadas a permissões
class PermissionException extends AppException {
  const PermissionException(super.message, {super.code});

  factory PermissionException.denied(String permission) {
    return PermissionException('Permissão negada: $permission',
        code: 'permission-denied');
  }

  factory PermissionException.cameraAccess() {
    return const PermissionException('Acesso à câmera negado',
        code: 'camera-denied');
  }

  factory PermissionException.storageAccess() {
    return const PermissionException('Acesso ao armazenamento negado',
        code: 'storage-denied');
  }
}

/// Exceções relacionadas a arquivos
class FileException extends AppException {
  const FileException(super.message, {super.code, super.originalError});

  factory FileException.notFound(String filename) {
    return FileException('Arquivo não encontrado: $filename',
        code: 'file-not-found');
  }

  factory FileException.tooLarge(String filename, int maxSize) {
    return FileException('Arquivo muito grande: $filename (máx: ${maxSize}MB)',
        code: 'file-too-large');
  }

  factory FileException.invalidFormat(
      String filename, List<String> allowedFormats) {
    return FileException(
        'Formato inválido: $filename. Permitidos: ${allowedFormats.join(', ')}',
        code: 'invalid-format');
  }

  factory FileException.uploadFailed(String details) {
    return FileException('Falha no upload: $details', code: 'upload-failed');
  }
}

/// Utility para converter exceções Firebase para exceções customizadas
class ExceptionMapper {
  static AppException mapFirebaseException(dynamic error) {
    final errorCode = error?.code?.toString() ?? '';
    final errorMessage = error?.message?.toString() ?? error.toString();

    switch (errorCode) {
      case 'user-not-found':
        return AuthException.userNotFound();
      case 'wrong-password':
        return AuthException.invalidCredentials();
      case 'email-already-in-use':
        return AuthException.emailAlreadyInUse();
      case 'weak-password':
        return AuthException.weakPassword();
      case 'user-disabled':
        return AuthException.userDisabled();
      case 'too-many-requests':
        return AuthException.tooManyRequests();
      case 'network-request-failed':
        return NetworkException.noConnection();
      case 'deadline-exceeded':
        return NetworkException.timeout();
      case 'permission-denied':
        return PermissionException.denied('Firebase');
      case 'not-found':
        return DataException.notFound('Documento');
      case 'already-exists':
        return DataException.alreadyExists('Documento');
      default:
        return GenericAppException(errorMessage,
            code: errorCode, originalError: error);
    }
  }

  static AppException mapGenericException(dynamic error) {
    if (error is AppException) return error;

    final message = error?.toString() ?? 'Erro desconhecido';

    if (message.contains('network') || message.contains('connection')) {
      return NetworkException.noConnection();
    }

    if (message.contains('timeout')) {
      return NetworkException.timeout();
    }

    if (message.contains('permission')) {
      return PermissionException.denied('Sistema');
    }

    return GenericAppException(message, originalError: error);
  }
}
