-- ============================================
-- CRIAR SISTEMA DE GRUPOS E FUNCIONALIDADES SOCIAIS
-- Execute este SQL no Supabase SQL Editor
-- ============================================

-- ========================================
-- TABELA: groups (academias, bairros, etc)
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
-- TABELA: group_members (membros dos grupos)
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
-- TABELA: group_exercises (exercícios compartilhados no grupo)
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
-- RLS PARA GROUPS
-- ========================================
ALTER TABLE groups ENABLE ROW LEVEL SECURITY;

-- Todos podem ver grupos públicos
CREATE POLICY "Anyone can view public groups"
  ON groups FOR SELECT
  USING (is_public = true OR EXISTS (
    SELECT 1 FROM group_members 
    WHERE group_members.group_id = groups.id 
    AND group_members.user_id = auth.uid()
  ));

-- Usuários autenticados podem criar grupos
CREATE POLICY "Authenticated users can create groups"
  ON groups FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = created_by);

-- Admins podem atualizar grupos
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

-- Admins podem deletar grupos
CREATE POLICY "Group admins can delete groups"
  ON groups FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM group_members 
      WHERE group_members.group_id = groups.id 
      AND group_members.user_id = auth.uid()
      AND group_members.role = 'admin'
    )
  );

-- ========================================
-- RLS PARA GROUP_MEMBERS
-- ========================================
ALTER TABLE group_members ENABLE ROW LEVEL SECURITY;

-- Membros podem ver outros membros do grupo
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

-- Usuários podem entrar em grupos públicos
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

-- Usuários podem sair de grupos
CREATE POLICY "Users can leave groups"
  ON group_members FOR DELETE
  USING (auth.uid() = user_id);

-- ========================================
-- RLS PARA GROUP_EXERCISES
-- ========================================
ALTER TABLE group_exercises ENABLE ROW LEVEL SECURITY;

-- Membros podem ver exercícios do grupo
CREATE POLICY "Group members can view group exercises"
  ON group_exercises FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM group_members 
      WHERE group_members.group_id = group_exercises.group_id 
      AND group_members.user_id = auth.uid()
    )
  );

-- Membros podem compartilhar exercícios no grupo
CREATE POLICY "Group members can share exercises"
  ON group_exercises FOR INSERT
  TO authenticated
  WITH CHECK (
    auth.uid() = shared_by
    AND EXISTS (
      SELECT 1 FROM group_members 
      WHERE group_members.group_id = group_exercises.group_id 
      AND group_members.user_id = auth.uid()
    )
  );

-- ========================================
-- TRIGGERS PARA CONTADORES
-- ========================================

-- Incrementar members_count ao adicionar membro
CREATE OR REPLACE FUNCTION increment_group_members_count()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE groups
  SET members_count = COALESCE(members_count, 0) + 1
  WHERE id = NEW.group_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_increment_group_members
  AFTER INSERT ON group_members
  FOR EACH ROW
  EXECUTE FUNCTION increment_group_members_count();

-- Decrementar members_count ao remover membro
CREATE OR REPLACE FUNCTION decrement_group_members_count()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE groups
  SET members_count = GREATEST(COALESCE(members_count, 0) - 1, 0)
  WHERE id = OLD.group_id;
  RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_decrement_group_members
  AFTER DELETE ON group_members
  FOR EACH ROW
  EXECUTE FUNCTION decrement_group_members_count();

-- Incrementar exercises_count ao compartilhar exercício
CREATE OR REPLACE FUNCTION increment_group_exercises_count()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE groups
  SET exercises_count = COALESCE(exercises_count, 0) + 1
  WHERE id = NEW.group_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_increment_group_exercises
  AFTER INSERT ON group_exercises
  FOR EACH ROW
  EXECUTE FUNCTION increment_group_exercises_count();

-- Decrementar exercises_count ao remover exercício
CREATE OR REPLACE FUNCTION decrement_group_exercises_count()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE groups
  SET exercises_count = GREATEST(COALESCE(exercises_count, 0) - 1, 0)
  WHERE id = OLD.group_id;
  RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_decrement_group_exercises
  AFTER DELETE ON group_exercises
  FOR EACH ROW
  EXECUTE FUNCTION decrement_group_exercises_count();

-- ========================================
-- TRIGGER: Adicionar criador como admin ao criar grupo
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
-- ATUALIZAR TABELA USERS (adicionar campos sociais)
-- ========================================
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS followers_count INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS following_count INTEGER DEFAULT 0;

-- ========================================
-- TRIGGERS PARA FOLLOWERS
-- ========================================

-- Incrementar contadores ao seguir
CREATE OR REPLACE FUNCTION increment_follow_counts()
RETURNS TRIGGER AS $$
BEGIN
  -- Incrementar following_count do seguidor
  UPDATE users
  SET following_count = COALESCE(following_count, 0) + 1
  WHERE id = NEW.follower_id;
  
  -- Incrementar followers_count do seguido
  UPDATE users
  SET followers_count = COALESCE(followers_count, 0) + 1
  WHERE id = NEW.following_id;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_increment_follow_counts
  AFTER INSERT ON followers
  FOR EACH ROW
  EXECUTE FUNCTION increment_follow_counts();

-- Decrementar contadores ao deixar de seguir
CREATE OR REPLACE FUNCTION decrement_follow_counts()
RETURNS TRIGGER AS $$
BEGIN
  -- Decrementar following_count do seguidor
  UPDATE users
  SET following_count = GREATEST(COALESCE(following_count, 0) - 1, 0)
  WHERE id = OLD.follower_id;
  
  -- Decrementar followers_count do seguido
  UPDATE users
  SET followers_count = GREATEST(COALESCE(followers_count, 0) - 1, 0)
  WHERE id = OLD.following_id;
  
  RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_decrement_follow_counts
  AFTER DELETE ON followers
  FOR EACH ROW
  EXECUTE FUNCTION decrement_follow_counts();

-- ========================================
-- VERIFICAÇÃO FINAL
-- ========================================
SELECT 'GRUPOS CRIADOS:' as info;
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('groups', 'group_members', 'group_exercises')
ORDER BY table_name;

SELECT 'POLÍTICAS DE GRUPOS:' as info;
SELECT tablename, policyname, cmd
FROM pg_policies 
WHERE tablename IN ('groups', 'group_members', 'group_exercises')
ORDER BY tablename, policyname;

SELECT 'TRIGGERS DE GRUPOS:' as info;
SELECT trigger_name, event_object_table
FROM information_schema.triggers
WHERE event_object_table IN ('groups', 'group_members', 'group_exercises', 'followers')
ORDER BY event_object_table, trigger_name;
