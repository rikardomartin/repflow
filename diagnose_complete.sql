-- ============================================
-- DIAGNÓSTICO COMPLETO - GRUPOS
-- Execute este SQL no Supabase SQL Editor
-- ============================================

-- 1. Ver estrutura da tabela groups
SELECT 'ESTRUTURA DA TABELA GROUPS:' as info;
SELECT column_name, data_type, column_default
FROM information_schema.columns
WHERE table_name = 'groups'
ORDER BY ordinal_position;

-- 2. Ver todos os grupos
SELECT 'TODOS OS GRUPOS:' as info;
SELECT id, name, members_count, exercises_count, created_by, created_at
FROM groups
ORDER BY created_at DESC;

-- 3. Ver todos os membros
SELECT 'TODOS OS MEMBROS:' as info;
SELECT 
  gm.id,
  gm.group_id,
  gm.user_id,
  gm.role,
  gm.joined_at,
  u.display_name,
  g.name as group_name
FROM group_members gm
LEFT JOIN users u ON u.id = gm.user_id
LEFT JOIN groups g ON g.id = gm.group_id
ORDER BY gm.joined_at DESC;

-- 4. Contagem real vs contador
SELECT 'CONTAGEM REAL VS CONTADOR:' as info;
SELECT 
  g.id,
  g.name,
  g.members_count as contador_salvo,
  COUNT(gm.id) as membros_reais,
  CASE 
    WHEN g.members_count = COUNT(gm.id) THEN '✅ OK'
    ELSE '❌ ERRADO'
  END as status
FROM groups g
LEFT JOIN group_members gm ON gm.group_id = g.id
GROUP BY g.id, g.name, g.members_count
ORDER BY g.created_at DESC;

-- 5. Ver triggers ativos
SELECT 'TRIGGERS ATIVOS:' as info;
SELECT 
  trigger_name,
  event_manipulation,
  event_object_table,
  action_statement
FROM information_schema.triggers
WHERE event_object_table IN ('groups', 'group_members')
ORDER BY event_object_table, trigger_name;

-- 6. Ver funções
SELECT 'FUNÇÕES CRIADAS:' as info;
SELECT 
  routine_name,
  routine_type
FROM information_schema.routines
WHERE routine_schema = 'public'
AND routine_name LIKE '%group%'
ORDER BY routine_name;

-- 7. Testar trigger manualmente
SELECT 'TESTE: Vamos simular entrada de membro' as info;

-- Ver contador antes
SELECT 'ANTES:' as momento, id, name, members_count 
FROM groups 
ORDER BY created_at DESC 
LIMIT 1;

-- Simular entrada (não vai executar de verdade, só mostra o que faria)
SELECT 'Se um membro entrar, o trigger deveria incrementar members_count' as info;

-- 8. Ver políticas RLS
SELECT 'POLÍTICAS RLS:' as info;
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
WHERE tablename IN ('groups', 'group_members')
ORDER BY tablename, policyname;
