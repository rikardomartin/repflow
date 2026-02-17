-- ============================================
-- VERIFICAR EXERCÍCIOS SALVOS
-- Execute este SQL no Supabase SQL Editor
-- ============================================

-- Ver todos os exercícios
SELECT 
  e.id,
  e.name,
  e.training_group,
  e.instructions,
  e.is_public,
  e.created_at,
  u.display_name as user_name,
  u.id as user_id
FROM exercises e
LEFT JOIN users u ON e.user_id = u.id
ORDER BY e.created_at DESC;

-- Ver contagem de exercícios por usuário
SELECT 
  u.display_name,
  u.id,
  COUNT(e.id) as total_exercises
FROM users u
LEFT JOIN exercises e ON u.id = e.user_id
GROUP BY u.id, u.display_name;
