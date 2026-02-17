import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/exercise_model.dart';
import '../models/feeling_log_model.dart';
import 'notifications_service.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationsService _notificationsService = NotificationsService();


  // ========== COMMENTS ==========
  
  Future<void> addComment(Map<String, dynamic> commentData) async {
    await _firestore.collection('comments').add(commentData);
  }

  Future<List<Map<String, dynamic>>> getComments(String exerciseId) async {
    final snapshot = await _firestore
        .collection('comments')
        .where('exercise_id', isEqualTo: exerciseId)
        .orderBy('created_at', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data()})
        .toList();
  }

  // ========== EXERCISES ==========

  // Get user exercises stream
  Stream<List<Exercise>> getUserExercises(String userId) {
    return _firestore
        .collection('exercises')
        .where('user_id', isEqualTo: userId)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Exercise.fromMap(doc.id, doc.data()))
            .toList());
  }

  // Fetch public exercises
  Future<List<Exercise>> fetchPublicExercises() async {
    final snapshot = await _firestore
        .collection('exercises')
        .where('is_public', isEqualTo: true)
        .orderBy('created_at', descending: true)
        .limit(50)
        .get();

    return snapshot.docs
        .map((doc) => Exercise.fromMap(doc.id, doc.data()))
        .toList();
  }
  
  // Public exercises by user
  Future<List<Exercise>> fetchPublicExercisesByUser(String userId) async {
    final snapshot = await _firestore
        .collection('exercises')
        .where('user_id', isEqualTo: userId)
        .where('is_public', isEqualTo: true)
        .orderBy('created_at', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => Exercise.fromMap(doc.id, doc.data()))
        .toList();
  }

  // Get single exercise
  Future<Exercise?> fetchExerciseById(String exerciseId) async {
    final doc = await _firestore.collection('exercises').doc(exerciseId).get();
    if (!doc.exists) return null;
    return Exercise.fromMap(doc.id, doc.data()!);
  }

  // Get single exercise stream (real-time)
  Stream<Exercise?> getExerciseStream(String exerciseId) {
    return _firestore
        .collection('exercises')
        .doc(exerciseId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return Exercise.fromMap(doc.id, doc.data()!);
    });
  }

  // Add exercise
  Future<String> addExercise(Exercise exercise) async {
    final docRef = await _firestore.collection('exercises').add(exercise.toMap()..remove('id'));
    return docRef.id;
  }

  // Update exercise
  Future<void> updateExercise(Exercise exercise) async {
    print('DEBUG: Atualizando exercício ${exercise.id}');
    print('DEBUG: Dados do exercício: ${exercise.toMap()}');
    
    await _firestore
        .collection('exercises')
        .doc(exercise.id)
        .update(exercise.toMap()..remove('id'));
    
    print('DEBUG: Exercício atualizado no Firestore');
  }

  // Delete exercise
  Future<void> deleteExercise(String exerciseId) async {
    await _firestore.collection('exercises').doc(exerciseId).delete();
  }

  // ========== FEELING LOGS ==========
  // Usando subcoleção 'logs' dentro de cada exercício para organização

  Stream<List<FeelingLog>> getFeelingLogs(String exerciseId) {
    return _firestore
        .collection('exercises')
        .doc(exerciseId)
        .collection('logs')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FeelingLog.fromMap(doc.data()..['id'] = doc.id))
            .toList());
  }

  Future<void> addFeelingLog(FeelingLog log) async {
    await _firestore
        .collection('exercises')
        .doc(log.exerciseId)
        .collection('logs')
        .add(log.toMap()..remove('id'));
  }

  Future<void> deleteFeelingLog(String exerciseId, String logId) async {
    await _firestore
        .collection('exercises')
        .doc(exerciseId)
        .collection('logs')
        .doc(logId)
        .delete();
  }
  
  // ========== REACTIONS (LIKES / VALEU / AMEN) ==========
  
  Future<void> addReaction(String exerciseId, String userId, String reactionType) async {
    final reactionRef = _firestore
        .collection('exercises')
        .doc(exerciseId)
        .collection('reactions')
        .doc('${userId}_$reactionType');
        
    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(reactionRef);
      if (!doc.exists) {
        // Criar reação
        transaction.set(reactionRef, {
          'userId': userId,
          'type': reactionType,
          'timestamp': FieldValue.serverTimestamp(),
        });
        
        // Incrementar contador no exercício
        final String countField = reactionType == 'like' ? 'likes_count' : 
                                  reactionType == 'valeu' ? 'valeu_count' : 
                                  'amen_count';
                                  
        transaction.update(_firestore.collection('exercises').doc(exerciseId), {
          countField: FieldValue.increment(1),
        });
      }
    });

    // Notificação movida para SocialProvider para evitar leitura extra do exercício
  }

  Future<void> removeReaction(String exerciseId, String userId, String reactionType) async {
    final reactionRef = _firestore
        .collection('exercises')
        .doc(exerciseId)
        .collection('reactions')
        .doc('${userId}_$reactionType');

    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(reactionRef);
      if (doc.exists) {
        transaction.delete(reactionRef);
        
        // Decrementar contador
        final String countField = reactionType == 'like' ? 'likes_count' : 
                                  reactionType == 'valeu' ? 'valeu_count' : 
                                  'amen_count';
                                  
        transaction.update(_firestore.collection('exercises').doc(exerciseId), {
          countField: FieldValue.increment(-1),
        });
      }
    });
  }

  Future<List<String>> getUserReactions(String exerciseId, String userId) async {
    final snapshot = await _firestore
        .collection('exercises')
        .doc(exerciseId)
        .collection('reactions')
        .where('userId', isEqualTo: userId)
        .get();
        
    return snapshot.docs.map((doc) => doc.data()['type'] as String).toList();
  }
}
