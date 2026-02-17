import 'package:flutter/material.dart';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import '../models/exercise_model.dart';
import '../services/database_service.dart';
import '../services/storage_service.dart';

class ExercisesProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final StorageService _storageService = StorageService();

  List<Exercise> _exercises = [];
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<List<Exercise>>? _exercisesSubscription;

  List<Exercise> get exercises => _exercises;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Get exercises by training group
  List<Exercise> getExercisesByGroup(String group) {
    return _exercises.where((ex) => ex.trainingGroup == group).toList();
  }

  // Load exercises for a user (Real-time)
  void loadUserExercises(String userId) {
    _isLoading = true;
    notifyListeners();

    _exercisesSubscription?.cancel();
    _exercisesSubscription = _databaseService.getUserExercises(userId).listen(
      (exercises) {
        _exercises = exercises;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = 'Erro ao carregar exercícios: $error';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _exercisesSubscription?.cancel();
    super.dispose();
  }

  // Force reload exercises (útil se o realtime não estiver funcionando)
  Future<void> reloadExercises(String userId) async {
    loadUserExercises(userId);
  }

  // Add exercise
  Future<bool> addExercise({
    required String userId,
    required String name,
    required String trainingGroup,
    required String instructions,
    XFile? image,
    bool isPublic = false,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      print('DEBUG: Criando exercício...');
      final now = DateTime.now();
      String? imageUrl;

      // Upload image first if provided
      if (image != null) {
        print('DEBUG: Fazendo upload da imagem...');
        // Usar timestamp como ID temporário para upload
        final tempId = DateTime.now().millisecondsSinceEpoch.toString();
        imageUrl = await _storageService.uploadExerciseImage(image, tempId);
        print('DEBUG: Imagem carregada: $imageUrl');
      }

      // Create exercise with image URL already set
      final exercise = Exercise(
        id: '',
        userId: userId,
        name: name,
        trainingGroup: trainingGroup,
        instructions: instructions,
        machineImageUrl: imageUrl,
        isPublic: isPublic,
        createdAt: now,
        updatedAt: now,
      );

      final exerciseId = await _databaseService.addExercise(exercise);
      print('DEBUG: Exercício criado com ID: $exerciseId');

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e, stackTrace) {
      print('DEBUG: Erro ao adicionar exercício: $e');
      print('DEBUG: Stack trace: $stackTrace');
      _errorMessage = 'Erro ao adicionar exercício: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update exercise
  Future<bool> updateExercise({
    required Exercise exercise,
    XFile? newImage,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      Exercise updatedExercise = exercise.copyWith(updatedAt: DateTime.now());

      // Upload new image if provided
      if (newImage != null) {
        // Delete old image if exists
        if (exercise.machineImageUrl != null) {
          await _storageService.deleteExerciseImage(exercise.machineImageUrl!);
        }

        final imageUrl = await _storageService.uploadExerciseImage(
          newImage,
          exercise.id,
        );
        updatedExercise = updatedExercise.copyWith(machineImageUrl: imageUrl);
      }

      await _databaseService.updateExercise(updatedExercise);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Erro ao atualizar exercício: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete exercise
  Future<bool> deleteExercise(Exercise exercise) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      print('DEBUG: Iniciando exclusão do exercício ${exercise.id}');

      // Delete from Firestore first
      await _databaseService.deleteExercise(exercise.id);
      print('DEBUG: Exercício deletado do Firestore');

      // Delete image if exists (não bloqueia se falhar)
      if (exercise.machineImageUrl != null) {
        try {
          await _storageService.deleteExerciseImage(exercise.machineImageUrl!);
          print('DEBUG: Imagem deletada do Storage');
        } catch (e) {
          print('DEBUG: Erro ao deletar imagem (não crítico): $e');
          // Continua mesmo se falhar ao deletar imagem
        }
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e, stackTrace) {
      print('DEBUG: Erro ao excluir exercício: $e');
      print('DEBUG: Stack trace: $stackTrace');
      _errorMessage = 'Erro ao excluir exercício: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Toggle exercise public/private
  Future<bool> toggleExerciseVisibility(Exercise exercise) async {
    return updateExercise(
      exercise: exercise.copyWith(isPublic: !exercise.isPublic),
    );
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
