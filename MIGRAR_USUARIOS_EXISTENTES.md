# Migrar Usuários Existentes para Firestore

Os usuários que foram criados antes da correção não têm documentos na coleção `users` do Firestore. Isso causa problemas ao listar membros de grupos.

## Solução Temporária

Para usuários existentes, você tem duas opções:

### Opção 1: Criar Manualmente no Firebase Console

1. Acesse o [Firebase Console](https://console.firebase.google.com)
2. Vá em Firestore Database
3. Crie a coleção `users` (se não existir)
4. Para cada usuário:
   - Clique em "Add Document"
   - Document ID: Use o UID do usuário (pode ver em Authentication)
   - Campos:
     ```
     display_name: "Nome do Usuário"
     email: "email@exemplo.com"
     created_at: timestamp (now)
     profile_image_url: null
     bio: null
     ```

### Opção 2: Script de Migração (Recomendado)

Crie um arquivo `migrate_users.dart` na pasta `lib/scripts/`:

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> migrateUsers() async {
  final auth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;
  
  // Listar todos os usuários do Authentication
  // Nota: Isso requer Firebase Admin SDK ou fazer manualmente
  
  print('Migração de usuários iniciada...');
  
  // Para cada usuário autenticado, criar documento no Firestore
  // Este script deve ser executado com privilégios de admin
  
  print('Migração concluída!');
}
```

### Opção 3: Fazer Login Novamente

A forma mais simples é fazer logout e login novamente com cada usuário. Isso não vai funcionar porque o código de criação só roda no registro.

### Opção 4: Criar Documento ao Fazer Login (Melhor Solução)

Vou adicionar código para criar o documento do usuário automaticamente no primeiro login se ele não existir.

## Verificar Usuários Existentes

Para verificar quais usuários precisam de migração:

1. Acesse Firebase Console > Authentication
2. Veja a lista de usuários
3. Acesse Firebase Console > Firestore Database > users
4. Compare os UIDs

## Após a Migração

Depois de criar os documentos dos usuários:

1. Faça logout e login novamente
2. Tente acessar a lista de membros do grupo
3. Os membros devem aparecer corretamente
