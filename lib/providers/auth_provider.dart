import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../utils/firebase_auth_extensions.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    // Listen to auth state changes using Firebase stream
    // authStateChanges no AuthService foi implementado?
    // O AuthService antigo tinha `authStateChanges` que retornava Supabase Stream.
    // O AuthService novo (etapa 184) NÃO EXPOS `authStateChanges` explicitamente, 
    // mas o FirebaseAuth tem `authStateChanges()`.
    // Vou checar se o AuthService tem getters ou expõe o FirebaseAuth.
    // Se não, vou usar _authService.firebaseAuth.authStateChanges() se acessível ou adaptar.
    // Assumindo que AuthService expõe ou vou usar FirebaseAuth diretamente aqui se AuthService não tiver.
    // Melhor: Adicionar o getter no AuthService se não existir, mas não posso ver agora.
    // Vou usar FirebaseAuth.instance diretamente no listener se necessário, ou assumir que AuthService tem.
    // Olhando o diff anterior do AuthService, ele tem métodos de sign in mas não vi getter de stream.
    // Vou usar FirebaseAuth.instance aqui para garantir.
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  // Sign in
  Future<bool> signIn(String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final user = await _authService.signInWithEmailAndPassword(email, password);
      // _user será atualizado pelo listener
      _isLoading = false;
      notifyListeners();
      return user != null;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Register
  Future<bool> register(String email, String password, String displayName) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final user = await _authService.registerWithEmailAndPassword(
        email,
        password,
        displayName,
      );
      // _user será atualizado pelo listener
      _isLoading = false;
      notifyListeners();
      return user != null;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _authService.signOut();
    // _user será atualizado pelo listener para null
    _errorMessage = null;
    notifyListeners();
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
