-- ============================================
-- ADICIONAR FUNCIONALIDADE DE GRUPOS
-- Execute este SQL no Supabase SQL Editor
-- ============================================

-- Este script cria as tabelas de grupos que estavam faltando
-- e corrige o erro de relacionamento entre group_members e users

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
-- RLS PARA GROUPS
-- ========================================
ALTER TABLE groups ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Anyone can view public groups" ON groups;
CREATE POLICY "Anyone can view public groups"
  ON groups FOR SELECT
  USING (is_public = true OR EXISTS (
    SELECT 1 FROM group_members 
    WHERE group_members.group_id = groups.id 
    AND group_members.user_id = auth.uid()
  ));

DROP POLICY IF EXISTS "Authenticated users can create groups" ON groups;
CREATE POLICY "Authenticated users can create groups"
  ON groups FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = created_by);

DROP POLICY IF EXISTS "Group admins can update groups" ON groups;
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

DROP POLICY IF EXISTS "Group admins can delete groups" ON groups;
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

DROP POLICY IF EXISTS "Group members can view members" ON group_members;
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

DROP POLICY IF EXISTS "Users can join public groups" ON group_members;
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

DROP POLICY IF EXISTS "Users can leave groups" ON group_members;
CREATE POLICY "Users can leave groups"
  ON group_members FOR DELETE
  USING (auth.uid() = user_id);

-- ========================================
-- RLS PARA GROUP_EXERCISES
-- ========================================
ALTER TABLE group_exercises ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Group members can view group exercises" ON group_exercises;
CREATE POLICY "Group members can view group exercises"
  ON group_exercises FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM group_members 
      WHERE group_members.group_id = group_exercises.group_id 
      AND group_members.user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Group members can share exercises" ON group_exercises;
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
-- TRIGGERS DE GRUPOS
-- ========================================

-- Trigger: Adicionar criador como admin
CREATE OR REPLACE FUNCTION add_creator_as_admin()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO group_members (group_id, user_id, role)
  VALUES (NEW.id, NEW.created_by, 'admin');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_add_creator_as_admin ON groups;
CREATE TRIGGER trigger_add_creator_as_admin
  AFTER INSERT ON groups
  FOR EACH ROW
  EXECUTE FUNCTION add_creator_as_admin();

-- Trigger: Incrementar membros
CREATE OR REPLACE FUNCTION increment_group_members_count()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE groups
  SET members_count = COALESCE(members_count, 0) + 1
  WHERE id = NEW.group_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_increment_group_members ON group_members;
CREATE TRIGGER trigger_increment_group_members
  AFTER INSERT ON group_members
  FOR EACH ROW
  EXECUTE FUNCTION increment_group_members_count();

-- Trigger: Decrementar membros
CREATE OR REPLACE FUNCTION decrement_group_members_count()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE groups
  SET members_count = GREATEST(COALESCE(members_count, 0) - 1, 0)
  WHERE id = OLD.group_id;
  RETURN OLD;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_decrement_group_members ON group_members;
CREATE TRIGGER trigger_decrement_group_members
  AFTER DELETE ON group_members
  FOR EACH ROW
  EXECUTE FUNCTION decrement_group_members_count();

-- Verificar tabelas
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('groups', 'group_members', 'group_exercises')
ORDER BY table_name;
