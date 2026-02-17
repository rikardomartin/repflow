import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/comment_model.dart';
import '../models/notification_model.dart';
import '../models/exercise_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Comments
  Future<void> addComment(Comment comment) async {
    await _firestore
        .collection('comments')
        .doc(comment.id)
        .set(comment.toMap());
  }

  Stream<List<Comment>> getCommentsStream(String exerciseId) {
    return _firestore
        .collection('comments')
        .where('exercise_id', isEqualTo: exerciseId)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Comment.fromMap(doc.id, doc.data()))
            .toList());
  }

  Future<void> deleteComment(String commentId) async {
    await _firestore.collection('comments').doc(commentId).delete();
  }

  // Notifications
  Future<void> createNotification(NotificationModel notification) async {
    await _firestore
        .collection('notifications')
        .doc(notification.id)
        .set(notification.toMap());
  }

  Stream<List<NotificationModel>> getNotificationsStream(String userId) {
    return _firestore
        .collection('notifications')
        .where('user_id', isEqualTo: userId)
        .orderBy('created_at', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    await _firestore
        .collection('notifications')
        .doc(notificationId)
        .update({'is_read': true});
  }

  Future<void> markAllNotificationsAsRead(String userId) async {
    final batch = _firestore.batch();
    final notifications = await _firestore
        .collection('notifications')
        .where('user_id', isEqualTo: userId)
        .where('is_read', isEqualTo: false)
        .get();

    for (var doc in notifications.docs) {
      batch.update(doc.reference, {'is_read': true});
    }

    await batch.commit();
  }

  Future<int> getUnreadNotificationsCount(String userId) async {
    final snapshot = await _firestore
        .collection('notifications')
        .where('user_id', isEqualTo: userId)
        .where('is_read', isEqualTo: false)
        .count()
        .get();

    return snapshot.count ?? 0;
  }

  // User methods
  Future<Map<String, dynamic>?> getUserById(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (!doc.exists) return null;
    return {'id': doc.id, ...doc.data()!};
  }

  // Exercise methods
  Future<Exercise?> fetchExerciseById(String exerciseId) async {
    final doc = await _firestore.collection('exercises').doc(exerciseId).get();
    if (!doc.exists) return null;
    return Exercise.fromMap(doc.id, doc.data()!);
  }

  Future<List<Exercise>> fetchPublicExercises() async {
    final snapshot = await _firestore
        .collection('exercises')
        .where('is_public', isEqualTo: true)
        .limit(50)
        .get();

    // Ordenar no código para evitar necessidade de índice composto
    final exercises = snapshot.docs
        .map((doc) => Exercise.fromMap(doc.id, doc.data()))
        .toList();
    
    exercises.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    return exercises;
  }

  Future<List<Exercise>> fetchPublicExercisesByUser(String userId) async {
    final snapshot = await _firestore
        .collection('exercises')
        .where('user_id', isEqualTo: userId)
        .where('is_public', isEqualTo: true)
        .get();

    // Ordenar no código para evitar necessidade de índice composto
    final exercises = snapshot.docs
        .map((doc) => Exercise.fromMap(doc.id, doc.data()))
        .toList();
    
    exercises.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    return exercises;
  }

  // Follow methods
  Future<bool> isFollowing(String currentUserId, String targetUserId) async {
    final doc = await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('following')
        .doc(targetUserId)
        .get();

    return doc.exists;
  }

  Future<void> followUser(String currentUserId, String targetUserId) async {
    final batch = _firestore.batch();

    // Add to following
    batch.set(
      _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('following')
          .doc(targetUserId),
      {'created_at': FieldValue.serverTimestamp()},
    );

    // Add to followers
    batch.set(
      _firestore
          .collection('users')
          .doc(targetUserId)
          .collection('followers')
          .doc(currentUserId),
      {'created_at': FieldValue.serverTimestamp()},
    );

    await batch.commit();
  }

  Future<void> unfollowUser(String currentUserId, String targetUserId) async {
    final batch = _firestore.batch();

    // Remove from following
    batch.delete(
      _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('following')
          .doc(targetUserId),
    );

    // Remove from followers
    batch.delete(
      _firestore
          .collection('users')
          .doc(targetUserId)
          .collection('followers')
          .doc(currentUserId),
    );

    await batch.commit();
  }

  // Reactions methods
  Future<Map<String, bool>> getUserReactions(String userId, String exerciseId) async {
    final doc = await _firestore
        .collection('reactions')
        .doc('${userId}_$exerciseId')
        .get();

    if (!doc.exists) {
      return {'liked': false, 'valeu': false, 'amen': false};
    }

    final data = doc.data()!;
    return {
      'liked': data['liked'] ?? false,
      'valeu': data['valeu'] ?? false,
      'amen': data['amen'] ?? false,
    };
  }

  // Feeling logs
  Future<void> addFeelingLog(Map<String, dynamic> feelingLogData) async {
    await _firestore.collection('feeling_logs').add(feelingLogData);
  }

  Stream<List<Map<String, dynamic>>> getFeelingLogsStream(String exerciseId) {
    return _firestore
        .collection('feeling_logs')
        .where('exercise_id', isEqualTo: exerciseId)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .toList());
  }

  // Comments stream
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

}
