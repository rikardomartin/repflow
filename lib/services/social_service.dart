import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile_model.dart';
import '../models/exercise_model.dart';
import '../models/comment_model.dart';
import '../models/notification_model.dart';

class SocialService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== USER PROFILES ====================

  // Buscar perfil de usuário
  Future<UserProfile?> getUserProfile(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (doc.exists) {
      return UserProfile.fromMap(doc.id, doc.data()!);
    }
    return null;
  }

  // Atualizar perfil de usuário
  Future<void> updateUserProfile(UserProfile profile) async {
    await _firestore.collection('users').doc(profile.uid).update(profile.toMap());
  }

  // Buscar usuários por nome
  Stream<List<UserProfile>> searchUsers(String query) {
    if (query.isEmpty) {
      return Stream.value([]);
    }

    return _firestore
        .collection('users')
        .where('displayName', isGreaterThanOrEqualTo: query)
        .where('displayName', isLessThanOrEqualTo: '$query\uf8ff')
        .limit(20)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserProfile.fromMap(doc.id, doc.data()))
            .toList());
  }

  // ==================== FOLLOWING ====================

  // Seguir usuário
  Future<void> followUser(String currentUserId, String targetUserId) async {
    await _firestore.runTransaction((transaction) async {
      // Adicionar na lista de following do usuário atual
      final followingRef = _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('following')
          .doc(targetUserId);

      // Adicionar na lista de followers do usuário alvo
      final followerRef = _firestore
          .collection('users')
          .doc(targetUserId)
          .collection('followers')
          .doc(currentUserId);

      transaction.set(followingRef, {
        'timestamp': FieldValue.serverTimestamp(),
      });

      transaction.set(followerRef, {
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Incrementar contadores
      final currentUserRef = _firestore.collection('users').doc(currentUserId);
      final targetUserRef = _firestore.collection('users').doc(targetUserId);

      transaction.update(currentUserRef, {
        'followingCount': FieldValue.increment(1),
      });

      transaction.update(targetUserRef, {
        'followersCount': FieldValue.increment(1),
      });
    });
  }

  // Deixar de seguir usuário
  Future<void> unfollowUser(String currentUserId, String targetUserId) async {
    await _firestore.runTransaction((transaction) async {
      // Remover da lista de following
      final followingRef = _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('following')
          .doc(targetUserId);

      // Remover da lista de followers
      final followerRef = _firestore
          .collection('users')
          .doc(targetUserId)
          .collection('followers')
          .doc(currentUserId);

      transaction.delete(followingRef);
      transaction.delete(followerRef);

      // Decrementar contadores
      final currentUserRef = _firestore.collection('users').doc(currentUserId);
      final targetUserRef = _firestore.collection('users').doc(targetUserId);

      transaction.update(currentUserRef, {
        'followingCount': FieldValue.increment(-1),
      });

      transaction.update(targetUserRef, {
        'followersCount': FieldValue.increment(-1),
      });
    });
  }

  // Verificar se está seguindo
  Future<bool> isFollowing(String currentUserId, String targetUserId) async {
    final doc = await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('following')
        .doc(targetUserId)
        .get();
    return doc.exists;
  }

  // ==================== FEED ====================

  // Stream de exercícios públicos (feed comunitário)
  Stream<List<Exercise>> getPublicExercises() {
    return _firestore
        .collection('exercises')
        .where('isPublic', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Exercise.fromMap(doc.id, doc.data()))
            .toList());
  }

  // Stream de exercícios de quem o usuário segue
  Stream<List<Exercise>> getFollowingExercises(String userId) async* {
    // Buscar lista de quem o usuário segue
    final followingSnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('following')
        .get();

    final followingIds = followingSnapshot.docs.map((doc) => doc.id).toList();

    if (followingIds.isEmpty) {
      yield [];
      return;
    }

    // Buscar exercícios públicos dos usuários seguidos
    yield* _firestore
        .collection('exercises')
        .where('userId', whereIn: followingIds)
        .where('isPublic', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Exercise.fromMap(doc.id, doc.data()))
            .toList());
  }

  // ==================== COMMENTS ====================

  // Adicionar comentário
  Future<String> addComment(Comment comment) async {
    final docRef = await _firestore.collection('comments').add(comment.toMap());
    return docRef.id;
  }

  // Stream de comentários de um exercício
  Stream<List<Comment>> getComments(String exerciseId) {
    return _firestore
        .collection('comments')
        .where('exerciseId', isEqualTo: exerciseId)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Comment.fromMap(doc.id, doc.data()))
            .toList());
  }

  // Deletar comentário
  Future<void> deleteComment(String commentId) async {
    await _firestore.collection('comments').doc(commentId).delete();
  }

  // ==================== NOTIFICATIONS ====================

  // Criar notificação
  Future<String> createNotification(AppNotification notification) async {
    final docRef = await _firestore
        .collection('notifications')
        .add(notification.toMap());
    return docRef.id;
  }

  // Stream de notificações do usuário
  Stream<List<AppNotification>> getUserNotifications(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AppNotification.fromMap(doc.id, doc.data()))
            .toList());
  }

  // Marcar notificação como lida
  Future<void> markNotificationAsRead(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).update({
      'isRead': true,
    });
  }

  // Contar notificações não lidas
  Future<int> getUnreadNotificationsCount(String userId) async {
    final snapshot = await _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();
    return snapshot.docs.length;
  }
}
