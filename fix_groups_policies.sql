-- ============================================
-- CORRIGIR POLÍTICAS DE GRUPOS (Recursão Infinita)
-- Execute este SQL no Supabase SQL Editor
-- ============================================

-- Remover políticas problemáticas
DROP POLICY IF EXISTS "Anyone can view public groups" ON groups;
DROP POLICY IF EXISTS "Authenticated users can create groups" ON groups;
DROP POLICY IF EXISTS "Group admins can update groups" ON groups;
DROP POLICY IF EXISTS "Group admins can delete groups" ON groups;

-- Criar políticas mais simples (sem recursão)

-- Todos podem ver grupos públicos
CREATE POLICY "Public groups are viewable"
  ON groups FOR SELECT
  USING (is_public = true);

-- Membros podem ver grupos privados que participam
CREATE POLICY "Members can view their private groups"
  ON groups FOR SELECT
  USING (
    is_public = false 
    AND id IN (
      SELECT group_id FROM group_members WHERE user_id = auth.uid()
    )
  );

-- Usuários autenticados podem criar grupos
CREATE POLICY "Authenticated users can create groups"
  ON groups FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = created_by);

-- Criador pode atualizar grupo
CREATE POLICY "Creator can update group"
  ON groups FOR UPDATE
  USING (auth.uid() = created_by);

-- Criador pode deletar grupo
CREATE POLICY "Creator can delete group"
  ON groups FOR DELETE
  USING (auth.uid() = created_by);

-- Verificar políticas
SELECT tablename, policyname, cmd
FROM pg_policies 
WHERE tablename = 'groups'
ORDER BY policyname;
