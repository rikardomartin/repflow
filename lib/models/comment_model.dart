import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String exerciseId;
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final String text;
  final DateTime timestamp;

  Comment({
    required this.id,
    required this.exerciseId,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.text,
    required this.timestamp,
  });

  // Converter para Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'exercise_id': exerciseId,
      'user_id': userId,
      'user_display_name': userName,
      'user_profile_image_url': userPhotoUrl,
      'text': text,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  // Criar Comment a partir de Map do Firestore
  factory Comment.fromMap(String id, Map<String, dynamic> map) {
    return Comment(
      id: id,
      exerciseId: map['exercise_id'] ?? '',
      userId: map['user_id'] ?? '',
      userName: map['user_display_name'] ?? '',
      userPhotoUrl: map['user_profile_image_url'],
      text: map['text'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }
}
