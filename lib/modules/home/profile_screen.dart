import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import '../../services/firebase_service.dart';
import '../../models/user_profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseService _firebaseService = Modular.get<FirebaseService>();
  final ImagePicker _picker = ImagePicker();

  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  String? _selectedGender;
  String? _selectedActivityLevel;
  File? _selectedImage;
  bool _isLoading = false;
  bool _isUploadingImage = false;
  UserProfile? _currentProfile;

  final List<String> _genders = ['Masculino', 'Feminino'];
  final List<String> _activityLevels = [
    'Sedentário',
    'Pouco ativo',
    'Moderadamente ativo',
    'Muito ativo',
    'Extremamente ativo'
  ];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final profile = await _firebaseService.getUserProfile();
      if (profile != null) {
        setState(() {
          _currentProfile = profile;
          _nameController.text = profile.name;
          _ageController.text = profile.age?.toString() ?? '';
          _heightController.text = profile.height?.toString() ?? '';
          _weightController.text = profile.weight?.toString() ?? '';
          _selectedGender = profile.gender;
          _selectedActivityLevel = profile.activityLevel;
        });
      } else {
        _createInitialProfile();
      }
    } catch (e) {
      _showErrorDialog('Erro ao carregar perfil: $e');
    }
  }

  Future<void> _createInitialProfile() async {
    final user = _firebaseService.currentUser;
    if (user != null) {
      final profile = UserProfile(
        id: user.uid,
        name: user.displayName ?? '',
        email: user.email ?? '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firebaseService.createUserProfile(profile);
      setState(() {
        _currentProfile = profile;
        _nameController.text = profile.name;
      });
    }
  }

  Future<void> _pickImage() async {
    final ImageSource? source = await _showImageSourceDialog();
    if (source == null) return;

    final XFile? image = await _picker.pickImage(
      source: source,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 70,
    );

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<ImageSource?> _showImageSourceDialog() async {
    return await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Selecionar imagem'),
        content: const Text('Escolha a origem da imagem:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
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

  Future<void> _saveProfile() async {
    if (_nameController.text.trim().isEmpty) {
      _showErrorDialog('Nome é obrigatório');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String? imageUrl = _currentProfile?.profileImageUrl;

      // Upload de imagem se selecionada
      if (_selectedImage != null) {
        setState(() {
          _isUploadingImage = true;
        });

        print('Iniciando upload da imagem...');
        imageUrl = await _firebaseService.uploadProfileImage(_selectedImage!);
        print('Upload concluído. URL: $imageUrl');

        setState(() {
          _isUploadingImage = false;
        });
      }

      // Criar/atualizar perfil
      final updatedProfile = (_currentProfile ??
              UserProfile(
                id: _firebaseService.currentUser!.uid,
                name: '',
                email: _firebaseService.currentUser!.email ?? '',
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ))
          .copyWith(
        name: _nameController.text.trim(),
        profileImageUrl: imageUrl,
        age: int.tryParse(_ageController.text),
        gender: _selectedGender,
        height: double.tryParse(_heightController.text),
        weight: double.tryParse(_weightController.text),
        activityLevel: _selectedActivityLevel,
        updatedAt: DateTime.now(),
      );

      print('Salvando perfil no Firestore...');
      await _firebaseService.updateUserProfile(updatedProfile);
      print('Perfil salvo com sucesso!');

      if (mounted) {
        setState(() {
          _currentProfile = updatedProfile;
          _selectedImage = null;
        });

        _showSuccessDialog('Perfil atualizado com sucesso!');
      }
    } catch (e) {
      print('Erro ao salvar perfil: $e');
      if (mounted) {
        _showErrorDialog('Erro ao salvar perfil: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isUploadingImage = false;
        });
      }
    }
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
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
            const SizedBox(height: 16),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Nova Senha',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
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
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (newPasswordController.text !=
                  confirmPasswordController.text) {
                _showErrorDialog('As senhas não coincidem');
                return;
              }

              if (newPasswordController.text.length < 6) {
                _showErrorDialog(
                    'A nova senha deve ter pelo menos 6 caracteres');
                return;
              }

              try {
                await _firebaseService.changePassword(
                  currentPasswordController.text,
                  newPasswordController.text,
                );
                if (context.mounted) {
                  Navigator.pop(context);
                  _showSuccessDialog('Senha alterada com sucesso!');
                }
              } catch (e) {
                if (context.mounted) {
                  _showErrorDialog('Erro ao alterar senha: $e');
                }
              }
            },
            child: const Text('Alterar'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sucesso'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Erro'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage(String imageUrl) {
    try {
      if (imageUrl.startsWith('data:image')) {
        // É uma imagem base64
        final base64String = imageUrl.split(',')[1];
        final bytes = base64Decode(base64String);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.person, size: 60),
        );
      } else if (imageUrl.startsWith('http')) {
        // É uma URL normal (para compatibilidade com dados antigos)
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
        // Formato não reconhecido
        return const Icon(Icons.person, size: 60);
      }
    } catch (e) {
      print('Erro ao carregar imagem: $e');
      return const Icon(Icons.person, size: 60);
    }
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
              padding: const EdgeInsets.all(16),
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
                                  : _currentProfile?.profileImageUrl != null
                                      ? _buildProfileImage(
                                          _currentProfile!.profileImageUrl!)
                                      : const Icon(Icons.person, size: 60),
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
                  const SizedBox(height: 16),

                  TextField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Idade',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

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
                  const SizedBox(height: 16),

                  TextField(
                    controller: _heightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Altura (cm)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: _weightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Peso (kg)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

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

                  // Botões de ação
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveProfile,
                      child: const Text('Salvar Perfil'),
                    ),
                  ),
                  const SizedBox(height: 16),

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

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }
}
