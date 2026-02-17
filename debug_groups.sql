-- ============================================
-- DEBUG: Verificar estado dos grupos
-- Execute este SQL no Supabase SQL Editor
-- ============================================

-- 1. Ver todos os grupos
SELECT 'GRUPOS:' as info;
SELECT id, name, members_count, exercises_count, created_by 
FROM groups 
ORDER BY created_at DESC;

-- 2. Ver todos os membros
SELECT 'MEMBROS:' as info;
SELECT gm.id, gm.group_id, gm.user_id, gm.role, u.display_name,
       (SELECT name FROM groups WHERE id = gm.group_id) as group_name
FROM group_members gm
LEFT JOIN users u ON u.id = gm.user_id
ORDER BY gm.joined_at DESC;

-- 3. Contar membros manualmente
SELECT 'CONTAGEM MANUAL:' as info;
SELECT g.name, g.members_count as contador_atual, COUNT(gm.id) as membros_reais
FROM groups g
LEFT JOIN group_members gm ON gm.group_id = g.id
GROUP BY g.id, g.name, g.members_count;

-- 4. Verificar triggers
SELECT 'TRIGGERS:' as info;
SELECT trigger_name, event_manipulation, event_object_table
FROM information_schema.triggers
WHERE event_object_table IN ('group_members', 'groups')
ORDER BY event_object_table, trigger_name;

-- 5. Verificar funções
SELECT 'FUNÇÕES:' as info;
SELECT routine_name
FROM information_schema.routines
WHERE routine_name LIKE '%group%'
ORDER BY routine_name;
