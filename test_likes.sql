-- ============================================
-- TESTAR LIKES MANUALMENTE
-- Execute este SQL no Supabase SQL Editor
-- ============================================

-- 1. Ver todos os likes
SELECT 
  l.id,
  l.exercise_id,
  l.user_id,
  e.name as exercise_name,
  e.likes_count
FROM likes l
JOIN exercises e ON l.exercise_id = e.id
ORDER BY l.timestamp DESC;

-- 2. Ver exercícios com contadores
SELECT 
  e.id,
  e.name,
  e.likes_count as contador_atual,
  COUNT(l.id) as likes_reais
FROM exercises e
LEFT JOIN likes l ON e.id = l.exercise_id
GROUP BY e.id, e.name, e.likes_count
ORDER BY e.created_at DESC;

-- 3. Testar DELETE manualmente (substitua o ID)
-- Descomente para testar:
/*
DELETE FROM likes 
WHERE exercise_id = 'SEU_EXERCISE_ID' 
  AND user_id = auth.uid();
*/

-- 4. Verificar se o trigger de decremento existe
SELECT 
  trigger_name,
  event_manipulation,
  action_statement
FROM information_schema.triggers
WHERE event_object_table = 'likes'
  AND trigger_name LIKE '%decrement%';

-- 5. Forçar recálculo de todos os contadores
UPDATE exercises e
SET likes_count = (
  SELECT COUNT(*)
  FROM likes l
  WHERE l.exercise_id = e.id
);

-- 6. Verificar resultado
SELECT 
  e.name,
  e.likes_count,
  COUNT(l.id) as likes_reais
FROM exercises e
LEFT JOIN likes l ON e.id = l.exercise_id
GROUP BY e.id, e.name, e.likes_count;
