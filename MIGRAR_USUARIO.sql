-- ============================================
-- MIGRAR USUÁRIO EXISTENTE
-- Execute este SQL AGORA no Supabase SQL Editor
-- ============================================

-- Este SQL copia seu usuário de auth.users para public.users
-- Assim você poderá criar exercícios!

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

-- Verificar se funcionou (deve mostrar seu usuário)
SELECT 
  id,
  display_name,
  created_at
FROM public.users;
