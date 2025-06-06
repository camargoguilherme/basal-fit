import '../../models/user_profile.dart';
import '../../models/exercise.dart' as exercise_model;
import '../../models/exercise_record.dart';
import '../../models/weight_record.dart';
import '../../models/tmb_record.dart';

/// Interface base para todos os repositories
abstract class BaseRepository<T> {
  Future<List<T>> getAll();
  Future<T?> getById(String id);
  Future<void> create(T entity);
  Future<void> update(T entity);
  Future<void> delete(String id);
  Stream<List<T>> watchAll();
  Stream<T?> watchById(String id);
}

/// Repository para gerenciar perfis de usuário
abstract class IUserRepository {
  Future<UserProfile?> getCurrentUserProfile();
  Future<void> createUserProfile(UserProfile profile);
  Future<void> updateUserProfile(UserProfile profile);
  Future<void> deleteUserProfile();
  Stream<UserProfile?> watchCurrentUserProfile();
  Future<String?> uploadProfileImage(String imagePath);
  Future<void> deleteProfileImage();
}

/// Repository para gerenciar exercícios
abstract class IExerciseRepository
    extends BaseRepository<exercise_model.Exercise> {
  Future<List<exercise_model.Exercise>> getByCategory(String category);
  Stream<List<exercise_model.Exercise>> watchByCategory(String category);
  Future<void> addDefaultExercises();
}

/// Repository para gerenciar registros de exercícios
abstract class IExerciseRecordRepository
    extends BaseRepository<ExerciseRecord> {
  Future<List<ExerciseRecord>> getByDateRange(DateTime start, DateTime end);
  Future<List<ExerciseRecord>> getByExerciseId(String exerciseId);
  Stream<List<ExerciseRecord>> watchByDateRange(DateTime start, DateTime end);
  Future<double> getTotalCaloriesBurned(DateTime start, DateTime end);
}

/// Repository para gerenciar registros de peso
abstract class IWeightRecordRepository extends BaseRepository<WeightRecord> {
  Future<List<WeightRecord>> getByDateRange(DateTime start, DateTime end);
  Future<WeightRecord?> getLatest();
  Stream<List<WeightRecord>> watchByDateRange(DateTime start, DateTime end);
  Stream<WeightRecord?> watchLatest();
}

/// Repository para gerenciar registros de TMB
abstract class ITmbRecordRepository extends BaseRepository<TMBRecord> {
  Future<List<TMBRecord>> getByDateRange(DateTime start, DateTime end);
  Future<TMBRecord?> getLatest();
  Stream<List<TMBRecord>> watchByDateRange(DateTime start, DateTime end);
  Stream<TMBRecord?> watchLatest();
}

/// Repository para gerenciar autenticação
abstract class IAuthRepository {
  Future<bool> signIn(String email, String password);
  Future<bool> signUp(String email, String password, String name);
  Future<bool> signInWithGoogle();
  Future<bool> signInWithFacebook();
  Future<void> signOut();
  Future<void> resetPassword(String email);
  Future<void> changePassword(String currentPassword, String newPassword);
  Future<void> updateEmail(String newEmail, String password);
  Stream<bool> watchAuthState();
  bool get isAuthenticated;
  String? get currentUserId;
  String? get currentUserEmail;
}
