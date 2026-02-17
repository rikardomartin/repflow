import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/exercise_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../utils/firebase_auth_extensions.dart';
import '../exercise/exercise_detail_screen.dart';
import '../profile/user_profile_screen.dart';
import '../../widgets/user_avatar.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  List<Exercise> _publicExercises = [];
  Map<String, Map<String, dynamic>> _usersCache = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPublicExercises();
  }

  Future<void> _loadPublicExercises() async {
    setState(() => _isLoading = true);
    try {
      final exercises = await _firestoreService.fetchPublicExercises();
      
      // Carregar dados dos usuários
      final userIds = exercises.map((e) => e.userId).toSet();
      for (final userId in userIds) {
        if (!_usersCache.containsKey(userId)) {
          final userData = await _firestoreService.getUserById(userId);
          if (userData != null) {
            _usersCache[userId] = userData;
          }
        }
      }
      
      setState(() {
        _publicExercises = exercises;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar exercícios: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final currentUserId = authProvider.user?.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explorar Exercícios'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPublicExercises,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _publicExercises.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadPublicExercises,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _publicExercises.length,
                    itemBuilder: (context, index) {
                      final exercise = _publicExercises[index];
                      final isOwnExercise = exercise.userId == currentUserId;
                      return _buildExerciseCard(context, exercise, isOwnExercise);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.explore_outlined,
            size: 100,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum exercício público ainda',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Seja o primeiro a compartilhar!',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(BuildContext context, Exercise exercise, bool isOwn) {
    final userData = _usersCache[exercise.userId];
    final userName = userData?['display_name'] as String? ?? 'Usuário';
    final userImageUrl = userData?['profile_image_url'] as String?;
    final initials = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User header
          ListTile(
            leading: GestureDetector(
              onTap: isOwn ? null : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => UserProfileScreen(userId: exercise.userId),
                  ),
                );
              },
              child: UserAvatar(
                initials: initials,
                imageUrl: userImageUrl,
                radius: 20,
              ),
            ),
            title: GestureDetector(
              onTap: isOwn ? null : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => UserProfileScreen(userId: exercise.userId),
                  ),
                );
              },
              child: Row(
                children: [
                  Text(
                    userName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (isOwn) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Você',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            subtitle: Text(exercise.trainingGroup),
          ),

          // Exercise image
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ExerciseDetailScreen(exercise: exercise),
                ),
              );
            },
            child: exercise.machineImageUrl != null
                ? Image.network(
                    exercise.machineImageUrl!,
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildImagePlaceholder(250),
                  )
                : _buildImagePlaceholder(250),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Exercise name
                Text(
                  exercise.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),

                // Instructions
                Text(
                  exercise.instructions,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),

                // Actions (likes, comments)
                Row(
                  children: [
                    // Like button
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ExerciseDetailScreen(exercise: exercise),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.favorite_border,
                            size: 24,
                            color: Colors.red,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${exercise.likesCount + exercise.valeuCount + exercise.amenCount}',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    // Comment button
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ExerciseDetailScreen(exercise: exercise),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.comment_outlined,
                            size: 24,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Comentar',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // View details button
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ExerciseDetailScreen(exercise: exercise),
                          ),
                        );
                      },
                      child: const Text('Ver detalhes'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder(double height) {
    return Container(
      width: double.infinity,
      height: height,
      color: Colors.grey[200],
      child: Icon(
        Icons.fitness_center,
        size: 60,
        color: Colors.grey[400],
      ),
    );
  }
}
