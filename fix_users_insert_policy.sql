-- ============================================
-- FIX: Adicionar política de INSERT para tabela users
-- Execute este SQL no Supabase SQL Editor
-- ============================================

-- Remover política antiga se existir
DROP POLICY IF EXISTS "Users can insert their own profile" ON users;

-- Criar política para permitir que usuários criem seu próprio perfil
CREATE POLICY "Users can insert their own profile"
  ON users FOR INSERT
  WITH CHECK (auth.uid() = id);

-- Verificar se funcionou
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual,
  with_check
FROM pg_policies 
WHERE tablename = 'users';
