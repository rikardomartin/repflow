import 'package:cloud_firestore/cloud_firestore.dart';

class Exercise {
  final String id;
  final String userId;
  final String name;
  final String trainingGroup;
  final String instructions;
  final String? machineImageUrl;
  final bool isPublic;
  final int likesCount;
  final int valeuCount;
  final int amenCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Exercise({
    required this.id,
    required this.userId,
    required this.name,
    required this.trainingGroup,
    required this.instructions,
    this.machineImageUrl,
    this.isPublic = false,
    this.likesCount = 0,
    this.valeuCount = 0,
    this.amenCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'training_group': trainingGroup,
      'instructions': instructions,
      'machine_image_url': machineImageUrl,
      'is_public': isPublic,
      'likes_count': likesCount,
      'valeu_count': valeuCount,
      'amen_count': amenCount,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
    };
  }

  // Create from Firestore Map
  factory Exercise.fromMap(String id, Map<String, dynamic> map) {
    return Exercise(
      id: id,
      userId: map['user_id'] as String,
      name: map['name'] as String,
      trainingGroup: map['training_group'] as String,
      instructions: map['instructions'] as String,
      machineImageUrl: map['machine_image_url'] as String?,
      isPublic: map['is_public'] as bool? ?? false,
      likesCount: map['likes_count'] as int? ?? 0,
      valeuCount: map['valeu_count'] as int? ?? 0,
      amenCount: map['amen_count'] as int? ?? 0,
      createdAt: (map['created_at'] as Timestamp).toDate(),
      updatedAt: (map['updated_at'] as Timestamp).toDate(),
    );
  }

  // Copy with
  Exercise copyWith({
    String? id,
    String? userId,
    String? name,
    String? trainingGroup,
    String? instructions,
    String? machineImageUrl,
    bool? isPublic,
    int? likesCount,
    int? valeuCount,
    int? amenCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Exercise(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      trainingGroup: trainingGroup ?? this.trainingGroup,
      instructions: instructions ?? this.instructions,
      machineImageUrl: machineImageUrl ?? this.machineImageUrl,
      isPublic: isPublic ?? this.isPublic,
      likesCount: likesCount ?? this.likesCount,
      valeuCount: valeuCount ?? this.valeuCount,
      amenCount: amenCount ?? this.amenCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
