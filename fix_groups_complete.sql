-- ============================================
-- SISTEMA COMPLETO DE GRUPOS - CORRIGIDO
-- Execute este SQL no Supabase SQL Editor
-- ============================================

-- 1. LIMPAR TUDO E COMEÇAR DO ZERO
DROP TRIGGER IF EXISTS trigger_increment_group_members ON group_members;
DROP TRIGGER IF EXISTS trigger_decrement_group_members ON group_members;
DROP TRIGGER IF EXISTS trigger_add_creator_as_admin ON groups;
DROP TRIGGER IF EXISTS trigger_promote_next_admin ON group_members;

DROP FUNCTION IF EXISTS increment_group_members_count();
DROP FUNCTION IF EXISTS decrement_group_members_count();
DROP FUNCTION IF EXISTS add_creator_as_admin();
DROP FUNCTION IF EXISTS promote_next_admin();

-- 2. FUNÇÃO: Incrementar contador de membros
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

-- 3. FUNÇÃO: Decrementar contador e promover próximo admin se necessário
CREATE OR REPLACE FUNCTION decrement_group_members_count()
RETURNS TRIGGER AS $$
DECLARE
  remaining_members INTEGER;
  next_member_id UUID;
BEGIN
  -- Decrementar contador
  UPDATE groups
  SET members_count = GREATEST(COALESCE(members_count, 1) - 1, 0),
      updated_at = NOW()
  WHERE id = OLD.group_id;
  
  -- Se era admin que saiu, promover próximo membro
  IF OLD.role = 'admin' THEN
    -- Contar membros restantes
    SELECT COUNT(*) INTO remaining_members
    FROM group_members
    WHERE group_id = OLD.group_id;
    
    -- Se ainda tem membros, promover o mais antigo
    IF remaining_members > 0 THEN
      SELECT user_id INTO next_member_id
      FROM group_members
      WHERE group_id = OLD.group_id
      ORDER BY joined_at ASC
      LIMIT 1;
      
      -- Promover a admin
      UPDATE group_members
      SET role = 'admin'
      WHERE group_id = OLD.group_id
      AND user_id = next_member_id;
    END IF;
  END IF;
  
  RETURN OLD;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. FUNÇÃO: Adicionar criador como admin
CREATE OR REPLACE FUNCTION add_creator_as_admin()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO group_members (group_id, user_id, role)
  VALUES (NEW.id, NEW.created_by, 'admin');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 5. CRIAR TRIGGERS
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

-- 6. ADICIONAR POLÍTICAS PARA ADMIN GERENCIAR MEMBROS
DROP POLICY IF EXISTS "Admins can remove members" ON group_members;
CREATE POLICY "Admins can remove members"
  ON group_members FOR DELETE
  USING (
    auth.uid() = user_id OR -- Pode sair
    EXISTS ( -- Ou é admin
      SELECT 1 FROM group_members gm
      WHERE gm.group_id = group_members.group_id
      AND gm.user_id = auth.uid()
      AND gm.role = 'admin'
    )
  );

-- 7. CORRIGIR CONTADORES EXISTENTES
UPDATE groups g
SET members_count = (
  SELECT COUNT(*)
  FROM group_members gm
  WHERE gm.group_id = g.id
);

-- 8. VERIFICAR RESULTADO
SELECT '=== GRUPOS ===' as info;
SELECT id, name, members_count, created_by
FROM groups
ORDER BY created_at DESC;

SELECT '=== MEMBROS ===' as info;
SELECT 
  g.name as grupo,
  u.display_name as usuario,
  gm.role as funcao,
  gm.joined_at as entrou_em
FROM group_members gm
JOIN groups g ON g.id = gm.group_id
JOIN users u ON u.id = gm.user_id
ORDER BY g.name, gm.joined_at;

SELECT '=== CONTADORES ===' as info;
SELECT 
  g.name,
  g.members_count as contador,
  COUNT(gm.id) as real
FROM groups g
LEFT JOIN group_members gm ON gm.group_id = g.id
GROUP BY g.id, g.name, g.members_count;

SELECT '=== TRIGGERS ===' as info;
SELECT trigger_name, event_manipulation
FROM information_schema.triggers
WHERE event_object_table = 'group_members'
ORDER BY trigger_name;
