import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';

import '../../core/di/app_module.dart';
import '../../core/constants/app_constants.dart';

import '../../core/exceptions/app_exceptions.dart';
import '../../use_cases/user_use_cases.dart';
import '../../models/user_profile.dart';
import '../../services/firebase_service.dart';

/// Mixin para facilitar acesso às dependências
mixin DependencyMixin<T extends StatefulWidget> on State<T> {
  UserUseCases get userUseCases => DI.get<UserUseCases>();
  FirebaseService get firebaseService => DI.get<FirebaseService>();
}

/// Exemplo de tela de perfil melhorada usando os novos padrões
class ProfileScreenImproved extends StatefulWidget {
  const ProfileScreenImproved({super.key});

  @override
  State<ProfileScreenImproved> createState() => _ProfileScreenImprovedState();
}

class _ProfileScreenImprovedState extends State<ProfileScreenImproved>
    with DependencyMixin {
  // Controllers
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  // State
  UserProfile? _currentProfile;
  File? _selectedImage;
  String? _selectedGender;
  String? _selectedActivityLevel;
  bool _isLoading = false;
  bool _isUploadingImage = false;

  // Constants
  static const _genders = ['Masculino', 'Feminino'];
  static const _activityLevels = [
    'Sedentário',
    'Levemente Ativo',
    'Moderadamente Ativo',
    'Muito Ativo',
    'Extremamente Ativo'
  ];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  /// Carrega o perfil do usuário usando use cases
  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);

    final result = await userUseCases.getCurrentUserProfile();

    result.when(
      success: (profile) {
        setState(() {
          _currentProfile = profile;
          _nameController.text = profile.name;
          _ageController.text = profile.age?.toString() ?? '';
          _heightController.text = profile.height?.toString() ?? '';
          _weightController.text = profile.weight?.toString() ?? '';
          _selectedGender = profile.gender;
          _selectedActivityLevel = profile.activityLevel;
          _isLoading = false;
        });
      },
      error: (error) {
        setState(() => _isLoading = false);
        _showErrorSnackBar(error.message);
      },
    );
  }

  /// Seleciona imagem usando ImagePicker
  Future<void> _pickImage() async {
    if (_isLoading) return;

    final source = await _showImageSourceDialog();
    if (source == null) return;

    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null) {
        setState(() => _selectedImage = File(pickedFile.path));
      }
    } catch (e) {
      _showErrorSnackBar('Erro ao selecionar imagem: $e');
    }
  }

  /// Mostra dialog para escolher fonte da imagem
  Future<ImageSource?> _showImageSourceDialog() async {
    return await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Selecionar imagem'),
        content: const Text('Escolha a origem da imagem:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, ImageSource.camera),
            child: const Text('Câmera'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, ImageSource.gallery),
            child: const Text('Galeria'),
          ),
        ],
      ),
    );
  }

  /// Salva o perfil usando use cases
  Future<void> _saveProfile() async {
    if (!_validateForm()) return;

    setState(() => _isLoading = true);

    try {
      // Upload da imagem se selecionada
      if (_selectedImage != null) {
        setState(() => _isUploadingImage = true);

        try {
          await firebaseService.uploadProfileImage(_selectedImage!);
          setState(() => _isUploadingImage = false);
        } catch (e) {
          setState(() => _isUploadingImage = false);
          _showErrorSnackBar('Erro ao fazer upload da imagem: $e');
          return;
        }
      }

      // Atualiza perfil
      final result = await userUseCases.updateUserProfile(
        name: _nameController.text.trim(),
        age: int.tryParse(_ageController.text),
        gender: _selectedGender,
        height: double.tryParse(_heightController.text),
        weight: double.tryParse(_weightController.text),
        activityLevel: _selectedActivityLevel,
      );

      result.when(
        success: (_) {
          setState(() {
            _selectedImage = null;
            _isLoading = false;
          });
          _showSuccessSnackBar(AppStrings.profileUpdated);
          _loadProfile(); // Recarrega dados atualizados
        },
        error: (error) {
          setState(() => _isLoading = false);
          _showErrorSnackBar(error.message);
        },
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isUploadingImage = false;
        });
      }
    }
  }

  /// Valida o formulário usando constantes
  bool _validateForm() {
    if (_nameController.text.trim().isEmpty) {
      _showErrorSnackBar(ValidationException.required('Nome').message);
      return false;
    }

    if (_nameController.text.length > AppConstants.maxNameLength) {
      _showErrorSnackBar(
          ValidationException.tooLong('Nome', AppConstants.maxNameLength)
              .message);
      return false;
    }

    final age = int.tryParse(_ageController.text);
    if (age != null &&
        (age < AppConstants.minAge || age > AppConstants.maxAge)) {
      _showErrorSnackBar(ValidationException.outOfRange(
              'Idade', AppConstants.minAge, AppConstants.maxAge)
          .message);
      return false;
    }

    final weight = double.tryParse(_weightController.text);
    if (weight != null &&
        (weight < AppConstants.minWeight || weight > AppConstants.maxWeight)) {
      _showErrorSnackBar(ValidationException.outOfRange(
              'Peso', AppConstants.minWeight, AppConstants.maxWeight)
          .message);
      return false;
    }

    final height = double.tryParse(_heightController.text);
    if (height != null &&
        (height < AppConstants.minHeight || height > AppConstants.maxHeight)) {
      _showErrorSnackBar(ValidationException.outOfRange(
              'Altura', AppConstants.minHeight, AppConstants.maxHeight)
          .message);
      return false;
    }

    return true;
  }

  /// Mostra dialog para alterar senha
  Future<void> _showChangePasswordDialog() async {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Alterar Senha'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Senha Atual',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Nova Senha',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirmar Nova Senha',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              if (newPasswordController.text !=
                  confirmPasswordController.text) {
                _showErrorSnackBar(AppStrings.passwordsDoNotMatch);
                return;
              }

              if (newPasswordController.text.length <
                  AppConstants.minPasswordLength) {
                _showErrorSnackBar(AppStrings.passwordTooShort);
                return;
              }

              try {
                await firebaseService.changePassword(
                  currentPasswordController.text,
                  newPasswordController.text,
                );
                if (context.mounted) {
                  Navigator.pop(context, true);
                }
              } catch (e) {
                _showErrorSnackBar('Erro ao alterar senha: $e');
              }
            },
            child: const Text('Alterar'),
          ),
        ],
      ),
    );

    if (result == true) {
      _showSuccessSnackBar(AppStrings.passwordChanged);
    }
  }

  /// Constrói a imagem de perfil
  Widget _buildProfileImage(String? imageUrl) {
    try {
      if (imageUrl != null && imageUrl.startsWith('data:image')) {
        final base64String = imageUrl.split(',')[1];
        final bytes = base64Decode(base64String);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.person, size: 60),
        );
      } else if (imageUrl != null && imageUrl.startsWith('http')) {
        return Image.network(
          imageUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(child: CircularProgressIndicator());
          },
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.person, size: 60),
        );
      } else {
        return const Icon(Icons.person, size: 60);
      }
    } catch (e) {
      return const Icon(Icons.person, size: 60);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _saveProfile,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                children: [
                  // Foto de perfil
                  Center(
                    child: Stack(
                      children: [
                        GestureDetector(
                          onTap: _isLoading ? null : _pickImage,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(60),
                              child: _selectedImage != null
                                  ? Image.file(
                                      _selectedImage!,
                                      fit: BoxFit.cover,
                                    )
                                  : _buildProfileImage(
                                      _currentProfile?.profileImageUrl),
                            ),
                          ),
                        ),
                        if (_isUploadingImage)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black.withOpacity(0.5),
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isUploadingImage
                        ? 'Fazendo upload...'
                        : 'Toque para alterar foto',
                    style: TextStyle(
                      color: _isUploadingImage ? Colors.blue : null,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Formulário
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nome *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: AppConstants.defaultPadding),

                  TextField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Idade',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: AppConstants.defaultPadding),

                  DropdownButtonFormField<String>(
                    value: _selectedGender,
                    onChanged: (value) =>
                        setState(() => _selectedGender = value),
                    decoration: const InputDecoration(
                      labelText: 'Gênero',
                      border: OutlineInputBorder(),
                    ),
                    items: _genders
                        .map((gender) => DropdownMenuItem(
                              value: gender,
                              child: Text(gender),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: AppConstants.defaultPadding),

                  TextField(
                    controller: _heightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Altura (cm)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: AppConstants.defaultPadding),

                  TextField(
                    controller: _weightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Peso (kg)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: AppConstants.defaultPadding),

                  DropdownButtonFormField<String>(
                    value: _selectedActivityLevel,
                    onChanged: (value) =>
                        setState(() => _selectedActivityLevel = value),
                    decoration: const InputDecoration(
                      labelText: 'Nível de Atividade',
                      border: OutlineInputBorder(),
                    ),
                    items: _activityLevels
                        .map((level) => DropdownMenuItem(
                              value: level,
                              child: Text(level),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 24),

                  // Botões
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveProfile,
                      child: Text(AppStrings.save),
                    ),
                  ),
                  const SizedBox(height: AppConstants.defaultPadding),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _showChangePasswordDialog,
                      child: const Text('Alterar Senha'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
