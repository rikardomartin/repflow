# 🚀 Guia Completo de Setup - Supabase

## ✅ Migração Completa!

Todo o código foi migrado de Firebase para Supabase. Agora você precisa:
1. Criar projeto no Supabase
2. Executar o schema SQL
3. Configurar as credenciais no app
4. Testar!

---

## 📋 Passo 1: Criar Projeto no Supabase

### 1.1 Criar Conta
1. Acesse: https://supabase.com
2. Clique em **"Start your project"**
3. Faça login com GitHub, Google ou Email

### 1.2 Criar Novo Projeto
1. Clique em **"New project"**
2. Preencha:
   - **Name**: `RepFlow`
   - **Database Password**: (anote bem essa senha!)
   - **Region**: Escolha o mais próximo do Brasil (ex: South America - São Paulo)
3. Clique em **"Create new project"**
4. Aguarde 2-3 minutos para o projeto ser criado

---

## 📝 Passo 2: Executar Schema SQL

### 2.1 Abrir SQL Editor
1. No painel lateral, clique em **"SQL Editor"**
2. Clique em **"New query"**

### 2.2 Copiar e Colar o Schema

Cole TODO este código SQL:

```sql
-- ========================================
-- TABELA: users
-- ========================================
CREATE TABLE users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  display_name TEXT NOT NULL,
  bio TEXT,
  profile_image_url TEXT,
  is_public BOOLEAN DEFAULT true,
  allow_comments BOOLEAN DEFAULT true,
  followers_count INTEGER DEFAULT 0,
  following_count INTEGER DEFAULT 0,
  exercises_count INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ========================================
-- TABELA: exercises
-- ========================================
CREATE TABLE exercises (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  training_group TEXT NOT NULL,
  instructions TEXT NOT NULL,
  machine_image_url TEXT,
  is_public BOOLEAN DEFAULT false,
  likes_count INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ========================================
-- TABELA: feeling_logs
-- ========================================
CREATE TABLE feeling_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  exercise_id UUID NOT NULL REFERENCES exercises(id) ON DELETE CASCADE,
  note TEXT NOT NULL,
  timestamp TIMESTAMPTZ DEFAULT NOW()
);

-- ========================================
-- TABELA: comments
-- ========================================
CREATE TABLE comments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  exercise_id UUID NOT NULL REFERENCES exercises(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  user_display_name TEXT NOT NULL,
  user_profile_image_url TEXT,
  text TEXT NOT NULL,
  timestamp TIMESTAMPTZ DEFAULT NOW()
);

-- ========================================
-- TABELA: notifications
-- ========================================
CREATE TABLE notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  from_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  type TEXT NOT NULL CHECK (type IN ('follow', 'comment', 'like')),
  exercise_id UUID REFERENCES exercises(id) ON DELETE CASCADE,
  preview_text TEXT,
  is_read BOOLEAN DEFAULT false,
  timestamp TIMESTAMPTZ DEFAULT NOW()
);

-- ========================================
-- TABELA: followers
-- ========================================
CREATE TABLE followers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  follower_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  following_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  timestamp TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(follower_id, following_id)
);

-- ========================================
-- TABELA: likes
-- ========================================
CREATE TABLE likes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  exercise_id UUID NOT NULL REFERENCES exercises(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  timestamp TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(exercise_id, user_id)
);

-- ========================================
-- ROW LEVEL SECURITY (RLS)
-- ========================================

-- Exercises
ALTER TABLE exercises ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own or public exercises"
  ON exercises FOR SELECT
  USING (auth.uid() = user_id OR is_public = true);

CREATE POLICY "Users can insert own exercises"
  ON exercises FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own exercises"
  ON exercises FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own exercises"
  ON exercises FOR DELETE
  USING (auth.uid() = user_id);

-- Feeling Logs
ALTER TABLE feeling_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view feeling logs of accessible exercises"
  ON feeling_logs FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM exercises
      WHERE exercises.id = feeling_logs.exercise_id
      AND (exercises.user_id = auth.uid() OR exercises.is_public = true)
    )
  );

CREATE POLICY "Users can insert feeling logs on own exercises"
  ON feeling_logs FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM exercises
      WHERE exercises.id = feeling_logs.exercise_id
      AND exercises.user_id = auth.uid()
    )
  );

-- Users
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users are viewable by everyone"
  ON users FOR SELECT
  USING (true);

CREATE POLICY "Users can update own profile"
  ON users FOR UPDATE
  USING (auth.uid() = id);

-- Comments
ALTER TABLE comments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Comments are viewable if exercise is accessible"
  ON comments FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM exercises
      WHERE exercises.id = comments.exercise_id
      AND (exercises.user_id = auth.uid() OR exercises.is_public = true)
    )
  );

CREATE POLICY "Users can insert comments on public exercises"
  ON comments FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM exercises
      WHERE exercises.id = comments.exercise_id
      AND exercises.is_public = true
    )
  );

-- Notifications
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own notifications"
  ON notifications FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can update own notifications"
  ON notifications FOR UPDATE
  USING (auth.uid() = user_id);

-- Followers
ALTER TABLE followers ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Followers are viewable by everyone"
  ON followers FOR SELECT
  USING (true);

CREATE POLICY "Users can manage own follows"
  ON followers FOR ALL
  USING (auth.uid() = follower_id);

-- Likes
ALTER TABLE likes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Likes are viewable by everyone"
  ON likes FOR SELECT
  USING (true);

CREATE POLICY "Users can manage own likes"
  ON likes FOR ALL
  USING (auth.uid() = user_id);

-- ========================================
-- TRIGGERS para atualizar contadores
-- ========================================

-- Trigger para incrementar likes_count
CREATE OR REPLACE FUNCTION increment_likes_count()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE exercises
  SET likes_count = likes_count + 1
  WHERE id = NEW.exercise_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_increment_likes
  AFTER INSERT ON likes
  FOR EACH ROW
  EXECUTE FUNCTION increment_likes_count();

-- Trigger para decrementar likes_count
CREATE OR REPLACE FUNCTION decrement_likes_count()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE exercises
  SET likes_count = likes_count - 1
  WHERE id = OLD.exercise_id;
  RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_decrement_likes
  AFTER DELETE ON likes
  FOR EACH ROW
  EXECUTE FUNCTION decrement_likes_count();
```

### 2.3 Executar
1. Clique em **"Run"** (ou pressione Ctrl+Enter)
2. Deve aparecer **"Success. No rows returned"**
3. Verifique na lateral em **"Table Editor"** que as 7 tabelas foram criadas

---

## 🪣 Passo 3: Criar Storage Buckets

### 3.1 Criar bucket para imagens de exercícios
1. Na lateral, clique em **"Storage"**
2. Clique em **"New bucket"**
3. Preencha:
   - **Name**: `exercise-images`
   - **Public bucket**: ✅ Marcar
4. Clique em **"Create bucket"**

### 3.2 Criar bucket para fotos de perfil
1. Clique em **"New bucket"** novamente
2. Preencha:
   - **Name**: `profile-images`
   - **Public bucket**: ✅ Marcar
3. Clique em **"Create bucket"**

---

## 🔑 Passo 4: Obter Credenciais

### 4.1 Copiar URL e Key
1. Na lateral, clique em **"Settings"** (ícone de engrenagem)
2. Clique em **"API"**
3. Você verá:
   - **Project URL**: `https://xxxxx.supabase.co`
   - **anon public**: `eyJhbGciOiJIUzI1NiIs...` (chave longa)
4. **COPIE AMBOS!**

### 4.2 Configurar no App
Abra o arquivo: `c:\projetos\list-academic\repflow\lib\main.dart`

Substitua as linhas 13-14:
```dart
url: 'YOUR_SUPABASE_URL', // COLE SUA URL AQUI
anonKey: 'YOUR_SUPABASE_ANON_KEY', // COLE SUA KEY AQUI
```

Por exemplo:
```dart
url: 'https://abcdefghijk.supabase.co',
anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
```

---

## 🏃‍♂️ Passo 5: Executar o App!

```bash
cd c:\projetos\list-academic\repflow

# Baixar dependências
flutter pub get

# Executar
flutter run
```

---

## ✅ Testar Funcionalidades

### 1. Cadastro
- Abra o app
- Clique em "Cadastre-se"
- Preencha nome, email, senha
- ✅ Deve criar conta e logar automaticamente

### 2. Adicionar Exercício
- Clique no botão "+"
- Preencha: Nome, Treino, Instruções
- Adicione foto (opcional)
- ✅ Exercício deve aparecer na lista

### 3. Ver Detalhes
- Clique no exercício
- Adicione nota em "Como estou me sentindo"
- ✅ Nota deve aparecer imediatamente (Realtime!)

---

## 🎯 Verificar no Supabase Dashboard

### Ver usuários criados:
1. Supabase Dashboard → **Authentication**
2. Deve aparecer os usuários cadastrados

### Ver dados:
1. Supabase Dashboard → **Table Editor**
2. Clique em qualquer tabela (users, exercises, etc)
3. Veja os dados em tempo real!

---

## 🔥 Realtime (Bônus!)

O Supabase tem realtime nativo! Quando você adiciona um exercício ou nota, outros dispositivos veem na hora.

Para habilitar:
1. Dashboard → **Database** → **Replication**
2. Selecione todas as tabelas
3. Clique em **"Enable"**

---

## 🐛 Problemas Comuns

### "Invalid API key"
- Verifique se copiou corretamente a `anon public` key
- Não use a `service_role` key (essa é secreta!)

### "Failed to create user profile"
- Verifique se executou o SQL schema completo
- Tabela `users` deve existir

### Imagens não aparecem
- Verifique se os buckets são **públicos**
- Storage → bucket → Settings → Public

---

## 📊 Diferenças do Firebase

| Firebase | Supabase | Vantagem |
|----------|----------|----------|
| NoSQL | PostgreSQL | Queries SQL reais |
| Streams | Realtime | Mais rápido |
| Rules personalizadas | RLS (SQL) | Mais poderoso |
| Setup complexo | Setup simples | 5 min vs 30 min |

---

## 🎉 Pronto!

Agora você tem um app 100% funcional com Supabase!

**Próximos passos (opcional):**
- Implementar telas sociais (feed, perfil, etc)
- Adicionar funcionalidade de editar exercício
- Configurar email de confirmação
