-- ============================================
-- SOLUÇÃO RÁPIDA: Criar usuário na tabela public.users
-- Execute este SQL no Supabase SQL Editor
-- ============================================

-- Este script adiciona o trigger que estava faltando
-- Ele automaticamente cria um registro em public.users 
-- quando um usuário se registra no auth.users

-- 1. Criar função que será chamada automaticamente
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

-- 2. Criar trigger que executa após criar usuário no auth
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- 3. Para usuários que já se registraram mas não têm perfil,
-- execute este comando para criar os perfis manualmente:

INSERT INTO public.users (id, display_name, created_at)
SELECT 
  auth.users.id,
  COALESCE(auth.users.raw_user_meta_data->>'display_name', 'Usuário'),
  auth.users.created_at
FROM auth.users
WHERE NOT EXISTS (
  SELECT 1 FROM public.users WHERE public.users.id = auth.users.id
)
ON CONFLICT (id) DO NOTHING;

-- 4. Verificar se funcionou
SELECT 
  COUNT(*) as total_auth_users,
  (SELECT COUNT(*) FROM public.users) as total_public_users
FROM auth.users;

-- Se os números forem iguais, está OK!
