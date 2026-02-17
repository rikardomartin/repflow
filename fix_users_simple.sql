-- ============================================
-- SOLUÇÃO MAIS SIMPLES: Política permissiva para INSERT
-- Execute este SQL no Supabase SQL Editor
-- ============================================

-- Remover política antiga
DROP POLICY IF EXISTS "Users can insert their own profile" ON users;

-- Criar política permissiva para usuários autenticados
-- Permite que qualquer usuário autenticado insira na tabela users
CREATE POLICY "Authenticated users can insert profiles"
  ON users FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- Verificar
SELECT policyname, cmd, roles, with_check 
FROM pg_policies 
WHERE tablename = 'users' AND cmd = 'INSERT';
