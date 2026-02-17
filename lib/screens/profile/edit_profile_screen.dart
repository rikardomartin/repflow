import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/social_service.dart';
import '../../services/storage_service.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final SocialService _socialService = SocialService(); // Usando SocialService
  final StorageService _storageService = StorageService();
  
  bool _isLoading = false;
  Uint8List? _imageBytes;
  XFile? _selectedImage;
  String? _currentImageUrl;

  @override
  void initState() {
    super.initState();
    _loadCurrentData();
  }

  Future<void> _loadCurrentData() async {
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.user?.uid; // Firebase UID

    if (userId != null) {
      try {
        final userProfile = await _socialService.getUserProfile(userId);

        if (userProfile != null && mounted) {
          setState(() {
            _nameController.text = userProfile.displayName;
            _currentImageUrl = userProfile.photoUrl;
          });
        }
      } catch (e) {
        print('Erro ao carregar dados: $e');
      }
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _selectedImage = image;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final userId = authProvider.user?.uid; // Firebase UID

      if (userId == null) return;

      String? imageUrl = _currentImageUrl;

      // Upload nova foto se selecionada
      if (_selectedImage != null) {
        imageUrl = await _storageService.uploadProfileImage(_selectedImage!, userId);
      }

      // Atualizar perfil via SocialService
      final currentProfile = await _socialService.getUserProfile(userId);
      if (currentProfile != null) {
         final updatedProfile = currentProfile.copyWith(
            displayName: _nameController.text.trim(),
            profileImageUrl: imageUrl,
         );
         await _socialService.updateUserProfile(updatedProfile);
      }


      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil atualizado!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Foto de perfil
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: _imageBytes != null
                        ? MemoryImage(_imageBytes!)
                        : (_currentImageUrl != null
                            ? NetworkImage(_currentImageUrl!)
                            : null) as ImageProvider?,
                    child: _imageBytes == null && _currentImageUrl == null
                        ? const Icon(Icons.person, size: 60)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, color: Colors.white),
                        onPressed: _pickImage,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Nome
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nome',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Digite seu nome';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Botão salvar
            ElevatedButton(
              onPressed: _isLoading ? null : _saveProfile,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Salvar Alterações'),
            ),
          ],
        ),
      ),
    );
  }
}
