import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../core/interfaces/repositories.dart';
import '../core/constants/app_constants.dart';
import '../core/exceptions/app_exceptions.dart';
import '../core/utils/result.dart';
import '../models/user_profile.dart';

class FirebaseUserRepository implements IUserRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  const FirebaseUserRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  })  : _firestore = firestore,
        _auth = auth;

  String get _currentUserId {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw const AuthException('Usuário não autenticado',
          code: 'not-authenticated');
    }
    return userId;
  }

  DocumentReference<Map<String, dynamic>> get _userDoc =>
      _firestore.collection(AppConstants.usersCollection).doc(_currentUserId);

  @override
  Future<UserProfile?> getCurrentUserProfile() async {
    try {
      final doc = await _userDoc.get();

      if (!doc.exists || doc.data() == null) {
        return null;
      }

      return UserProfile.fromMap({
        ...doc.data()!,
        'id': doc.id,
      });
    } catch (error) {
      throw ExceptionMapper.mapFirebaseException(error);
    }
  }

  @override
  Stream<UserProfile?> watchCurrentUserProfile() {
    try {
      return _userDoc.snapshots().map((doc) {
        if (!doc.exists || doc.data() == null) {
          return null;
        }

        return UserProfile.fromMap({
          ...doc.data()!,
          'id': doc.id,
        });
      });
    } catch (error) {
      throw ExceptionMapper.mapFirebaseException(error);
    }
  }

  @override
  Future<void> createUserProfile(UserProfile profile) async {
    try {
      await _userDoc.set(profile.toMap());
    } catch (error) {
      throw ExceptionMapper.mapFirebaseException(error);
    }
  }

  @override
  Future<void> updateUserProfile(UserProfile profile) async {
    try {
      final updatedProfile = profile.copyWith(
        id: _currentUserId,
        updatedAt: DateTime.now(),
      );

      await _userDoc.set(
        updatedProfile.toMap(),
        SetOptions(merge: true),
      );
    } catch (error) {
      throw ExceptionMapper.mapFirebaseException(error);
    }
  }

  @override
  Future<void> deleteUserProfile() async {
    try {
      await _userDoc.delete();
    } catch (error) {
      throw ExceptionMapper.mapFirebaseException(error);
    }
  }

  @override
  Future<String?> uploadProfileImage(String imagePath) async {
    try {
      final imageFile = File(imagePath);

      if (!await imageFile.exists()) {
        throw FileException.notFound(imagePath);
      }

      // Lê os bytes da imagem
      final Uint8List imageBytes = await imageFile.readAsBytes();

      // Validação de tamanho (máx 1MB para base64 no Firestore)
      if (imageBytes.length > 1024 * 1024) {
        throw FileException.tooLarge(imagePath, 1);
      }

      // Converte para base64
      final String base64Image = base64Encode(imageBytes);

      // Cria o data URL
      final String imageDataUrl = 'data:image/jpeg;base64,$base64Image';

      // Atualiza o perfil com a nova imagem
      await _userDoc.update({
        'profileImageUrl': imageDataUrl,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });

      return imageDataUrl;
    } catch (error) {
      if (error is AppException) rethrow;
      throw ExceptionMapper.mapGenericException(error);
    }
  }

  @override
  Future<void> deleteProfileImage() async {
    try {
      await _userDoc.update({
        'profileImageUrl': null,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (error) {
      throw ExceptionMapper.mapFirebaseException(error);
    }
  }

  /// Methods adicionais específicos para usuário

  Future<Result<UserProfile>> getCurrentUserProfileSafe() async {
    return ResultUtils.tryExecuteAsync(() async {
      final profile = await getCurrentUserProfile();
      if (profile == null) {
        throw DataException.notFound('Perfil do usuário');
      }
      return profile;
    });
  }

  Future<Result<void>> updateUserProfileSafe(UserProfile profile) async {
    return ResultUtils.tryExecuteAsync(() => updateUserProfile(profile));
  }

  Future<Result<String>> uploadProfileImageSafe(String imagePath) async {
    return ResultUtils.tryExecuteAsync(() async {
      final imageUrl = await uploadProfileImage(imagePath);
      if (imageUrl == null) {
        throw FileException.uploadFailed('Falha ao processar imagem');
      }
      return imageUrl;
    });
  }

  /// Validações específicas do domínio

  void _validateProfile(UserProfile profile) {
    if (profile.name.trim().isEmpty) {
      throw ValidationException.required('Nome');
    }

    if (profile.name.length > AppConstants.maxNameLength) {
      throw ValidationException.tooLong('Nome', AppConstants.maxNameLength);
    }

    if (profile.age != null) {
      if (profile.age! < AppConstants.minAge ||
          profile.age! > AppConstants.maxAge) {
        throw ValidationException.outOfRange(
            'Idade', AppConstants.minAge, AppConstants.maxAge);
      }
    }

    if (profile.weight != null) {
      if (profile.weight! < AppConstants.minWeight ||
          profile.weight! > AppConstants.maxWeight) {
        throw ValidationException.outOfRange(
            'Peso', AppConstants.minWeight, AppConstants.maxWeight);
      }
    }

    if (profile.height != null) {
      if (profile.height! < AppConstants.minHeight ||
          profile.height! > AppConstants.maxHeight) {
        throw ValidationException.outOfRange(
            'Altura', AppConstants.minHeight, AppConstants.maxHeight);
      }
    }
  }

  Future<Result<void>> updateUserProfileValidated(UserProfile profile) async {
    return ResultUtils.tryExecuteAsync(() async {
      _validateProfile(profile);
      await updateUserProfile(profile);
    });
  }

  Future<Result<void>> createUserProfileValidated(UserProfile profile) async {
    return ResultUtils.tryExecuteAsync(() async {
      _validateProfile(profile);
      await createUserProfile(profile);
    });
  }
}
