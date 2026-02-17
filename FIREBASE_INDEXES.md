# Índices do Firebase Firestore

Este documento contém instruções para criar índices compostos no Firestore para melhorar a performance das queries.

## Por que criar índices?

Atualmente, as queries estão ordenando os resultados no código (client-side) para evitar a necessidade de índices compostos. Isso funciona bem para pequenas quantidades de dados, mas pode ser lento com muitos documentos.

Criar índices permite que o Firestore faça a ordenação no servidor, o que é muito mais eficiente.

## Índices Recomendados

### 1. Exercícios Públicos Ordenados por Data

**Coleção:** `exercises`
**Campos:**
- `is_public` (Ascending)
- `created_at` (Descending)

**Como criar:**
1. Acesse o [Firebase Console](https://console.firebase.google.com)
2. Selecione seu projeto `repflowshow`
3. Vá em Firestore Database > Indexes
4. Clique em "Create Index"
5. Configure:
   - Collection ID: `exercises`
   - Fields to index:
     - Field: `is_public`, Order: Ascending
     - Field: `created_at`, Order: Descending
6. Clique em "Create"

### 2. Exercícios Públicos por Usuário Ordenados por Data

**Coleção:** `exercises`
**Campos:**
- `user_id` (Ascending)
- `is_public` (Ascending)
- `created_at` (Descending)

**Como criar:**
1. Acesse o [Firebase Console](https://console.firebase.google.com)
2. Selecione seu projeto `repflowshow`
3. Vá em Firestore Database > Indexes
4. Clique em "Create Index"
5. Configure:
   - Collection ID: `exercises`
   - Fields to index:
     - Field: `user_id`, Order: Ascending
     - Field: `is_public`, Order: Ascending
     - Field: `created_at`, Order: Descending
6. Clique em "Create"

## Após Criar os Índices

Depois de criar os índices (leva alguns minutos), você pode atualizar o código para usar ordenação no servidor:

### Em `lib/services/firestore_service.dart`:

```dart
Future<List<Exercise>> fetchPublicExercises() async {
  final snapshot = await _firestore
      .collection('exercises')
      .where('is_public', isEqualTo: true)
      .orderBy('created_at', descending: true)  // Adicionar de volta
      .limit(50)
      .get();

  return snapshot.docs
      .map((doc) => Exercise.fromMap(doc.id, doc.data()))
      .toList();
}

Future<List<Exercise>> fetchPublicExercisesByUser(String userId) async {
  final snapshot = await _firestore
      .collection('exercises')
      .where('user_id', isEqualTo: userId)
      .where('is_public', isEqualTo: true)
      .orderBy('created_at', descending: true)  // Adicionar de volta
      .get();

  return snapshot.docs
      .map((doc) => Exercise.fromMap(doc.id, doc.data()))
      .toList();
}
```

## Verificar Status dos Índices

1. Acesse o [Firebase Console](https://console.firebase.google.com)
2. Selecione seu projeto
3. Vá em Firestore Database > Indexes
4. Verifique se os índices estão com status "Enabled" (verde)

## Links Rápidos

- [Documentação de Índices do Firestore](https://firebase.google.com/docs/firestore/query-data/indexing)
- [Console do Firebase - Índices](https://console.firebase.google.com/project/repflowshow/firestore/indexes)


### 3. Grupos Públicos Ordenados por Data

**Coleção:** `groups`
**Campos:**
- `is_public` (Ascending)
- `created_at` (Descending)

**Como criar:**
1. Acesse o [Firebase Console](https://console.firebase.google.com)
2. Selecione seu projeto `repflowshow`
3. Vá em Firestore Database > Indexes
4. Clique em "Create Index"
5. Configure:
   - Collection ID: `groups`
   - Fields to index:
     - Field: `is_public`, Order: Ascending
     - Field: `created_at`, Order: Descending
6. Clique em "Create"

### 4. Exercícios de Grupo Ordenados por Data de Compartilhamento

**Coleção:** `group_exercises`
**Campos:**
- `groupId` (Ascending)
- `sharedAt` (Descending)

**Como criar:**
1. Acesse o [Firebase Console](https://console.firebase.google.com)
2. Selecione seu projeto `repflowshow`
3. Vá em Firestore Database > Indexes
4. Clique em "Create Index"
5. Configure:
   - Collection ID: `group_exercises`
   - Fields to index:
     - Field: `groupId`, Order: Ascending
     - Field: `sharedAt`, Order: Descending
6. Clique em "Create"
