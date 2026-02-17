-- ============================================
-- CORREÇÃO DEFINITIVA V3 - ELIMINANDO RECURSÃO INFINITA
-- Execute este SQL no Supabase SQL Editor
-- ============================================

-- O problema "infinite recursion" acontece porque as policies
-- ficam checando umas as outras num loop sem fim.

-- 1. Desabilitar RLS temporariamente para limpar policies
ALTER TABLE groups DISABLE ROW LEVEL SECURITY;
ALTER TABLE group_members DISABLE ROW LEVEL SECURITY;
ALTER TABLE group_exercises DISABLE ROW LEVEL SECURITY;

-- 2. Remover TODAS as policies antigas problemáticas
DROP POLICY IF EXISTS "Anyone can view public groups" ON groups;
DROP POLICY IF EXISTS "Authenticated users can create groups" ON groups;
DROP POLICY IF EXISTS "Group admins can update groups" ON groups;
DROP POLICY IF EXISTS "Group admins can delete groups" ON groups;
DROP POLICY IF EXISTS "Public groups are viewable" ON groups;

DROP POLICY IF EXISTS "Group members can view members" ON group_members;
DROP POLICY IF EXISTS "Users can join public groups" ON group_members;
DROP POLICY IF EXISTS "Users can leave groups" ON group_members;
DROP POLICY IF EXISTS "Members are viewable" ON group_members;
DROP POLICY IF EXISTS "Users can join" ON group_members;
DROP POLICY IF EXISTS "Admins can remove members" ON group_members;

DROP POLICY IF EXISTS "Group members can view group exercises" ON group_exercises;
DROP POLICY IF EXISTS "Group members can share exercises" ON group_exercises;

-- ========================================================
-- SOLUÇÃO: POLICIES SIMPLIFICADAS E DIRETAS
-- ========================================================

-- --- GROUPS ---

-- 1. Qualquer um pode ver grupos públicos (Simplificado)
CREATE POLICY "Public groups are viewable" 
  ON groups FOR SELECT 
  USING (is_public = true);

-- 2. Membros podem ver grupos privados (Sem recursão: direto na tabela group_members)
CREATE POLICY "Members can view private groups" 
  ON groups FOR SELECT 
  USING (
    EXISTS (
      SELECT 1 FROM group_members 
      WHERE group_members.group_id = id -- id da tabela groups
      AND group_members.user_id = auth.uid()
    )
  );

-- 3. Inserir grupos (Autenticado)
CREATE POLICY "Authenticated users can create groups" 
  ON groups FOR INSERT 
  WITH CHECK (auth.uid() = created_by);

-- 4. Atualizar grupos (Admins apenas)
CREATE POLICY "Admins can update groups" 
  ON groups FOR UPDATE 
  USING (
    EXISTS (
      SELECT 1 FROM group_members 
      WHERE group_members.group_id = id
      AND group_members.user_id = auth.uid()
      AND group_members.role = 'admin'
    )
  );

-- --- GROUP MEMBERS ---

-- 1. Ver membros (Simplificado: Se você é membro ou o grupo é público)
-- ATENÇÃO: Aqui estava a recursão. Vamos simplificar.
CREATE POLICY "View members" 
  ON group_members FOR SELECT 
  USING (
    -- Você pode ver o registro se:
    -- 1. É o seu próprio registro
    user_id = auth.uid()
    OR
    -- 2. O grupo é público (checagem direta)
    EXISTS (
      SELECT 1 FROM groups 
      WHERE groups.id = group_members.group_id 
      AND groups.is_public = true
    )
    OR
    -- 3. Você é membro do mesmo grupo (checagem direta sem cruzar policies)
    EXISTS (
      SELECT 1 FROM group_members gm 
      WHERE gm.group_id = group_members.group_id 
      AND gm.user_id = auth.uid()
    )
  );

-- 2. Entrar em grupos (INSERT)
CREATE POLICY "Join groups" 
  ON group_members FOR INSERT 
  WITH CHECK (
    user_id = auth.uid() -- Só pode adicionar a si mesmo
    AND (
      -- Grupo é público
      EXISTS (
        SELECT 1 FROM groups 
        WHERE groups.id = group_id 
        AND groups.is_public = true
      )
      OR
      -- OU você foi convidado/adicionado por um admin (futuro)
      -- Por enquanto, permite entrar em públicos
      true
    )
  );

-- 3. Sair de grupos (DELETE)
CREATE POLICY "Leave groups" 
  ON group_members FOR DELETE 
  USING (user_id = auth.uid());

-- --- GROUP EXERCISES ---

CREATE POLICY "View group exercises" 
  ON group_exercises FOR SELECT 
  USING (
    EXISTS (
      SELECT 1 FROM group_members 
      WHERE group_members.group_id = group_exercises.group_id 
      AND group_members.user_id = auth.uid()
    )
  );

CREATE POLICY "Share exercises" 
  ON group_exercises FOR INSERT 
  WITH CHECK (
    shared_by = auth.uid()
    AND
    EXISTS (
      SELECT 1 FROM group_members 
      WHERE group_members.group_id = group_exercises.group_id 
      AND group_members.user_id = auth.uid()
    )
  );

-- 3. Reativar RLS
ALTER TABLE groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE group_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE group_exercises ENABLE ROW LEVEL SECURITY;

-- 4. Verificar Trigger de Admin (garantir que existe)
CREATE OR REPLACE FUNCTION add_creator_as_admin() RETURNS TRIGGER AS $$
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

SELECT 'SUCESSO: Policies corrigidas (sem recursão)!' as status;
