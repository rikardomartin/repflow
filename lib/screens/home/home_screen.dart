import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/exercise_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/exercises_provider.dart';
import '../../widgets/user_avatar.dart';
import '../../utils/firebase_auth_extensions.dart';
import 'add_exercise_screen.dart';
import '../exercise/exercise_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Carregar exercícios quando a tela é criada
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      final exercisesProvider = context.read<ExercisesProvider>();
      if (authProvider.user != null) {
        exercisesProvider.loadUserExercises(authProvider.user!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final exercisesProvider = context.watch<ExercisesProvider>();
    final user = authProvider.user!;

    // Get display name from metadata or email
    final displayName = user.userMetadata?['display_name'] as String? ?? 'Usuário';
    final email = user.email ?? '';

    // Get initials for avatar
    final initials = displayName.isNotEmpty
        ? displayName.substring(0, 1).toUpperCase()
        : email.substring(0, 1).toUpperCase();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Exercícios'),
        actions: [
          // User avatar with logout menu
          PopupMenuButton<void>(
            icon: UserAvatar(initials: initials, radius: 18),
            itemBuilder: (context) => <PopupMenuEntry<void>>[
              PopupMenuItem(
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(displayName),
                  subtitle: Text(email),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                onTap: () async {
                  await authProvider.signOut();
                },
                child: const ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Sair'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: exercisesProvider.exercises.isEmpty
          ? _buildEmptyState(context)
          : _buildExercisesList(context, exercisesProvider.exercises),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddExerciseScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Novo Exercício'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fitness_center_outlined,
            size: 100,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum exercício cadastrado',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Toque no botão + para adicionar',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildExercisesList(BuildContext context, List<Exercise> exercises) {
    // Group exercises by training group
    final groupedExercises = <String, List<Exercise>>{};
    for (var exercise in exercises) {
      if (!groupedExercises.containsKey(exercise.trainingGroup)) {
        groupedExercises[exercise.trainingGroup] = [];
      }
      groupedExercises[exercise.trainingGroup]!.add(exercise);
    }

    // Sort groups alphabetically
    final sortedGroups = groupedExercises.keys.toList()..sort();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedGroups.length,
      itemBuilder: (context, index) {
        final group = sortedGroups[index];
        final groupExercises = groupedExercises[group]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Group header
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                group,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),

            // Exercises in this group
            ...groupExercises.map((exercise) => _buildExerciseCard(
                  context,
                  exercise,
                )),

            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildExerciseCard(BuildContext context, Exercise exercise) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ExerciseDetailScreen(exercise: exercise),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Exercise image or placeholder
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: exercise.machineImageUrl != null
                    ? Image.network(
                        exercise.machineImageUrl!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
                      )
                    : _buildImagePlaceholder(),
              ),
              const SizedBox(width: 12),

              // Exercise info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      exercise.instructions,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (exercise.isPublic) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.public,
                            size: 14,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Público',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.fitness_center,
        size: 40,
        color: Colors.grey[400],
      ),
    );
  }
}
