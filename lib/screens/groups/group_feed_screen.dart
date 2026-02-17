import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/exercise_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/groups_service.dart';
import '../../services/firestore_service.dart';
import '../exercise/exercise_detail_screen.dart';

class GroupFeedScreen extends StatefulWidget {
  final String groupId;
  final String groupName;

  const GroupFeedScreen({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  State<GroupFeedScreen> createState() => _GroupFeedScreenState();
}

class _GroupFeedScreenState extends State<GroupFeedScreen> {
  final GroupsService _groupsService = GroupsService();
  final FirestoreService _firestoreService = FirestoreService();
  
  List<Map<String, dynamic>> _groupExercises = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGroupExercises();
  }

  Future<void> _loadGroupExercises() async {
    setState(() => _isLoading = true);
    
    try {
      final exercises = await _groupsService.fetchGroupExercises(widget.groupId);
      setState(() {
        _groupExercises = exercises;
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Exercícios - ${ widget.groupName}'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _groupExercises.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.fitness_center, size: 100, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhum exercício compartilhado ainda',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Seja o primeiro a compartilhar!',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadGroupExercises,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _groupExercises.length,
                    itemBuilder: (context, index) {
                      final item = _groupExercises[index];
                      final exerciseData = item['exercises'] as Map<String, dynamic>;
                      final exerciseId = exerciseData['id'] as String;
                      final exercise = Exercise.fromMap(exerciseId, exerciseData);
                      final sharedBy = item['sharedBy'] as String;
                      final sharedAtTimestamp = item['sharedAt'] as Timestamp?;
                      final sharedAt = sharedAtTimestamp?.toDate() ?? DateTime.now();

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
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
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(exercise.trainingGroup),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Compartilhado ${_formatDate(sharedAt)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
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
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) {
      return 'agora';
    } else if (diff.inHours < 1) {
      return 'há ${diff.inMinutes}min';
    } else if (diff.inDays < 1) {
      return 'há ${diff.inHours}h';
    } else if (diff.inDays == 1) {
      return 'ontem';
    } else if (diff.inDays < 7) {
      return 'há ${diff.inDays} dias';
    } else {
      return 'há ${(diff.inDays / 7).floor()} semanas';
    }
  }
}
