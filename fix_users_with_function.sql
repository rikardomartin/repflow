-- ============================================
-- SOLUÇÃO ALTERNATIVA: Usar função para criar usuário
-- Execute este SQL no Supabase SQL Editor
-- ============================================

-- 1. Remover a política de INSERT anterior (se existir)
DROP POLICY IF EXISTS "Users can insert their own profile" ON users;

-- 2. Criar uma função que roda com privilégios de segurança
CREATE OR REPLACE FUNCTION public.create_user_profile(
  user_id UUID,
  user_display_name TEXT
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER -- Isso faz a função rodar com privilégios do owner
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.users (id, display_name, created_at)
  VALUES (user_id, user_display_name, NOW())
  ON CONFLICT (id) DO NOTHING;
END;
$$;

-- 3. Dar permissão para usuários autenticados executarem a função
GRANT EXECUTE ON FUNCTION public.create_user_profile(UUID, TEXT) TO authenticated;

-- 4. Criar política de INSERT mais permissiva
CREATE POLICY "Users can insert their own profile"
  ON users FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- 5. Verificar se funcionou
SELECT 
  schemaname,
  tablename,
  policyname,
  roles,
  cmd
FROM pg_policies 
WHERE tablename = 'users';
