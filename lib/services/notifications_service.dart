import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';

class NotificationsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create notification
  Future<void> createNotification({
    required String userId,
    required String type,
    required String fromUserId,
    String? fromUserName,
    String? exerciseId,
    String? exerciseName,
  }) async {
    try {
      print('DEBUG: Criando notificação para userId: $userId');
      print('DEBUG: Tipo: $type, De: $fromUserName, Exercício: $exerciseName');
      
      final notification = AppNotification(
        id: '', // ID será gerado pelo Firestore
        userId: userId,
        type: NotificationType.values.firstWhere((e) => e.name == type, orElse: () => NotificationType.like),
        fromUserId: fromUserId,
        fromUserName: fromUserName ?? 'Usuário',
        exerciseId: exerciseId,
        text: exerciseName, // Usando campo text para armazenar nome do exercício
        timestamp: DateTime.now(),
      );

      final docRef = await _firestore.collection('notifications').add(notification.toMap());
      print('DEBUG: Notificação criada com ID: ${docRef.id}');
    } catch (e) {
      print('Erro ao criar notificação: $e');
    }
  }

  // Get user notifications stream
  Stream<List<AppNotification>> getUserNotificationsStream(String userId) {
    return _firestore
        .collection('notifications')
        .where('user_id', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AppNotification.fromMap(doc.id, doc.data()))
            .toList());
  }

  // Get user notifications (One-time fetch)
  Future<List<Map<String, dynamic>>> fetchUserNotifications(String userId) async {
    final snapshot = await _firestore
        .collection('notifications')
        .where('user_id', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(50)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  // Get unread count stream
  Stream<int> getUnreadCountStream(String userId) {
    return _firestore
        .collection('notifications')
        .where('user_id', isEqualTo: userId)
        .where('is_read', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Mark as read
  Future<void> markAsRead(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).update({
      'is_read': true,
    });
  }

  // Mark all as read
  Future<void> markAllAsRead(String userId) async {
    final batch = _firestore.batch();
    final snapshot = await _firestore
        .collection('notifications')
        .where('user_id', isEqualTo: userId)
        .where('is_read', isEqualTo: false)
        .get();

    for (var doc in snapshot.docs) {
      batch.update(doc.reference, {'is_read': true});
    }

    await batch.commit();
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).delete();
  }
}
