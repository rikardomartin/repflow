import 'package:firebase_auth/firebase_auth.dart';

/// Extensões para compatibilizar a API do Firebase Auth com o código anterior do Supabase
extension FirebaseUserExtensions on User {
  /// Retorna o UID do usuário (compatível com Supabase user.id)
  String get id => uid;

  /// Retorna metadados do usuário simulando a estrutura do Supabase
  Map<String, dynamic>? get userMetadata => {
        'display_name': displayName ?? email?.split('@').first ?? 'Usuário',
        'email': email,
        'photo_url': photoURL,
      };
}
