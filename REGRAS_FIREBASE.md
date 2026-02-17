# 🔐 Regras de Segurança Firebase - RepFlow

## ⚠️ IMPORTANTE
As regras de **Firestore** e **Storage** são SEPARADAS e devem ser aplicadas em locais DIFERENTES no Firebase Console!

---

## 1️⃣ REGRAS DO FIRESTORE DATABASE

### 📍 Onde aplicar:
Firebase Console → **Firestore Database** → Aba **Rules**

### 📋 Cole APENAS este código:

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

### ✅ Depois clique em **Publicar**

---

## 2️⃣ REGRAS DO STORAGE

### 📍 Onde aplicar:
Firebase Console → **Storage** → Aba **Rules**

### 📋 Cole APENAS este código:

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

### ✅ Depois clique em **Publicar**

---

## 🎯 Passo a Passo Visual

### Para Firestore:
1. Abra https://console.firebase.google.com/
2. Selecione seu projeto "repflow"
3. Menu lateral → **Firestore Database**
4. Clique na aba **Rules** (no topo)
5. **DELETE** todo o conteúdo existente
6. **COLE** as regras da seção 1️⃣ acima
7. Clique em **Publicar**

### Para Storage:
1. Ainda no Firebase Console
2. Menu lateral → **Storage**
3. Clique na aba **Rules** (no topo)
4. **DELETE** todo o conteúdo existente
5. **COLE** as regras da seção 2️⃣ acima
6. Clique em **Publicar**

---

## ⚠️ ERRO COMUM

❌ **ERRADO**: Colar as duas regras juntas no mesmo lugar
```
rules_version = '2';
service cloud.firestore {
  ...
}
service firebase.storage {  ← ERRO! Não pode ter dois "service" no mesmo arquivo
  ...
}
```

✅ **CORRETO**: Aplicar cada uma no seu local próprio (Firestore Rules vs Storage Rules)

---

## 🔍 Como Verificar se Deu Certo

### Firestore:
- Após publicar, deve mostrar: "Última modificação: alguns segundos atrás"
- Não deve ter erros de sintaxe

### Storage:
- Após publicar, deve mostrar: "Última modificação: alguns segundos atrás"
- Não deve ter erros de sintaxe

---

## 📱 Teste Pronto!

Depois de aplicar ambas as regras:
1. Execute `flutter run` no projeto
2. Cadastre um usuário
3. Adicione um exercício com foto
4. Tudo deve funcionar! ✅
