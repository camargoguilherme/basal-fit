import '../core/interfaces/repositories.dart';
import '../core/utils/result.dart';
import '../core/exceptions/app_exceptions.dart';
import '../models/user_profile.dart';

/// Use cases relacionados ao gerenciamento de usuário
class UserUseCases {
  final IUserRepository _userRepository;
  final IAuthRepository _authRepository;

  const UserUseCases({
    required IUserRepository userRepository,
    required IAuthRepository authRepository,
  })  : _userRepository = userRepository,
        _authRepository = authRepository;

  /// Obtém o perfil do usuário atual
  Future<Result<UserProfile>> getCurrentUserProfile() async {
    return ResultUtils.tryExecuteAsync(() async {
      final profile = await _userRepository.getCurrentUserProfile();
      if (profile == null) {
        throw DataException.notFound('Perfil do usuário');
      }
      return profile;
    });
  }

  /// Observa mudanças no perfil do usuário
  Stream<UserProfile?> watchUserProfile() {
    return _userRepository.watchCurrentUserProfile();
  }

  /// Cria um novo perfil de usuário
  Future<Result<void>> createUserProfile({
    required String name,
    required String email,
    int? age,
    String? gender,
    double? height,
    double? weight,
    String? activityLevel,
  }) async {
    return ResultUtils.tryExecuteAsync(() async {
      final userId = _authRepository.currentUserId;
      if (userId == null) {
        throw const AuthException('Usuário não autenticado');
      }

      final profile = UserProfile(
        id: userId,
        name: name.trim(),
        email: email.trim(),
        age: age,
        gender: gender,
        height: height,
        weight: weight,
        activityLevel: activityLevel,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _userRepository.createUserProfile(profile);
    });
  }

  /// Atualiza o perfil do usuário
  Future<Result<void>> updateUserProfile({
    String? name,
    int? age,
    String? gender,
    double? height,
    double? weight,
    String? activityLevel,
  }) async {
    return ResultUtils.tryExecuteAsync(() async {
      final currentProfile = await _userRepository.getCurrentUserProfile();
      if (currentProfile == null) {
        throw DataException.notFound('Perfil do usuário');
      }

      final updatedProfile = currentProfile.copyWith(
        name: name?.trim() ?? currentProfile.name,
        age: age ?? currentProfile.age,
        gender: gender ?? currentProfile.gender,
        height: height ?? currentProfile.height,
        weight: weight ?? currentProfile.weight,
        activityLevel: activityLevel ?? currentProfile.activityLevel,
        updatedAt: DateTime.now(),
      );

      await _userRepository.updateUserProfile(updatedProfile);
    });
  }

  /// Atualiza a foto do perfil
  Future<Result<String>> updateProfileImage(String imagePath) async {
    return ResultUtils.tryExecuteAsync(() async {
      final imageUrl = await _userRepository.uploadProfileImage(imagePath);
      if (imageUrl == null) {
        throw FileException.uploadFailed('Falha ao processar imagem');
      }
      return imageUrl;
    });
  }

  /// Remove a foto do perfil
  Future<Result<void>> removeProfileImage() async {
    return ResultUtils.tryExecuteAsync(() async {
      await _userRepository.deleteProfileImage();
    });
  }

  /// Calcula o TMB (Taxa Metabólica Basal) baseado no perfil
  Future<Result<double>> calculateTMB() async {
    return ResultUtils.tryExecuteAsync(() async {
      final profile = await _userRepository.getCurrentUserProfile();
      if (profile == null) {
        throw DataException.notFound('Perfil do usuário');
      }

      if (profile.weight == null ||
          profile.height == null ||
          profile.age == null ||
          profile.gender == null) {
        throw ValidationException.required(
            'Peso, altura, idade e gênero são necessários para calcular TMB');
      }

      return _calculateTMBValue(
        weight: profile.weight!,
        height: profile.height!,
        age: profile.age!,
        gender: profile.gender!,
      );
    });
  }

  /// Calcula o GET (Gasto Energético Total) baseado no perfil e nível de atividade
  Future<Result<double>> calculateGET() async {
    return ResultUtils.tryExecuteAsync(() async {
      final tmbResult = await calculateTMB();
      if (tmbResult.isError) {
        throw tmbResult.exception!;
      }

      final profile = await _userRepository.getCurrentUserProfile();
      if (profile == null) {
        throw DataException.notFound('Perfil do usuário');
      }

      if (profile.activityLevel == null) {
        throw ValidationException.required(
            'Nível de atividade é necessário para calcular GET');
      }

      final activityMultiplier = _getActivityMultiplier(profile.activityLevel!);
      return tmbResult.data! * activityMultiplier;
    });
  }

  /// Verifica se o perfil está completo
  Future<Result<bool>> isProfileComplete() async {
    return ResultUtils.tryExecuteAsync(() async {
      final profile = await _userRepository.getCurrentUserProfile();
      if (profile == null) {
        return false;
      }

      return profile.name.isNotEmpty &&
          profile.age != null &&
          profile.gender != null &&
          profile.height != null &&
          profile.weight != null &&
          profile.activityLevel != null;
    });
  }

  /// Obtém recomendações baseadas no perfil
  Future<Result<UserRecommendations>> getUserRecommendations() async {
    return ResultUtils.tryExecuteAsync(() async {
      final getResult = await calculateGET();
      if (getResult.isError) {
        throw getResult.exception!;
      }

      final profile = await _userRepository.getCurrentUserProfile();
      if (profile == null) {
        throw DataException.notFound('Perfil do usuário');
      }

      final dailyCalories = getResult.data!;

      return UserRecommendations(
        dailyCalories: dailyCalories,
        dailyWaterLiters: _calculateWaterRecommendation(profile.weight ?? 70),
        exerciseMinutesPerWeek:
            _getExerciseRecommendation(profile.activityLevel),
        sleepHours: _getSleepRecommendation(profile.age ?? 30),
      );
    });
  }

  // Métodos privados para cálculos

  double _calculateTMBValue({
    required double weight,
    required double height,
    required int age,
    required String gender,
  }) {
    // Fórmula de Mifflin-St Jeor
    if (gender.toLowerCase() == 'masculino' ||
        gender.toLowerCase() == 'male' ||
        gender.toLowerCase() == 'm') {
      return (10 * weight) + (6.25 * height) - (5 * age) + 5;
    } else {
      return (10 * weight) + (6.25 * height) - (5 * age) - 161;
    }
  }

  double _getActivityMultiplier(String activityLevel) {
    switch (activityLevel.toLowerCase()) {
      case 'sedentário':
      case 'sedentary':
        return 1.2;
      case 'levemente ativo':
      case 'lightly active':
        return 1.375;
      case 'moderadamente ativo':
      case 'moderately active':
        return 1.55;
      case 'muito ativo':
      case 'very active':
        return 1.725;
      case 'extremamente ativo':
      case 'extra active':
        return 1.9;
      default:
        return 1.55; // Padrão: moderadamente ativo
    }
  }

  double _calculateWaterRecommendation(double weight) {
    // 35ml por kg de peso corporal
    return (weight * 35) / 1000; // Converte para litros
  }

  int _getExerciseRecommendation(String? activityLevel) {
    switch (activityLevel?.toLowerCase()) {
      case 'sedentário':
      case 'sedentary':
        return 150; // 150 minutos por semana
      case 'levemente ativo':
      case 'lightly active':
        return 200;
      case 'moderadamente ativo':
      case 'moderately active':
        return 250;
      case 'muito ativo':
      case 'very active':
        return 300;
      case 'extremamente ativo':
      case 'extra active':
        return 350;
      default:
        return 150;
    }
  }

  int _getSleepRecommendation(int age) {
    if (age < 18) return 9;
    if (age < 65) return 8;
    return 7;
  }
}

/// Classe para recomendações personalizadas
class UserRecommendations {
  final double dailyCalories;
  final double dailyWaterLiters;
  final int exerciseMinutesPerWeek;
  final int sleepHours;

  const UserRecommendations({
    required this.dailyCalories,
    required this.dailyWaterLiters,
    required this.exerciseMinutesPerWeek,
    required this.sleepHours,
  });

  Map<String, dynamic> toMap() {
    return {
      'dailyCalories': dailyCalories,
      'dailyWaterLiters': dailyWaterLiters,
      'exerciseMinutesPerWeek': exerciseMinutesPerWeek,
      'sleepHours': sleepHours,
    };
  }
}
