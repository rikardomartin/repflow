-- ============================================
-- CORREÇÃO BLINDADA V4 - FUNÇÕES SECURITY DEFINER
-- Execute este SQL no Supabase SQL Editor
-- ============================================

-- O problema de recursão infinita acontece porque as tabelas ficam se consultando
-- mutuamente através do RLS.
-- A SOLUÇÃO DEFINITIVA é usar funções "SECURITY DEFINER" que pulam o RLS.

-- 1. LIMPEZA GERAL
ALTER TABLE groups DISABLE ROW LEVEL SECURITY;
ALTER TABLE group_members DISABLE ROW LEVEL SECURITY;
ALTER TABLE group_exercises DISABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public groups are viewable" ON groups;
DROP POLICY IF EXISTS "Members can view private groups" ON groups;
DROP POLICY IF EXISTS "Authenticated users can create groups" ON groups;
DROP POLICY IF EXISTS "Admins can update groups" ON groups;

DROP POLICY IF EXISTS "View members" ON group_members;
DROP POLICY IF EXISTS "Join groups" ON group_members;
DROP POLICY IF EXISTS "Leave groups" ON group_members;

DROP POLICY IF EXISTS "View group exercises" ON group_exercises;
DROP POLICY IF EXISTS "Share exercises" ON group_exercises;

-- 2. FUNÇÕES AUXILIARES (SECURITY DEFINER)
-- Estas funções rodam com permissão total, evitando o loop de verificação

-- Verifica se o usuário atual é membro do grupo
CREATE OR REPLACE FUNCTION public.is_member_of(_group_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
STABLE
AS $$
  SELECT EXISTS (
    SELECT 1 FROM group_members
    WHERE group_id = _group_id
    AND user_id = auth.uid()
  );
$$;

-- Verifica se o usuário atual é admin do grupo
CREATE OR REPLACE FUNCTION public.is_admin_of(_group_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
STABLE
AS $$
  SELECT EXISTS (
    SELECT 1 FROM group_members
    WHERE group_id = _group_id
    AND user_id = auth.uid()
    AND role = 'admin'
  );
$$;

-- Verifica se um grupo é público (sem ativar RLS de grupos)
CREATE OR REPLACE FUNCTION public.is_group_public_safe(_group_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
STABLE
AS $$
  SELECT is_public FROM groups WHERE id = _group_id;
$$;

-- 3. NOVAS POLICIES USANDO AS FUNÇÕES
-- Agora as policies chamam as funções acima, que não disparam RLS recursivo

-- --- GROUPS ---
CREATE POLICY "Public groups are viewable" 
  ON groups FOR SELECT 
  USING (is_public = true);

CREATE POLICY "Members can view private groups" 
  ON groups FOR SELECT 
  USING (public.is_member_of(id)); -- Usa função segura

CREATE POLICY "Authenticated users can create groups" 
  ON groups FOR INSERT 
  WITH CHECK (auth.uid() = created_by);

CREATE POLICY "Admins can update groups" 
  ON groups FOR UPDATE 
  USING (public.is_admin_of(id)); -- Usa função segura

-- --- GROUP MEMBERS ---
CREATE POLICY "View members" 
  ON group_members FOR SELECT 
  USING (
    user_id = auth.uid() OR                 -- Você mesmo
    public.is_group_public_safe(group_id) OR -- Grupo público (função segura)
    public.is_member_of(group_id)            -- Colega de grupo (função segura)
  );

CREATE POLICY "Join groups" 
  ON group_members FOR INSERT 
  WITH CHECK (
    user_id = auth.uid() -- Só entra como si mesmo
    -- Removido outras checagens complexas para evitar qualquer risco
  );

CREATE POLICY "Leave groups" 
  ON group_members FOR DELETE 
  USING (user_id = auth.uid());

-- --- GROUP EXERCISES ---
CREATE POLICY "View group exercises" 
  ON group_exercises FOR SELECT 
  USING (public.is_member_of(group_id));

CREATE POLICY "Share exercises" 
  ON group_exercises FOR INSERT 
  WITH CHECK (
    shared_by = auth.uid() AND
    public.is_member_of(group_id)
  );

-- 4. REATIVAR RLS
ALTER TABLE groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE group_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE group_exercises ENABLE ROW LEVEL SECURITY;

-- 5. TRIGGER DE ADMIN (MANTER)
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

SELECT 'SUCESSO: Correção V4 (Security Definer) aplicada!' as status;
