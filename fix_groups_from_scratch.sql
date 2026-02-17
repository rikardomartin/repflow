-- ============================================
-- CORRIGIR GRUPOS DO ZERO - VERSÃO DEFINITIVA
-- Execute este SQL no Supabase SQL Editor
-- ============================================

-- PASSO 1: LIMPAR TUDO
-- ============================================

-- Remover todos os triggers
DROP TRIGGER IF EXISTS trigger_increment_group_members ON group_members CASCADE;
DROP TRIGGER IF EXISTS trigger_decrement_group_members ON group_members CASCADE;
DROP TRIGGER IF EXISTS trigger_add_creator_as_admin ON groups CASCADE;
DROP TRIGGER IF EXISTS trigger_increment_group_exercises ON group_exercises CASCADE;
DROP TRIGGER IF EXISTS trigger_decrement_group_exercises ON group_exercises CASCADE;

-- Remover todas as funções
DROP FUNCTION IF EXISTS increment_group_members_count() CASCADE;
DROP FUNCTION IF EXISTS decrement_group_members_count() CASCADE;
DROP FUNCTION IF EXISTS add_creator_as_admin() CASCADE;
DROP FUNCTION IF EXISTS increment_group_exercises_count() CASCADE;
DROP FUNCTION IF EXISTS decrement_group_exercises_count() CASCADE;

-- PASSO 2: CORRIGIR CONTADORES EXISTENTES
-- ============================================

-- Atualizar members_count com valores reais
UPDATE groups g
SET members_count = (
  SELECT COALESCE(COUNT(*), 0)
  FROM group_members gm
  WHERE gm.group_id = g.id
);

-- Atualizar exercises_count com valores reais
UPDATE groups g
SET exercises_count = (
  SELECT COALESCE(COUNT(*), 0)
  FROM group_exercises ge
  WHERE ge.group_id = g.id
);

-- PASSO 3: CRIAR FUNÇÕES NOVAS
-- ============================================

-- Função: Incrementar membros
CREATE OR REPLACE FUNCTION increment_group_members_count()
RETURNS TRIGGER 
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
BEGIN
  -- Log para debug
  RAISE NOTICE 'Incrementando membros do grupo %', NEW.group_id;
  
  -- Atualizar contador
  UPDATE groups
  SET 
    members_count = COALESCE(members_count, 0) + 1,
    updated_at = NOW()
  WHERE id = NEW.group_id;
  
  RETURN NEW;
END;
$$;

-- Função: Decrementar membros e promover admin
CREATE OR REPLACE FUNCTION decrement_group_members_count()
RETURNS TRIGGER 
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
  remaining_count INTEGER;
  next_admin_id UUID;
BEGIN
  -- Log para debug
  RAISE NOTICE 'Decrementando membros do grupo %', OLD.group_id;
  
  -- Atualizar contador
  UPDATE groups
  SET 
    members_count = GREATEST(COALESCE(members_count, 1) - 1, 0),
    updated_at = NOW()
  WHERE id = OLD.group_id;
  
  -- Se era admin que saiu, promover próximo
  IF OLD.role = 'admin' THEN
    -- Contar membros restantes
    SELECT COUNT(*) INTO remaining_count
    FROM group_members
    WHERE group_id = OLD.group_id;
    
    -- Se ainda tem membros, promover o mais antigo
    IF remaining_count > 0 THEN
      SELECT user_id INTO next_admin_id
      FROM group_members
      WHERE group_id = OLD.group_id
      ORDER BY joined_at ASC
      LIMIT 1;
      
      -- Promover a admin
      IF next_admin_id IS NOT NULL THEN
        UPDATE group_members
        SET role = 'admin'
        WHERE group_id = OLD.group_id
        AND user_id = next_admin_id;
        
        RAISE NOTICE 'Promovido novo admin: %', next_admin_id;
      END IF;
    END IF;
  END IF;
  
  RETURN OLD;
END;
$$;

-- Função: Adicionar criador como admin
CREATE OR REPLACE FUNCTION add_creator_as_admin()
RETURNS TRIGGER 
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
BEGIN
  -- Log para debug
  RAISE NOTICE 'Adicionando criador % como admin do grupo %', NEW.created_by, NEW.id;
  
  -- Inserir criador como admin
  INSERT INTO group_members (group_id, user_id, role)
  VALUES (NEW.id, NEW.created_by, 'admin');
  
  RETURN NEW;
END;
$$;

-- Função: Incrementar exercícios
CREATE OR REPLACE FUNCTION increment_group_exercises_count()
RETURNS TRIGGER 
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
BEGIN
  UPDATE groups
  SET 
    exercises_count = COALESCE(exercises_count, 0) + 1,
    updated_at = NOW()
  WHERE id = NEW.group_id;
  
  RETURN NEW;
END;
$$;

-- Função: Decrementar exercícios
CREATE OR REPLACE FUNCTION decrement_group_exercises_count()
RETURNS TRIGGER 
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
BEGIN
  UPDATE groups
  SET 
    exercises_count = GREATEST(COALESCE(exercises_count, 1) - 1, 0),
    updated_at = NOW()
  WHERE id = OLD.group_id;
  
  RETURN OLD;
END;
$$;

-- PASSO 4: CRIAR TRIGGERS
-- ============================================

-- Trigger: Incrementar membros
CREATE TRIGGER trigger_increment_group_members
  AFTER INSERT ON group_members
  FOR EACH ROW
  EXECUTE FUNCTION increment_group_members_count();

-- Trigger: Decrementar membros
CREATE TRIGGER trigger_decrement_group_members
  AFTER DELETE ON group_members
  FOR EACH ROW
  EXECUTE FUNCTION decrement_group_members_count();

-- Trigger: Adicionar criador como admin
CREATE TRIGGER trigger_add_creator_as_admin
  AFTER INSERT ON groups
  FOR EACH ROW
  EXECUTE FUNCTION add_creator_as_admin();

-- Trigger: Incrementar exercícios
CREATE TRIGGER trigger_increment_group_exercises
  AFTER INSERT ON group_exercises
  FOR EACH ROW
  EXECUTE FUNCTION increment_group_exercises_count();

-- Trigger: Decrementar exercícios
CREATE TRIGGER trigger_decrement_group_exercises
  AFTER DELETE ON group_exercises
  FOR EACH ROW
  EXECUTE FUNCTION decrement_group_exercises_count();

-- PASSO 5: GARANTIR POLÍTICAS RLS CORRETAS
-- ============================================

-- Remover política antiga de delete
DROP POLICY IF EXISTS "Users can leave" ON group_members;
DROP POLICY IF EXISTS "Users can leave groups" ON group_members;
DROP POLICY IF EXISTS "Admins can remove members" ON group_members;

-- Criar política unificada de delete
CREATE POLICY "Users can leave or admins can remove"
  ON group_members FOR DELETE
  USING (
    -- Pode sair do próprio grupo
    auth.uid() = user_id 
    OR 
    -- Ou é admin do grupo
    EXISTS (
      SELECT 1 FROM group_members gm
      WHERE gm.group_id = group_members.group_id
      AND gm.user_id = auth.uid()
      AND gm.role = 'admin'
    )
  );

-- PASSO 6: VERIFICAÇÃO FINAL
-- ============================================

SELECT '========================================' as info;
SELECT '✅ CORREÇÃO COMPLETA!' as info;
SELECT '========================================' as info;

SELECT 'GRUPOS:' as info;
SELECT id, name, members_count, exercises_count
FROM groups
ORDER BY created_at DESC;

SELECT 'MEMBROS:' as info;
SELECT 
  g.name as grupo,
  u.display_name as usuario,
  gm.role as funcao,
  gm.joined_at
FROM group_members gm
JOIN groups g ON g.id = gm.group_id
JOIN users u ON u.id = gm.user_id
ORDER BY g.name, gm.joined_at;

SELECT 'CONTADORES:' as info;
SELECT 
  g.name,
  g.members_count as contador,
  COUNT(gm.id) as real,
  CASE 
    WHEN g.members_count = COUNT(gm.id) THEN '✅ OK'
    ELSE '❌ DIFERENTE'
  END as status
FROM groups g
LEFT JOIN group_members gm ON gm.group_id = g.id
GROUP BY g.id, g.name, g.members_count;

SELECT 'TRIGGERS:' as info;
SELECT trigger_name, event_manipulation, event_object_table
FROM information_schema.triggers
WHERE event_object_table IN ('groups', 'group_members')
ORDER BY event_object_table, trigger_name;

SELECT '========================================' as info;
SELECT '🎯 AGORA TESTE NO APP!' as info;
SELECT '========================================' as info;
