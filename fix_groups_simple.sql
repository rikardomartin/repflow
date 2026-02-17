-- ============================================
-- CORRIGIR POLÍTICAS DE GRUPOS - VERSÃO SIMPLES
-- Execute este SQL no Supabase SQL Editor
-- ============================================

-- 1. DESABILITAR RLS TEMPORARIAMENTE
ALTER TABLE groups DISABLE ROW LEVEL SECURITY;
ALTER TABLE group_members DISABLE ROW LEVEL SECURITY;

-- 2. REMOVER TODAS AS POLÍTICAS ANTIGAS
DROP POLICY IF EXISTS "Anyone can view public groups" ON groups;
DROP POLICY IF EXISTS "Public groups are viewable" ON groups;
DROP POLICY IF EXISTS "Members can view their private groups" ON groups;
DROP POLICY IF EXISTS "Authenticated users can create groups" ON groups;
DROP POLICY IF EXISTS "Group admins can update groups" ON groups;
DROP POLICY IF EXISTS "Group admins can delete groups" ON groups;
DROP POLICY IF EXISTS "Creator can update group" ON groups;
DROP POLICY IF EXISTS "Creator can delete group" ON groups;

DROP POLICY IF EXISTS "Group members can view members" ON group_members;
DROP POLICY IF EXISTS "Users can join public groups" ON group_members;
DROP POLICY IF EXISTS "Users can leave groups" ON group_members;

-- 3. REABILITAR RLS
ALTER TABLE groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE group_members ENABLE ROW LEVEL SECURITY;

-- 4. CRIAR POLÍTICAS SIMPLES PARA GROUPS

-- Todos podem ver todos os grupos (simplificado para teste)
CREATE POLICY "Anyone can view groups"
  ON groups FOR SELECT
  TO public
  USING (true);

-- Usuários autenticados podem criar grupos
CREATE POLICY "Users can create groups"
  ON groups FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = created_by);

-- Criador pode atualizar
CREATE POLICY "Creator can update"
  ON groups FOR UPDATE
  TO authenticated
  USING (auth.uid() = created_by);

-- Criador pode deletar
CREATE POLICY "Creator can delete"
  ON groups FOR DELETE
  TO authenticated
  USING (auth.uid() = created_by);

-- 5. CRIAR POLÍTICAS SIMPLES PARA GROUP_MEMBERS

-- Todos podem ver membros
CREATE POLICY "Anyone can view members"
  ON group_members FOR SELECT
  TO public
  USING (true);

-- Usuários podem entrar em grupos
CREATE POLICY "Users can join groups"
  ON group_members FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- Usuários podem sair
CREATE POLICY "Users can leave"
  ON group_members FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);

-- 6. VERIFICAR
SELECT 'POLÍTICAS DE GROUPS:' as info;
SELECT policyname, cmd FROM pg_policies WHERE tablename = 'groups';

SELECT 'POLÍTICAS DE GROUP_MEMBERS:' as info;
SELECT policyname, cmd FROM pg_policies WHERE tablename = 'group_members';

-- 7. TESTAR CRIAÇÃO
SELECT 'TESTE: Tente criar um grupo agora no app' as info;
