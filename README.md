# RepFlow - Seu Parceiro de Treinos 💪

Um aplicativo Flutter de academia com funcionalidades sociais, desenvolvido com Firebase.

## 📱 Funcionalidades Implementadas

### ✅ Core Features (MVP)
- **Autenticação**: Login e cadastro com Firebase Auth
- **Gestão de Exercícios**: 
  - Adicionar exercícios com nome, grupo de treino (A, B, C, etc.), instruções
  - Upload de foto da máquina
  - Listagem agrupada por treino
  - Visualização detalhada
  - Excluir exercícios
- **Logs de Sentimento**: Sistema de notas datadas para cada exercício
- **Privacidade**: Toggle público/privado para exercícios

### 🚧 Funcionalidades Sociais (Preparadas, não implementadas na UI)
Toda a infraestrutura foi criada, faltando apenas implementar as telas:
- Sistema de perfis públicos/privados
- Feed comunitário de exercícios
- Seguir/Deixar de seguir usuários
- Comentários e sugestões
- Sistema de curtidas
- Notificações em tempo real

## 🔧 Configuração Firebase (OBRIGATÓRIO)

### Passo 1: Instalar FlutterFire CLI

```bash
dart pub global activate flutterfire_cli
```

### Passo 2: Criar Projeto Firebase

1. Acesse [Firebase Console](https://console.firebase.google.com/)
2. Crie um novo projeto ou use um existente
3. Habilite os seguintes serviços:
   - **Authentication** → Email/Password
   - **Cloud Firestore** (mode: production)
   - **Storage**

### Passo 3: Configurar FlutterFire no Projeto

Execute no diretório `repflow`:

```bash
flutterfire configure
```

- Selecione seu projeto Firebase
- Selecione as plataformas (Android, iOS, Web)
- O arquivo `lib/firebase_options.dart` será gerado automaticamente

### Passo 4: Configurar Regras de Segurança

#### Firestore Rules
No Firebase Console > Firestore > Rules, cole:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Exercises
    match /exercises/{exerciseId} {
      allow read: if request.auth != null && 
        (request.auth.uid == resource.data.userId || resource.data.isPublic == true);
      allow write: if request.auth != null && request.auth.uid == resource.data.userId;
    }
    
    // Feeling logs
    match /feeling_logs/{logId} {
      allow read, write: if request.auth != null;
    }
    
    // Users
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Comments
    match /comments/{commentId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null && request.auth.uid == resource.data.userId;
    }
    
    // Notifications
    match /notifications/{notificationId} {
      allow read, write: if request.auth != null && request.auth.uid == resource.data.userId;
    }
    
    // Followers
    match /followers/{followId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
    
    // Likes
    match /likes/{likeId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
  }
}
```

#### Storage Rules
No Firebase Console > Storage > Rules, cole:

```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /exercise_images/{userId}/{imageId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /profile_images/{imageId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
  }
}
```

## 🚀 Executar o Projeto

```bash
# Instalar dependências
flutter pub get

# Executar em modo debug
flutter run

# Executar em dispositivo específico
flutter devices  # Liste dispositivos
flutter run -d <device_id>
```

## 📋 Estrutura do Projeto

```
lib/
├── config/
│   └── app_theme.dart          # Tema do app
├── models/
│   ├── exercise_model.dart
│   ├── feeling_log_model.dart
│   ├── user_profile_model.dart
│   ├── comment_model.dart
│   └── notification_model.dart
├── services/
│   ├── auth_service.dart       # Autenticação Firebase
│   ├── firestore_service.dart  # CRUD Firestore
│   ├── storage_service.dart    # Upload imagens
│   └── social_service.dart     # Funcionalidades sociais
├── providers/
│   ├── auth_provider.dart
│   └── exercises_provider.dart
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── home/
│   │   ├── home_screen.dart
│   │   └── add_exercise_screen.dart
│   ├── exercise/
│   │   └── exercise_detail_screen.dart
│   └── social/                 # A implementar
└── widgets/
    ├── custom_button.dart
    ├── custom_text_field.dart
    └── user_avatar.dart
```

## 🎨 Design

- **Cores**: Azul profissional (#1E3A8A) + Laranja energético (#EA580C)
- **Framework UI**: Material Design 3
- **Tipografia**: Padrão do sistema com hierarquia clara

## 📝 Próximos Passos

1. **Configurar Firebase** (obrigatório para rodar)
2. **Implementar funcionalidade de editar exercício**
3. **Adicionar telas sociais**:
   - Feed comunitário
   - Perfil do usuário
   - Notificações
   - Busca de usuários
4. **Melhorias de UX**:
   - Loading states
   - Animações de transição
   - Feedback visual melhorado

## 🤝 Contribuindo

Este é um projeto pessoal de academia. Sinta-se livre para fazer fork e customizar!

## 📄 Licença

MIT
