import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseService {
  // Singleton instance
  static final FirebaseService _instance = FirebaseService._internal();

  factory FirebaseService() {
    return _instance;
  }

  FirebaseService._internal();

  // Core instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Getters
  FirebaseAuth get auth => _auth;
  FirebaseFirestore get firestore => _firestore;
  FirebaseStorage get storage => _storage;
  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Collections References
  CollectionReference get usersCollection => _firestore.collection('users');
  CollectionReference get exercisesCollection => _firestore.collection('exercises');
  CollectionReference get groupsCollection => _firestore.collection('groups');
  CollectionReference get commentsCollection => _firestore.collection('comments');
  CollectionReference get notificationsCollection => _firestore.collection('notifications');

  // Helper methods
  String get currentUserId {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuário não autenticado');
    return user.uid;
  }
}
