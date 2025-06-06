class AppConstants {
  // App Info
  static const String appName = 'Basal Fit';
  static const String appVersion = '1.0.0';

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String exercisesCollection = 'exercises';
  static const String weightRecordsCollection = 'weight_records';
  static const String exerciseRecordsCollection = 'exercise_records';
  static const String tmbRecordsCollection = 'tmb_records';

  // Storage Paths
  static const String profileImagesPath = 'profile_images';

  // Validation
  static const int minPasswordLength = 8;
  static const int maxNameLength = 150;
  static const double minWeight = 15.0;
  static const double maxWeight = 4500;
  static const double minHeight = 45.0;
  static const double maxHeight = 295.0;
  static const int minAge = 13;
  static const int maxAge = 120;

  // Default Values
  static const double defaultCaloriesPerMinute = 5.0;
  static const String defaultCategory = 'Cardio';

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 12.0;
  static const double cardElevation = 4.0;

  // Timeouts
  static const int networkTimeoutSeconds = 30;
  static const int cacheTimeoutMinutes = 5;
}

class AppStrings {
  // Common
  static const String cancel = 'Cancelar';
  static const String save = 'Salvar';
  static const String delete = 'Excluir';
  static const String edit = 'Editar';
  static const String add = 'Adicionar';
  static const String ok = 'OK';
  static const String error = 'Erro';
  static const String success = 'Sucesso';
  static const String loading = 'Carregando...';

  // Validation Messages
  static const String fieldRequired = 'Este campo é obrigatório';
  static const String invalidEmail = 'Email inválido';
  static const String passwordTooShort =
      'Senha deve ter pelo menos 6 caracteres';
  static const String passwordsDoNotMatch = 'As senhas não coincidem';

  // Error Messages
  static const String networkError = 'Erro de conexão. Verifique sua internet';
  static const String authError = 'Erro de autenticação';
  static const String permissionError = 'Erro de permissão';
  static const String unknownError = 'Erro desconhecido';

  // Success Messages
  static const String profileUpdated = 'Perfil atualizado com sucesso!';
  static const String passwordChanged = 'Senha alterada com sucesso!';
  static const String exerciseAdded = 'Exercício adicionado com sucesso!';
  static const String dataDeleted = 'Dados excluídos com sucesso!';
}

enum ExerciseCategory {
  cardio('Cardio'),
  strength('Força'),
  flexibility('Flexibilidade'),
  sports('Esportes');

  const ExerciseCategory(this.displayName);
  final String displayName;
}

enum ActivityLevel {
  sedentary('Sedentário'),
  lightlyActive('Levemente Ativo'),
  moderatelyActive('Moderadamente Ativo'),
  veryActive('Muito Ativo'),
  extraActive('Extremamente Ativo');

  const ActivityLevel(this.displayName);
  final String displayName;

  double get multiplier {
    switch (this) {
      case ActivityLevel.sedentary:
        return 1.2;
      case ActivityLevel.lightlyActive:
        return 1.375;
      case ActivityLevel.moderatelyActive:
        return 1.55;
      case ActivityLevel.veryActive:
        return 1.725;
      case ActivityLevel.extraActive:
        return 1.9;
    }
  }
}
