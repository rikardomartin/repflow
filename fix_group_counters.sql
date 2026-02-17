-- ============================================
-- CORRIGIR CONTADORES DE GRUPOS
-- Execute este SQL no Supabase SQL Editor
-- ============================================

-- 1. REMOVER TRIGGERS ANTIGOS
DROP TRIGGER IF EXISTS trigger_increment_group_members ON group_members;
DROP TRIGGER IF EXISTS trigger_decrement_group_members ON group_members;
DROP TRIGGER IF EXISTS trigger_add_creator_as_admin ON groups;

-- 2. REMOVER FUNÇÕES ANTIGAS
DROP FUNCTION IF EXISTS increment_group_members_count();
DROP FUNCTION IF EXISTS decrement_group_members_count();
DROP FUNCTION IF EXISTS add_creator_as_admin();

-- 3. CRIAR FUNÇÃO PARA INCREMENTAR MEMBROS
CREATE OR REPLACE FUNCTION increment_group_members_count()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE groups
  SET members_count = COALESCE(members_count, 0) + 1,
      updated_at = NOW()
  WHERE id = NEW.group_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. CRIAR FUNÇÃO PARA DECREMENTAR MEMBROS
CREATE OR REPLACE FUNCTION decrement_group_members_count()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE groups
  SET members_count = GREATEST(COALESCE(members_count, 1) - 1, 0),
      updated_at = NOW()
  WHERE id = OLD.group_id;
  RETURN OLD;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 5. CRIAR FUNÇÃO PARA ADICIONAR CRIADOR COMO ADMIN
CREATE OR REPLACE FUNCTION add_creator_as_admin()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO group_members (group_id, user_id, role)
  VALUES (NEW.id, NEW.created_by, 'admin');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 6. CRIAR TRIGGERS
CREATE TRIGGER trigger_increment_group_members
  AFTER INSERT ON group_members
  FOR EACH ROW
  EXECUTE FUNCTION increment_group_members_count();

CREATE TRIGGER trigger_decrement_group_members
  AFTER DELETE ON group_members
  FOR EACH ROW
  EXECUTE FUNCTION decrement_group_members_count();

CREATE TRIGGER trigger_add_creator_as_admin
  AFTER INSERT ON groups
  FOR EACH ROW
  EXECUTE FUNCTION add_creator_as_admin();

-- 7. CORRIGIR CONTADORES EXISTENTES (atualizar com valores reais)
UPDATE groups g
SET members_count = (
  SELECT COUNT(*)
  FROM group_members gm
  WHERE gm.group_id = g.id
);

-- 8. VERIFICAR RESULTADO
SELECT 'CONTADORES CORRIGIDOS:' as info;
SELECT g.name, g.members_count, COUNT(gm.id) as membros_reais
FROM groups g
LEFT JOIN group_members gm ON gm.group_id = g.id
GROUP BY g.id, g.name, g.members_count;

SELECT 'TRIGGERS CRIADOS:' as info;
SELECT trigger_name, event_manipulation, event_object_table
FROM information_schema.triggers
WHERE event_object_table = 'group_members'
ORDER BY trigger_name;
