# ⚡ Próximos Passos - Supabase

## ✅ Credenciais JÁ configuradas!

As credenciais já estão no `main.dart`. Agora falta:

---

## 📝 1. Executar Schema SQL no Supabase

### Passo a Passo:

1. **Abra o Supabase Dashboard**:
   - Vá para: https://supabase.com/dashboard/project/rsduxqgjbyhqttiobqvh

2. **Abra o SQL Editor**:
   - No menu lateral → **SQL Editor**
   - Clique em **"New query"**

3. **Cole o SQL completo**:
   - Abra o arquivo: [SQL_SCHEMA.sql](file:///c:/projetos/list-academic/repflow/SQL_SCHEMA.sql)
   - Copie TODO o conteúdo
   - Cole no SQL Editor

4. **Execute**:
   - Clique em **"Run"** (ou Ctrl+Enter)
   - Deve aparecer "Success. No rows returned"

5. **Verifique**:
   - Menu lateral → **Table Editor**
   - Deve ver 7 tabelas: `users`, `exercises`, `feeling_logs`, `comments`, `notifications`, `followers`, `likes`

---

## 🪣 2. Criar Storage Buckets

### 2.1 Bucket: exercise-images

1. Menu lateral → **Storage**
2. Clique em **"New bucket"**
3. Preencha:
   - **Name**: `exercise-images`
   - **Public bucket**: ✅ **MARCAR**
4. Clique **"Create bucket"**

### 2.2 Bucket: profile-images

1. Clique em **"New bucket"** novamente
2. Preencha:
   - **Name**: `profile-images`
   - **Public bucket**: ✅ **MARCAR**
3. Clique **"Create bucket"**

---

## 🚀 3. Executar o App!

```bash
cd c:\projetos\list-academic\repflow
flutter run
```

---

## ✅ Testar

1. **Cadastrar usuário**
   - Nome, Email, Senha
   - Deve criar e logar automaticamente

2. **Adicionar exercício**
   - Clique no "+"
   - Preencha e adicione foto

3. **Ver no Supabase**
   - Dashboard → Table Editor → `users`
   - Dashboard → Table Editor → `exercises`
   - Veja seus dados em tempo real!

---

## 🐛 Problema?

Se der erro ao cadastrar:
- Verifique se executou TODO o SQL schema
- Tabela `users` deve existir

Se imagens não aparecerem:
- Verifique se os buckets são **públicos**
