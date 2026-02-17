-- ============================================
-- SOLUÇÃO COM TRIGGER AUTOMÁTICO
-- Cria o perfil automaticamente quando um usuário se registra
-- Execute este SQL no Supabase SQL Editor
-- ============================================

-- 1. Desabilitar RLS temporariamente para INSERT (mais seguro que desabilitar tudo)
DROP POLICY IF EXISTS "Users can insert their own profile" ON users;
DROP POLICY IF EXISTS "Authenticated users can insert profiles" ON users;

-- 2. Criar função que será chamada automaticamente
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

-- 3. Criar trigger que executa após criar usuário no auth
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- 4. Manter política de SELECT e UPDATE
-- (As outras políticas já existem, só garantindo que estão lá)

-- Verificar se o trigger foi criado
SELECT 
  trigger_name,
  event_manipulation,
  event_object_table,
  action_statement
FROM information_schema.triggers
WHERE trigger_name = 'on_auth_user_created';
