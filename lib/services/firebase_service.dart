import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import '../models/weight_record.dart';
import '../models/exercise.dart' as exercise_model;
import '../models/tmb_record.dart';
import '../models/exercise_record.dart';
import '../models/user_profile.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId => _auth.currentUser?.uid ?? '';
  User? get currentUser => _auth.currentUser;

  // Weight Records
  Future<void> addWeightRecord(WeightRecord record) async {
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('weight_records')
        .doc(record.id)
        .set(record.toMap());
  }

  Future<void> updateWeightRecord(WeightRecord record) async {
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('weight_records')
        .doc(record.id)
        .update(record.toMap());
  }

  Future<void> deleteWeightRecord(String id) async {
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('weight_records')
        .doc(id)
        .delete();
  }

  Stream<List<WeightRecord>> getWeightRecords() {
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('weight_records')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => WeightRecord.fromMap(doc.data()))
            .toList());
  }

  // Exercise Records
  Future<void> addExerciseRecord(ExerciseRecord record) async {
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('exercise_records')
        .doc(record.id)
        .set(record.toMap());
  }

  Future<void> updateExerciseRecord(ExerciseRecord record) async {
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('exercise_records')
        .doc(record.id)
        .update(record.toMap());
  }

  Future<void> deleteExerciseRecord(String id) async {
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('exercise_records')
        .doc(id)
        .delete();
  }

  Stream<List<ExerciseRecord>> getExerciseRecords() {
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('exercise_records')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ExerciseRecord.fromMap(doc.data()))
            .toList());
  }

  // TMB Records
  Stream<List<TMBRecord>> getTMBRecords() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('tmb_records')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TMBRecord.fromMap({...doc.data(), 'id': doc.id}))
            .toList());
  }

  Future<void> addTMBRecord(TMBRecord record) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('Usuário não autenticado');

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('tmb_records')
        .doc(record.id)
        .set(record.toMap());
  }

  Future<void> updateTMBRecord(TMBRecord record) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('Usuário não autenticado');

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('tmb_records')
        .doc(record.id)
        .update(record.toMap());
  }

  Future<void> deleteTMBRecord(String id) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('Usuário não autenticado');

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('tmb_records')
        .doc(id)
        .delete();
  }

  // Exercises
  Stream<List<exercise_model.Exercise>> getExercises() {
    return _firestore.collection('exercises').snapshots().map((snapshot) =>
        snapshot
            .docs
            .map((doc) =>
                exercise_model.Exercise.fromMap({...doc.data(), 'id': doc.id}))
            .toList());
  }

  Future<void> addExercise(exercise_model.Exercise exercise) async {
    await _firestore
        .collection('exercises')
        .doc(exercise.id)
        .set(exercise.toMap());
  }

  Future<void> updateExercise(exercise_model.Exercise exercise) async {
    await _firestore
        .collection('exercises')
        .doc(exercise.id)
        .update(exercise.toMap());
  }

  Future<void> deleteExercise(String id) async {
    await _firestore.collection('exercises').doc(id).delete();
  }

  // Autenticação
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Perfil do Usuário
  Future<UserProfile?> getUserProfile() async {
    if (_userId.isEmpty) return null;

    final doc = await _firestore.collection('users').doc(_userId).get();
    if (!doc.exists) return null;

    return UserProfile.fromMap({...doc.data()!, 'id': doc.id});
  }

  Stream<UserProfile?> getUserProfileStream() {
    if (_userId.isEmpty) return Stream.value(null);

    return _firestore.collection('users').doc(_userId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserProfile.fromMap({...doc.data()!, 'id': doc.id});
    });
  }

  Future<void> updateUserProfile(UserProfile profile) async {
    if (_userId.isEmpty) throw Exception('Usuário não autenticado');

    await _firestore.collection('users').doc(_userId).set(
        profile.copyWith(updatedAt: DateTime.now()).toMap(),
        SetOptions(merge: true));
  }

  Future<void> createUserProfile(UserProfile profile) async {
    if (_userId.isEmpty) throw Exception('Usuário não autenticado');

    await _firestore.collection('users').doc(_userId).set(profile.toMap());
  }

  Future<String?> uploadProfileImage(File imageFile) async {
    if (_userId.isEmpty) throw Exception('Usuário não autenticado');

    try {
      print('📁 Verificando arquivo: ${imageFile.path}');

      // Verifica se o arquivo existe
      if (!await imageFile.exists()) {
        throw Exception('Arquivo de imagem não encontrado');
      }

      print('📤 Convertendo imagem para base64...');

      // Lê os bytes da imagem
      final Uint8List imageBytes = await imageFile.readAsBytes();

      // Converte para base64
      final String base64Image = base64Encode(imageBytes);

      // Cria o data URL com prefixo para facilitar o uso
      final String imageDataUrl = 'data:image/jpeg;base64,$base64Image';

      print('💾 Salvando imagem no perfil do usuário...');

      // Atualiza o perfil do usuário com a imagem em base64
      await _firestore.collection('users').doc(_userId).update({
        'profileImageUrl': imageDataUrl,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });

      print('✅ Imagem salva com sucesso!');
      return imageDataUrl;
    } catch (e) {
      print('❌ Erro no upload da imagem: $e');
      if (e.toString().contains('permission-denied')) {
        throw Exception('Erro de permissão: Verifique as regras do Firestore');
      } else if (e.toString().contains('network')) {
        throw Exception('Erro de conexão: Verifique sua internet');
      } else {
        throw Exception('Erro ao processar imagem: $e');
      }
    }
  }

  Future<void> deleteProfileImage() async {
    if (_userId.isEmpty) throw Exception('Usuário não autenticado');

    try {
      // Remove a imagem do perfil do usuário
      await _firestore.collection('users').doc(_userId).update({
        'profileImageUrl': null,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
      print('✅ Imagem removida do perfil');
    } catch (e) {
      print('❌ Erro ao remover imagem: $e');
      // Não lança exceção para manter compatibilidade
    }
  }

  Future<void> changePassword(
      String currentPassword, String newPassword) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuário não autenticado');

    // Reautentica o usuário
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );

    try {
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
    } catch (e) {
      throw Exception('Erro ao alterar senha: $e');
    }
  }

  Future<void> updateEmail(String newEmail, String password) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuário não autenticado');

    // Reautentica o usuário
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: password,
    );

    try {
      await user.reauthenticateWithCredential(credential);
      await user.updateEmail(newEmail);

      // Atualiza o perfil no Firestore
      await _firestore.collection('users').doc(_userId).update({
        'email': newEmail,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw Exception('Erro ao alterar email: $e');
    }
  }
}
