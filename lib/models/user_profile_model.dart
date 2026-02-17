import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String displayName;
  final String? bio;
  final String? profileImageUrl;
  final bool isPublic;
  final bool allowComments;
  final int followersCount;
  final int followingCount;
  final int exercisesCount;
  final DateTime createdAt;

  UserProfile({
    required this.uid,
    required this.displayName,
    this.bio,
    this.profileImageUrl,
    this.isPublic = false,
    this.allowComments = true,
    this.followersCount = 0,
    this.followingCount = 0,
    this.exercisesCount = 0,
    required this.createdAt,
  });

  // Converter para Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'display_name': displayName,
      'bio': bio,
      'profile_image_url': profileImageUrl,
      'is_public': isPublic,
      'allow_comments': allowComments,
      'followers_count': followersCount,
      'following_count': followingCount,
      'exercises_count': exercisesCount,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }

  // Criar UserProfile a partir de Map do Firestore
  factory UserProfile.fromMap(String uid, Map<String, dynamic> map) {
    return UserProfile(
      uid: uid,
      displayName: map['display_name'] ?? '',
      bio: map['bio'],
      profileImageUrl: map['profile_image_url'],
      isPublic: map['is_public'] ?? false,
      allowComments: map['allow_comments'] ?? true,
      followersCount: map['followers_count'] ?? 0,
      followingCount: map['following_count'] ?? 0,
      exercisesCount: map['exercises_count'] ?? 0,
      createdAt: (map['created_at'] as Timestamp).toDate(),
    );
  }

  // CopyWith para facilitar edições
  UserProfile copyWith({
    String? uid,
    String? displayName,
    String? bio,
    String? profileImageUrl,
    bool? isPublic,
    bool? allowComments,
    int? followersCount,
    int? followingCount,
    int? exercisesCount,
    DateTime? createdAt,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      isPublic: isPublic ?? this.isPublic,
      allowComments: allowComments ?? this.allowComments,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      exercisesCount: exercisesCount ?? this.exercisesCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Getter para compatibilidade com código antigo
  String? get photoUrl => profileImageUrl;
}
