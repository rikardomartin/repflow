import 'package:cloud_firestore/cloud_firestore.dart';

class Group {
  final String id;
  final String name;
  final String? description;
  final String type; // 'academia', 'bairro', 'time', 'outro'
  final String? imageUrl;
  final String createdBy;
  final int membersCount;
  final int exercisesCount;
  final bool isPublic;
  final DateTime createdAt;
  final DateTime updatedAt;

  Group({
    required this.id,
    required this.name,
    this.description,
    required this.type,
    this.imageUrl,
    required this.createdBy,
    this.membersCount = 0,
    this.exercisesCount = 0,
    this.isPublic = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Group.fromMap(Map<String, dynamic> map) {
    return Group(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      type: map['type'] as String,
      imageUrl: map['image_url'] as String?,
      createdBy: map['created_by'] as String,
      membersCount: map['members_count'] as int? ?? 0,
      exercisesCount: map['exercises_count'] as int? ?? 0,
      isPublic: map['is_public'] as bool? ?? true,
      createdAt: map['created_at'] != null 
          ? (map['created_at'] as Timestamp).toDate() 
          : DateTime.now(),
      updatedAt: map['updated_at'] != null 
          ? (map['updated_at'] as Timestamp).toDate() 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type,
      'image_url': imageUrl,
      'created_by': createdBy,
      'members_count': membersCount,
      'exercises_count': exercisesCount,
      'is_public': isPublic,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
    };
  }

  Group copyWith({
    String? id,
    String? name,
    String? description,
    String? type,
    String? imageUrl,
    String? createdBy,
    int? membersCount,
    int? exercisesCount,
    bool? isPublic,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Group(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      imageUrl: imageUrl ?? this.imageUrl,
      createdBy: createdBy ?? this.createdBy,
      membersCount: membersCount ?? this.membersCount,
      exercisesCount: exercisesCount ?? this.exercisesCount,
      isPublic: isPublic ?? this.isPublic,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
