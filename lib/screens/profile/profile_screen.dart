import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/auth_provider.dart';
import '../../providers/exercises_provider.dart';
import '../../services/storage_service.dart';
import '../../services/social_service.dart';
import '../../utils/firebase_auth_extensions.dart';
import '../../widgets/user_avatar.dart';
import 'edit_profile_screen.dart';
import 'privacy_settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final StorageService _storageService = StorageService();
  final SocialService _socialService = SocialService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isUploadingPhoto = false;
  String? _profileImageUrl;
  String? _displayName;
  bool _isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    setState(() => _isLoadingProfile = true);
    try {
      final authProvider = context.read<AuthProvider>();
      final userId = authProvider.user!.uid; // Firebase Author id é uid
      
      // Load exercises statistics
      final exercisesProvider = context.read<ExercisesProvider>();
      exercisesProvider.loadUserExercises(userId);

      final userProfile = await _socialService.getUserProfile(userId);

      if (userProfile != null && mounted) {
        setState(() {
          _profileImageUrl = userProfile.photoUrl;
          _displayName = userProfile.displayName;
          _isLoadingProfile = false;
        });
      } else {
        setState(() => _isLoadingProfile = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingProfile = false);
    }
  }

  Future<void> _changeProfilePhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );

    if (image == null) return;

    setState(() => _isUploadingPhoto = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final userId = authProvider.user!.uid;

      print('DEBUG: Iniciando upload de foto de perfil para userId: $userId');

      // Upload nova foto
      final imageUrl = await _storageService.uploadProfileImage(image, userId);
      print('DEBUG: Foto carregada com sucesso: $imageUrl');

      // Atualizar no banco de dados
      final currentProfile = await _socialService.getUserProfile(userId);
      
      if (currentProfile != null) {
        print('DEBUG: Perfil encontrado, atualizando...');
        final updatedProfile = currentProfile.copyWith(profileImageUrl: imageUrl);
        await _socialService.updateUserProfile(updatedProfile);
      } else {
        print('DEBUG: Perfil não encontrado, criando novo...');
        // Criar perfil se não existir
        final user = authProvider.user!;
        await _firestore.collection('users').doc(userId).set({
          'display_name': user.displayName ?? user.email?.split('@')[0] ?? 'Usuário',
          'email': user.email,
          'profile_image_url': imageUrl,
          'bio': null,
          'created_at': FieldValue.serverTimestamp(),
        });
      }

      print('DEBUG: Foto de perfil salva com sucesso');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto de perfil atualizada!')),
        );
        // Recarregar foto
        await _loadProfileData();
      }
    } catch (e, stackTrace) {
      print('DEBUG: Erro ao atualizar foto: $e');
      print('DEBUG: Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar foto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isUploadingPhoto = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final exercisesProvider = context.watch<ExercisesProvider>();
    final user = authProvider.user!;

    final displayName = _displayName ?? user.userMetadata?['display_name'] as String? ?? user.email?.split('@')[0] ?? 'Usuário';
    final email = user.email ?? '';
    final initials = displayName.isNotEmpty
        ? displayName.substring(0, 1).toUpperCase()
        : email.substring(0, 1).toUpperCase();

    final totalExercises = exercisesProvider.exercises.length;
    final publicExercises = exercisesProvider.exercises.where((e) => e.isPublic).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Criar SettingsScreen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Configurações em breve!')),
              );
            },
            tooltip: 'Configurações',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 32),

            // Profile photo
            Stack(
              children: [
                _isLoadingProfile
                    ? CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey[300],
                        child: const CircularProgressIndicator(),
                      )
                    : CircleAvatar(
                        radius: 60,
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                        backgroundImage: _profileImageUrl != null ? NetworkImage(_profileImageUrl!) : null,
                        child: _profileImageUrl == null
                            ? Text(
                                initials,
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                ),
                              )
                            : null,
                      ),
                if (_isUploadingPhoto)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    radius: 20,
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt, size: 20),
                      color: Colors.white,
                      onPressed: _isUploadingPhoto ? null : _changeProfilePhoto,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Name and email
            Text(
              displayName,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              email,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 32),

            // Stats
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatCard(
                    context,
                    'Exercícios',
                    totalExercises.toString(),
                    Icons.fitness_center,
                  ),
                  _buildStatCard(
                    context,
                    'Públicos',
                    publicExercises.toString(),
                    Icons.public,
                  ),
                  _buildStatCard(
                    context,
                    'Privados',
                    (totalExercises - publicExercises).toString(),
                    Icons.lock,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Settings section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Configurações',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.edit),
                          title: const Text('Editar Perfil'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const EditProfileScreen(),
                              ),
                            );
                            // Se retornou true, recarregar dados
                            if (result == true) {
                              await _loadProfileData();
                            }
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.notifications),
                          title: const Text('Notificações'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            // Informar que deve usar a aba de notificações
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Use a aba de Notificações na barra inferior'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.privacy_tip),
                          title: const Text('Privacidade'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PrivacySettingsScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            icon,
            size: 32,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }
}
