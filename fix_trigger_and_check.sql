-- ============================================
-- VERIFICAR E CORRIGIR TRIGGER + CRIAR USUÁRIO MANUALMENTE
-- Execute este SQL no Supabase SQL Editor
-- ============================================

-- 1. Verificar se o trigger existe
SELECT 
  trigger_name,
  event_manipulation,
  event_object_table,
  action_statement
FROM information_schema.triggers
WHERE trigger_name = 'on_auth_user_created';

-- 2. Verificar usuários na tabela auth
SELECT id, email, raw_user_meta_data 
FROM auth.users;

-- 3. Verificar usuários na tabela users
SELECT id, display_name 
FROM public.users;

-- 4. SOLUÇÃO: Criar perfis para usuários que já existem mas não têm perfil
INSERT INTO public.users (id, display_name, created_at)
SELECT 
  au.id,
  COALESCE(au.raw_user_meta_data->>'display_name', 'Usuário'),
  NOW()
FROM auth.users au
LEFT JOIN public.users pu ON au.id = pu.id
WHERE pu.id IS NULL;

-- 5. Verificar novamente
SELECT 
  au.email,
  pu.display_name,
  CASE WHEN pu.id IS NULL THEN 'SEM PERFIL' ELSE 'OK' END as status
FROM auth.users au
LEFT JOIN public.users pu ON au.id = pu.id;
