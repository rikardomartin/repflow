import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_service.dart';

class AuthService {
  final FirebaseService _firebase = FirebaseService();

  // Get current user
  User? get currentUser => _firebase.auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _firebase.auth.authStateChanges();

  // Sign in with email and password
  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final userCredential = await _firebase.auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Verificar se o documento do usuário existe no Firestore
      if (userCredential.user != null) {
        final userDoc = await _firebase.firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();
        
        // Se não existir, criar
        if (!userDoc.exists) {
          print('DEBUG: Documento do usuário não existe, criando...');
          await _firebase.firestore
              .collection('users')
              .doc(userCredential.user!.uid)
              .set({
            'display_name': userCredential.user!.displayName ?? email.split('@')[0],
            'email': email,
            'created_at': FieldValue.serverTimestamp(),
            'profile_image_url': userCredential.user!.photoURL,
            'bio': null,
          });
          print('DEBUG: Documento do usuário criado no login');
        }
      }
      
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Erro ao fazer login: $e';
    }
  }

  // Register with email and password
  Future<User?> registerWithEmailAndPassword(
    String email,
    String password,
    String displayName,
  ) async {
    try {
      final userCredential = await _firebase.auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Update display name
      if (userCredential.user != null) {
        await userCredential.user!.updateDisplayName(displayName);
        
        // Criar documento do usuário no Firestore
        await _firebase.firestore.collection('users').doc(userCredential.user!.uid).set({
          'display_name': displayName,
          'email': email,
          'created_at': FieldValue.serverTimestamp(),
          'profile_image_url': null,
          'bio': null,
        });
        
        print('DEBUG: Documento do usuário criado no Firestore');
        
        // Recarregar usuário para garantir que o display name foi atualizado
        await userCredential.user!.reload();
      }
      
      return _firebase.auth.currentUser;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Erro ao criar conta: $e';
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _firebase.auth.signOut();
  }

  // Handle auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-credential':
      case 'user-not-found':
      case 'wrong-password':
        return 'Email ou senha inválidos';
      case 'email-already-in-use':
        return 'Este email já está cadastrado';
      case 'weak-password':
        return 'A senha deve ter pelo menos 6 caracteres';
      case 'invalid-email':
        return 'Email inválido';
      default:
        return e.message ?? 'Erro de autenticação';
    }
  }
}
