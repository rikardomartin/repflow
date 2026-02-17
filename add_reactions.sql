-- ============================================
-- ADICIONAR SISTEMA DE REAÇÕES
-- Execute este SQL no Supabase SQL Editor
-- ============================================

-- 1. Adicionar coluna de tipo de reação na tabela likes
ALTER TABLE likes 
ADD COLUMN IF NOT EXISTS reaction_type TEXT DEFAULT 'like' 
CHECK (reaction_type IN ('like', 'valeu', 'amen'));

-- 2. Remover constraint UNIQUE antiga (exercise_id, user_id)
ALTER TABLE likes 
DROP CONSTRAINT IF EXISTS likes_exercise_id_user_id_key;

-- 3. Adicionar nova constraint UNIQUE (exercise_id, user_id, reaction_type)
-- Permite que um usuário dê múltiplas reações diferentes no mesmo exercício
ALTER TABLE likes 
ADD CONSTRAINT likes_exercise_id_user_id_reaction_key 
UNIQUE (exercise_id, user_id, reaction_type);

-- 4. Adicionar colunas de contadores na tabela exercises
ALTER TABLE exercises 
ADD COLUMN IF NOT EXISTS valeu_count INTEGER DEFAULT 0;

ALTER TABLE exercises 
ADD COLUMN IF NOT EXISTS amen_count INTEGER DEFAULT 0;

-- 5. Criar função para incrementar contadores por tipo
CREATE OR REPLACE FUNCTION increment_reaction_count()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.reaction_type = 'like' THEN
    UPDATE exercises
    SET likes_count = COALESCE(likes_count, 0) + 1
    WHERE id = NEW.exercise_id;
  ELSIF NEW.reaction_type = 'valeu' THEN
    UPDATE exercises
    SET valeu_count = COALESCE(valeu_count, 0) + 1
    WHERE id = NEW.exercise_id;
  ELSIF NEW.reaction_type = 'amen' THEN
    UPDATE exercises
    SET amen_count = COALESCE(amen_count, 0) + 1
    WHERE id = NEW.exercise_id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 6. Criar função para decrementar contadores por tipo
CREATE OR REPLACE FUNCTION decrement_reaction_count()
RETURNS TRIGGER AS $$
BEGIN
  IF OLD.reaction_type = 'like' THEN
    UPDATE exercises
    SET likes_count = GREATEST(COALESCE(likes_count, 0) - 1, 0)
    WHERE id = OLD.exercise_id;
  ELSIF OLD.reaction_type = 'valeu' THEN
    UPDATE exercises
    SET valeu_count = GREATEST(COALESCE(valeu_count, 0) - 1, 0)
    WHERE id = OLD.exercise_id;
  ELSIF OLD.reaction_type = 'amen' THEN
    UPDATE exercises
    SET amen_count = GREATEST(COALESCE(amen_count, 0) - 1, 0)
    WHERE id = OLD.exercise_id;
  END IF;
  RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- 7. Recriar triggers
DROP TRIGGER IF EXISTS trigger_increment_likes ON likes;
DROP TRIGGER IF EXISTS trigger_decrement_likes ON likes;

CREATE TRIGGER trigger_increment_likes
  AFTER INSERT ON likes
  FOR EACH ROW
  EXECUTE FUNCTION increment_reaction_count();

CREATE TRIGGER trigger_decrement_likes
  AFTER DELETE ON likes
  FOR EACH ROW
  EXECUTE FUNCTION decrement_reaction_count();

-- 8. Recalcular todos os contadores
UPDATE exercises e
SET 
  likes_count = (SELECT COUNT(*) FROM likes WHERE exercise_id = e.id AND reaction_type = 'like'),
  valeu_count = (SELECT COUNT(*) FROM likes WHERE exercise_id = e.id AND reaction_type = 'valeu'),
  amen_count = (SELECT COUNT(*) FROM likes WHERE exercise_id = e.id AND reaction_type = 'amen');

-- 9. Verificar resultado
SELECT 
  e.name,
  e.likes_count,
  e.valeu_count,
  e.amen_count,
  COUNT(CASE WHEN l.reaction_type = 'like' THEN 1 END) as likes_reais,
  COUNT(CASE WHEN l.reaction_type = 'valeu' THEN 1 END) as valeu_reais,
  COUNT(CASE WHEN l.reaction_type = 'amen' THEN 1 END) as amen_reais
FROM exercises e
LEFT JOIN likes l ON e.id = l.exercise_id
GROUP BY e.id, e.name, e.likes_count, e.valeu_count, e.amen_count;
