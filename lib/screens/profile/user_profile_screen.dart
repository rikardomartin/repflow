import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/exercise_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../widgets/user_avatar.dart';
import '../../utils/firebase_auth_extensions.dart';
import '../exercise/exercise_detail_screen.dart';

class UserProfileScreen extends StatefulWidget {
  final String userId;

  const UserProfileScreen({super.key, required this.userId});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  
  Map<String, dynamic>? _userData;
  List<Exercise> _exercises = [];
  bool _isLoading = true;
  bool _isFollowing = false;
  bool _isFollowLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    
    try {
      final authProvider = context.read<AuthProvider>();
      final currentUserId = authProvider.user?.id;

      // Buscar dados do usuário
      final userData = await _firestoreService.getUserById(widget.userId);
      
      // Buscar exercícios públicos
      final exercises = await _firestoreService.fetchPublicExercisesByUser(widget.userId);
      
      // Verificar se está seguindo
      bool following = false;
      if (currentUserId != null) {
        following = await _firestoreService.isFollowing(currentUserId, widget.userId);
      }

      setState(() {
        _userData = userData;
        _exercises = exercises;
        _isFollowing = following;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar perfil: $e')),
        );
      }
    }
  }

  Future<void> _toggleFollow() async {
    final authProvider = context.read<AuthProvider>();
    final currentUserId = authProvider.user?.id;
    
    if (currentUserId == null) return;

    setState(() => _isFollowLoading = true);

    try {
      if (_isFollowing) {
        await _firestoreService.unfollowUser(currentUserId, widget.userId);
      } else {
        await _firestoreService.followUser(currentUserId, widget.userId);
      }

      setState(() {
        _isFollowing = !_isFollowing;
        // Atualizar contador
        if (_userData != null) {
          final currentCount = _userData!['followers_count'] as int? ?? 0;
          _userData!['followers_count'] = _isFollowing ? currentCount + 1 : currentCount - 1;
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isFollowLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_userData == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Usuário não encontrado')),
      );
    }

    final displayName = _userData!['display_name'] as String? ?? 'Usuário';
    final profileImageUrl = _userData!['profile_image_url'] as String?;
    final followersCount = _userData!['followers_count'] as int? ?? 0;
    final followingCount = _userData!['following_count'] as int? ?? 0;
    final initials = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';

    return Scaffold(
      appBar: AppBar(
        title: Text(displayName),
      ),
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Column(
              children: [
                UserAvatar(
                  initials: initials,
                  imageUrl: profileImageUrl,
                  radius: 50,
                ),
                const SizedBox(height: 16),
                Text(
                  displayName,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildStat(followersCount, 'Seguidores'),
                    const SizedBox(width: 32),
                    _buildStat(followingCount, 'Seguindo'),
                    const SizedBox(width: 32),
                    _buildStat(_exercises.length, 'Exercícios'),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _isFollowLoading ? null : _toggleFollow,
                  icon: Icon(_isFollowing ? Icons.person_remove : Icons.person_add),
                  label: Text(_isFollowing ? 'Deixar de Seguir' : 'Seguir'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    backgroundColor: _isFollowing ? Colors.grey : null,
                  ),
                ),
              ],
            ),
          ),

          // Exercícios
          Expanded(
            child: _exercises.isEmpty
                ? const Center(child: Text('Nenhum exercício público'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _exercises.length,
                    itemBuilder: (context, index) {
                      final exercise = _exercises[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: exercise.machineImageUrl != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    exercise.machineImageUrl!,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.fitness_center),
                                ),
                          title: Text(
                            exercise.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(exercise.trainingGroup),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.favorite, size: 16, color: Colors.red),
                              const SizedBox(width: 4),
                              Text('${exercise.likesCount + exercise.valeuCount + exercise.amenCount}'),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ExerciseDetailScreen(exercise: exercise),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(int value, String label) {
    return Column(
      children: [
        Text(
          '$value',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
