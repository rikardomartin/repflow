-- ============================================
-- DIAGNÓSTICO COMPLETO - LIKES E STORAGE
-- Execute este SQL no Supabase SQL Editor
-- ============================================

-- 1. VERIFICAR POLÍTICAS DE LIKES
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
WHERE tablename = 'likes'
ORDER BY policyname;

-- 2. VERIFICAR TRIGGERS DE LIKES
SELECT 
  trigger_name,
  event_manipulation,
  event_object_table,
  action_statement
FROM information_schema.triggers
WHERE event_object_table = 'likes'
ORDER BY trigger_name;

-- 3. TESTAR MANUALMENTE UM LIKE (substitua os IDs)
-- Descomente e ajuste os IDs para testar:
/*
INSERT INTO likes (exercise_id, user_id)
VALUES (
  'SEU_EXERCISE_ID_AQUI',
  auth.uid()
);
*/

-- 4. VERIFICAR CONTADORES DE LIKES
SELECT 
  e.id,
  e.name,
  e.likes_count,
  COUNT(l.id) as likes_reais
FROM exercises e
LEFT JOIN likes l ON e.id = l.exercise_id
GROUP BY e.id, e.name, e.likes_count
HAVING e.likes_count != COUNT(l.id) OR e.likes_count IS NULL;

-- 5. VERIFICAR POLÍTICAS DE STORAGE
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd
FROM pg_policies 
WHERE schemaname = 'storage' AND tablename = 'objects'
ORDER BY policyname;

-- 6. VERIFICAR BUCKETS
SELECT 
  id,
  name,
  public,
  file_size_limit,
  allowed_mime_types
FROM storage.buckets
ORDER BY name;

-- 7. CORRIGIR CONTADORES DE LIKES (se necessário)
UPDATE exercises e
SET likes_count = (
  SELECT COUNT(*)
  FROM likes l
  WHERE l.exercise_id = e.id
);

-- 8. VERIFICAR RESULTADO
SELECT 
  e.id,
  e.name,
  e.likes_count,
  COUNT(l.id) as likes_reais
FROM exercises e
LEFT JOIN likes l ON e.id = l.exercise_id
GROUP BY e.id, e.name, e.likes_count;
