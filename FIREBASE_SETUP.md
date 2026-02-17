# 🔥 Configuração Firebase - RepFlow

## ✅ Status da Configuração

### Android - CONFIGURADO ✓
- ✅ `google-services.json` instalado em `android/app/`
- ✅ `android/build.gradle.kts` configurado com Google Services plugin
- ✅ `android/app/build.gradle.kts` configurado com:
  - Plugin Google Services
  - Firebase BoM 34.9.0
  - Firebase Analytics
  - Firebase Auth
  - Firebase Firestore
  - Firebase Storage
- ✅ `lib/firebase_options.dart` criado
- ✅ FlutterFire CLI instalado

## 🚀 Próximos Passos

### 1. Testar o App

```bash
# No diretório: c:\projetos\list-academic\repflow

# Verificar dispositivos disponíveis
flutter devices

# Executar no Android
flutter run
```

### 2. Se Encontrar Erros de Build

#### Limpar cache e rebuildar:
```bash
flutter clean
flutter pub get
cd android
./gradlew clean
cd ..
flutter run
```

#### Erro: "Duplicate class found"
Adicione no `android/gradle.properties`:
```
android.enableJetifier=true
android.useAndroidX=true
```

#### Erro: "minSdkVersion"
No Firebase Console, certifique-se que criou o app Android com o package name: `com.repflow.repflow`

### 3. Habilitar Serviços no Firebase Console

Acesse: https://console.firebase.google.com/

1. **Authentication**
   - Aba "Sign-in method"
   - Habilitar "Email/Password"

2. **Firestore Database**
   - Criar database em modo "production"
   - Aplicar regras de segurança (ver README.md)

3. **Storage**
   - Criar bucket padrão
   - Aplicar regras de segurança (ver README.md)

## 📝 Regras de Segurança

### Firestore Rules

Copie e cole no Firebase Console > Firestore > Rules:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /exercises/{exerciseId} {
      allow read: if request.auth != null && 
        (request.auth.uid == resource.data.userId || resource.data.isPublic == true);
      allow write: if request.auth != null && request.auth.uid == resource.data.userId;
    }
    
    match /feeling_logs/{logId} {
      allow read, write: if request.auth != null;
    }
    
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /comments/{commentId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null && request.auth.uid == resource.data.userId;
    }
    
    match /notifications/{notificationId} {
      allow read, write: if request.auth != null && request.auth.uid == resource.data.userId;
    }
    
    match /followers/{followId} {
      allow read, write: if request.auth != null;
    }
    
    match /likes/{likeId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### Storage Rules

Copie e cole no Firebase Console > Storage > Rules:

```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /exercise_images/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
    
    match /profile_images/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
  }
}
```

## 🎯 Testando as Funcionalidades

### 1. Cadastro
- Abra o app
- Clique em "Cadastre-se"
- Preencha: Nome, Email, Senha
- Clique em "Criar Conta"
- ✅ Deve criar usuário e fazer login automaticamente

### 2. Adicionar Exercício
- Na Home, clique no botão "+"
- Adicione foto (opcional)
- Preencha: Nome, Treino, Instruções
- Toggle "Tornar público" se desejar
- Clique em "Salvar"
- ✅ Exercício deve aparecer na lista

### 3. Ver Detalhes
- Clique em um exercício
- Veja foto, instruções
- Adicione nota em "Como estou me sentindo"
- ✅ Nota deve aparecer na lista

### 4. Logout
- Clique no avatar no canto superior direito
- Clique em "Sair"
- ✅ Deve voltar para tela de login

## 🐛 Problemas Comuns

### App não conecta ao Firebase
- Verifique se o `google-services.json` está em `android/app/`
- Verifique package name: `com.repflow.repflow`
- Rebuilde: `flutter clean && flutter pub get && flutter run`

### Erro "FirebaseApp not initialized"
- O Firebase está sendo inicializado automaticamente
- Se persistir, adicione `--release` ao comando: `flutter run --release`

### Imagens não fazem upload
- Verifique regras do Storage no Firebase Console
- Garanta que Authentication está habilitado

## 📱 Plataformas

| Plataforma | Status |
|------------|--------|
| Android    | ✅ Configurado |
| iOS        | ❌ Não configurado |
| Web        | ❌ Não configurado |

Para adicionar iOS ou Web, execute:
```bash
flutterfire configure
```
E selecione as plataformas adicionais.
