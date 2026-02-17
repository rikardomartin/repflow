-- ========================================
-- REPFLOW - SUPABASE DATABASE SCHEMA
-- SCHEMA COMPLETO E ATUALIZADO
-- ========================================

-- ========================================
-- LIMPAR TUDO PRIMEIRO
-- ========================================

-- Drop all policies
DROP POLICY IF EXISTS "Users can view own or public exercises" ON exercises;
DROP POLICY IF EXISTS "Users can insert own exercises" ON exercises;
DROP POLICY IF EXISTS "Users can update own exercises" ON exercises;
DROP POLICY IF EXISTS "Users can delete own exercises" ON exercises;
DROP POLICY IF EXISTS "Users can view feeling logs of accessible exercises" ON feeling_logs;
DROP POLICY IF EXISTS "Users can insert feeling logs on own exercises" ON feeling_logs;
DROP POLICY IF EXISTS "Users are viewable by everyone" ON users;
DROP POLICY IF EXISTS "Users can insert their own profile" ON users;
DROP POLICY IF EXISTS "Users can update own profile" ON users;
DROP POLICY IF EXISTS "Comments are viewable if exercise is accessible" ON comments;
DROP POLICY IF EXISTS "Users can insert comments on public exercises" ON comments;
DROP POLICY IF EXISTS "Users can view own notifications" ON notifications;
DROP POLICY IF EXISTS "Users can update own notifications" ON notifications;
DROP POLICY IF EXISTS "Users can insert notifications" ON notifications;
DROP POLICY IF EXISTS "Followers are viewable by everyone" ON followers;
DROP POLICY IF EXISTS "Users can manage own follows" ON followers;
DROP POLICY IF EXISTS "Likes are viewable by everyone" ON likes;
DROP POLICY IF EXISTS "Users can manage own likes" ON likes;

-- Drop triggers
DROP TRIGGER IF EXISTS trigger_increment_likes ON likes;
DROP TRIGGER IF EXISTS trigger_decrement_likes ON likes;

-- Drop functions
DROP FUNCTION IF EXISTS increment_likes_count();
DROP FUNCTION IF EXISTS decrement_likes_count();
DROP FUNCTION IF EXISTS increment_reaction_count();
DROP FUNCTION IF EXISTS decrement_reaction_count();

-- Drop tables (CASCADE remove todas as constraints)
DROP TABLE IF EXISTS likes CASCADE;
DROP TABLE IF EXISTS followers CASCADE;
DROP TABLE IF EXISTS notifications CASCADE;
DROP TABLE IF EXISTS comments CASCADE;
DROP TABLE IF EXISTS feeling_logs CASCADE;
DROP TABLE IF EXISTS exercises CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- ========================================
-- CRIAR TABELAS
-- ========================================

-- TABELA: users
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

-- TABELA: exercises
CREATE TABLE exercises (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  training_group TEXT NOT NULL,
  instructions TEXT NOT NULL,
  machine_image_url TEXT,
  is_public BOOLEAN DEFAULT false,
  likes_count INTEGER DEFAULT 0,
  valeu_count INTEGER DEFAULT 0,
  amen_count INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- TABELA: feeling_logs
CREATE TABLE feeling_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  exercise_id UUID NOT NULL REFERENCES exercises(id) ON DELETE CASCADE,
  note TEXT NOT NULL,
  timestamp TIMESTAMPTZ DEFAULT NOW()
);

-- TABELA: comments
CREATE TABLE comments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  exercise_id UUID NOT NULL REFERENCES exercises(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  user_display_name TEXT NOT NULL,
  user_profile_image_url TEXT,
  text TEXT NOT NULL,
  timestamp TIMESTAMPTZ DEFAULT NOW()
);

-- TABELA: notifications
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

-- TABELA: followers
CREATE TABLE followers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  follower_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  following_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  timestamp TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(follower_id, following_id)
);

-- TABELA: likes (com suporte a múltiplas reações)
CREATE TABLE likes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  exercise_id UUID NOT NULL REFERENCES exercises(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  reaction_type TEXT DEFAULT 'like' CHECK (reaction_type IN ('like', 'valeu', 'amen')),
  timestamp TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(exercise_id, user_id, reaction_type)
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

CREATE POLICY "Users can insert their own profile"
  ON users FOR INSERT
  WITH CHECK (auth.uid() = id);

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

CREATE POLICY "Users can insert notifications"
  ON notifications FOR INSERT
  WITH CHECK (true);

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
-- TRIGGERS para atualizar contadores de reações
-- ========================================

-- Trigger para incrementar contadores por tipo
CREATE OR REPLACE FUNCTION increment_reaction_count()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.reaction_type = 'like' THEN
    UPDATE exercises SET likes_count = COALESCE(likes_count, 0) + 1 WHERE id = NEW.exercise_id;
  ELSIF NEW.reaction_type = 'valeu' THEN
    UPDATE exercises SET valeu_count = COALESCE(valeu_count, 0) + 1 WHERE id = NEW.exercise_id;
  ELSIF NEW.reaction_type = 'amen' THEN
    UPDATE exercises SET amen_count = COALESCE(amen_count, 0) + 1 WHERE id = NEW.exercise_id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_increment_likes
  AFTER INSERT ON likes
  FOR EACH ROW
  EXECUTE FUNCTION increment_reaction_count();

-- Trigger para decrementar contadores por tipo
CREATE OR REPLACE FUNCTION decrement_reaction_count()
RETURNS TRIGGER AS $$
BEGIN
  IF OLD.reaction_type = 'like' THEN
    UPDATE exercises SET likes_count = GREATEST(COALESCE(likes_count, 0) - 1, 0) WHERE id = OLD.exercise_id;
  ELSIF OLD.reaction_type = 'valeu' THEN
    UPDATE exercises SET valeu_count = GREATEST(COALESCE(valeu_count, 0) - 1, 0) WHERE id = OLD.exercise_id;
  ELSIF OLD.reaction_type = 'amen' THEN
    UPDATE exercises SET amen_count = GREATEST(COALESCE(amen_count, 0) - 1, 0) WHERE id = OLD.exercise_id;
  END IF;
  RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_decrement_likes
  AFTER DELETE ON likes
  FOR EACH ROW
  EXECUTE FUNCTION decrement_reaction_count();

-- ========================================
-- TRIGGER para criar perfil automaticamente
-- ========================================

-- Função que cria o perfil em public.users quando usuário se registra
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.users (id, display_name, created_at)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'display_name', 'Usuário'),
    NOW()
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$;

-- Trigger que executa após criar usuário no auth
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- ========================================
-- ÍNDICES PARA PERFORMANCE
-- ========================================

CREATE INDEX idx_exercises_user_id ON exercises(user_id);
CREATE INDEX idx_exercises_public ON exercises(is_public) WHERE is_public = true;
CREATE INDEX idx_exercises_created_at ON exercises(created_at DESC);

CREATE INDEX idx_comments_exercise_id ON comments(exercise_id);
CREATE INDEX idx_comments_timestamp ON comments(timestamp DESC);

CREATE INDEX idx_likes_exercise_id ON likes(exercise_id);
CREATE INDEX idx_likes_user_reaction ON likes(user_id, reaction_type);

CREATE INDEX idx_followers_follower ON followers(follower_id);
CREATE INDEX idx_followers_following ON followers(following_id);

CREATE INDEX idx_notifications_user_unread ON notifications(user_id, is_read);
CREATE INDEX idx_notifications_timestamp ON notifications(timestamp DESC);

-- ========================================
-- TABELA: groups
-- ========================================
CREATE TABLE IF NOT EXISTS groups (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT,
  type TEXT NOT NULL CHECK (type IN ('academia', 'bairro', 'time', 'outro')),
  image_url TEXT,
  created_by UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  members_count INTEGER DEFAULT 0,
  exercises_count INTEGER DEFAULT 0,
  is_public BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ========================================
-- TABELA: group_members
-- ========================================
CREATE TABLE IF NOT EXISTS group_members (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  group_id UUID NOT NULL REFERENCES groups(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  role TEXT DEFAULT 'member' CHECK (role IN ('admin', 'moderator', 'member')),
  joined_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(group_id, user_id)
);

-- ========================================
-- TABELA: group_exercises
-- ========================================
CREATE TABLE IF NOT EXISTS group_exercises (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  group_id UUID NOT NULL REFERENCES groups(id) ON DELETE CASCADE,
  exercise_id UUID NOT NULL REFERENCES exercises(id) ON DELETE CASCADE,
  shared_by UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  shared_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(group_id, exercise_id)
);

-- ========================================
-- RLS PARA GRUPOS
-- ========================================
ALTER TABLE groups ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view public groups"
  ON groups FOR SELECT
  USING (is_public = true OR EXISTS (
    SELECT 1 FROM group_members 
    WHERE group_members.group_id = groups.id 
    AND group_members.user_id = auth.uid()
  ));

CREATE POLICY "Authenticated users can create groups"
  ON groups FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = created_by);

CREATE POLICY "Group admins can update groups"
  ON groups FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM group_members 
      WHERE group_members.group_id = groups.id 
      AND group_members.user_id = auth.uid()
      AND group_members.role = 'admin'
    )
  );

ALTER TABLE group_members ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Group members can view members"
  ON group_members FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM groups 
      WHERE groups.id = group_members.group_id 
      AND (groups.is_public = true OR EXISTS (
        SELECT 1 FROM group_members gm2
        WHERE gm2.group_id = groups.id 
        AND gm2.user_id = auth.uid()
      ))
    )
  );

CREATE POLICY "Users can join public groups"
  ON group_members FOR INSERT
  TO authenticated
  WITH CHECK (
    auth.uid() = user_id 
    AND EXISTS (
      SELECT 1 FROM groups 
      WHERE groups.id = group_members.group_id 
      AND groups.is_public = true
    )
  );

-- ========================================
-- TRIGGERS DE GRUPOS
-- ========================================
CREATE OR REPLACE FUNCTION add_creator_as_admin()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO group_members (group_id, user_id, role)
  VALUES (NEW.id, NEW.created_by, 'admin');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_add_creator_as_admin
  AFTER INSERT ON groups
  FOR EACH ROW
  EXECUTE FUNCTION add_creator_as_admin();

-- ========================================
-- VERIFICAÇÃO FINAL
-- ========================================
SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' ORDER BY table_name;
