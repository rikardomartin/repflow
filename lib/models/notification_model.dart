import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType {
  follow,
  comment,
  like,
}

class AppNotification {
  final String id;
  final String userId; // destinatário
  final NotificationType type;
  final String fromUserId;
  final String fromUserName;
  final String? fromUserPhotoUrl;
  final String? exerciseId;
  final String? text; // preview do comentário se aplicável
  final bool isRead;
  final DateTime timestamp;

  AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.fromUserId,
    required this.fromUserName,
    this.fromUserPhotoUrl,
    this.exerciseId,
    this.text,
    this.isRead = false,
    required this.timestamp,
  });

  // Converter para Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'type': type.name,
      'from_user_id': fromUserId,
      'from_user_name': fromUserName,
      'from_user_photo_url': fromUserPhotoUrl,
      'exercise_id': exerciseId,
      'preview_text': text,
      'is_read': isRead,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  // Criar AppNotification a partir de Map do Firestore
  factory AppNotification.fromMap(String id, Map<String, dynamic> map) {
    return AppNotification(
      id: id,
      userId: map['user_id'] ?? '',
      type: NotificationType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => NotificationType.like,
      ),
      fromUserId: map['from_user_id'] ?? '',
      fromUserName: map['from_user_name'] ?? '',
      fromUserPhotoUrl: map['from_user_photo_url'],
      exerciseId: map['exercise_id'],
      text: map['preview_text'],
      isRead: map['is_read'] ?? false,
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }

  // CopyWith
  AppNotification copyWith({
    String? id,
    String? userId,
    NotificationType? type,
    String? fromUserId,
    String? fromUserName,
    String? fromUserPhotoUrl,
    String? exerciseId,
    String? text,
    bool? isRead,
    DateTime? timestamp,
  }) {
    return AppNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      fromUserId: fromUserId ?? this.fromUserId,
      fromUserName: fromUserName ?? this.fromUserName,
      fromUserPhotoUrl: fromUserPhotoUrl ?? this.fromUserPhotoUrl,
      exerciseId: exerciseId ?? this.exerciseId,
      text: text ?? this.text,
      isRead: isRead ?? this.isRead,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

// Typedef para compatibilidade
typedef NotificationModel = AppNotification;
