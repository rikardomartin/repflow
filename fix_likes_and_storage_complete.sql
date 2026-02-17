-- ============================================
-- CORREÇÃO COMPLETA - LIKES E STORAGE
-- Execute este SQL no Supabase SQL Editor
-- ============================================

-- ========================================
-- PARTE 1: CORRIGIR POLÍTICAS DE LIKES
-- ========================================

-- Remover políticas antigas
DROP POLICY IF EXISTS "Likes are viewable by everyone" ON likes;
DROP POLICY IF EXISTS "Users can manage own likes" ON likes;

-- Criar políticas corretas
CREATE POLICY "Anyone can view likes"
  ON likes FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Authenticated users can insert likes"
  ON likes FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own likes"
  ON likes FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);

-- ========================================
-- PARTE 2: VERIFICAR E CORRIGIR TRIGGERS
-- ========================================

-- Recriar função de incrementar likes
CREATE OR REPLACE FUNCTION increment_likes_count()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE exercises
  SET likes_count = COALESCE(likes_count, 0) + 1
  WHERE id = NEW.exercise_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Recriar função de decrementar likes
CREATE OR REPLACE FUNCTION decrement_likes_count()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE exercises
  SET likes_count = GREATEST(COALESCE(likes_count, 0) - 1, 0)
  WHERE id = OLD.exercise_id;
  RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- Remover triggers antigos
DROP TRIGGER IF EXISTS trigger_increment_likes ON likes;
DROP TRIGGER IF EXISTS trigger_decrement_likes ON likes;

-- Criar triggers novos
CREATE TRIGGER trigger_increment_likes
  AFTER INSERT ON likes
  FOR EACH ROW
  EXECUTE FUNCTION increment_likes_count();

CREATE TRIGGER trigger_decrement_likes
  AFTER DELETE ON likes
  FOR EACH ROW
  EXECUTE FUNCTION decrement_likes_count();

-- ========================================
-- PARTE 3: CORRIGIR CONTADORES EXISTENTES
-- ========================================

-- Atualizar todos os contadores de likes
UPDATE exercises e
SET likes_count = (
  SELECT COUNT(*)
  FROM likes l
  WHERE l.exercise_id = e.id
);

-- ========================================
-- PARTE 4: CORRIGIR STORAGE (PROFILE IMAGES)
-- ========================================

-- Remover políticas antigas de profile-images
DROP POLICY IF EXISTS "Users can upload profile images" ON storage.objects;
DROP POLICY IF EXISTS "Anyone can view profile images" ON storage.objects;
DROP POLICY IF EXISTS "Users can update their profile images" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete their profile images" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can upload profile images" ON storage.objects;
DROP POLICY IF EXISTS "Public can view profile images" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can update profile images" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can delete profile images" ON storage.objects;

-- Criar políticas simples e permissivas para profile-images
CREATE POLICY "Anyone can upload to profile-images"
  ON storage.objects FOR INSERT
  TO authenticated
  WITH CHECK (bucket_id = 'profile-images');

CREATE POLICY "Anyone can view profile-images"
  ON storage.objects FOR SELECT
  TO public
  USING (bucket_id = 'profile-images');

CREATE POLICY "Anyone can update profile-images"
  ON storage.objects FOR UPDATE
  TO authenticated
  USING (bucket_id = 'profile-images');

CREATE POLICY "Anyone can delete from profile-images"
  ON storage.objects FOR DELETE
  TO authenticated
  USING (bucket_id = 'profile-images');

-- ========================================
-- PARTE 5: VERIFICAÇÃO FINAL
-- ========================================

-- Verificar políticas de likes
SELECT 'LIKES POLICIES:' as info;
SELECT policyname, cmd, roles
FROM pg_policies 
WHERE tablename = 'likes'
ORDER BY policyname;

-- Verificar triggers de likes
SELECT 'LIKES TRIGGERS:' as info;
SELECT trigger_name, event_manipulation
FROM information_schema.triggers
WHERE event_object_table = 'likes';

-- Verificar contadores
SELECT 'LIKES COUNTS:' as info;
SELECT 
  e.name,
  e.likes_count as contador,
  COUNT(l.id) as likes_reais
FROM exercises e
LEFT JOIN likes l ON e.id = l.exercise_id
GROUP BY e.id, e.name, e.likes_count;

-- Verificar políticas de storage
SELECT 'STORAGE POLICIES:' as info;
SELECT policyname, cmd
FROM pg_policies 
WHERE schemaname = 'storage' 
  AND tablename = 'objects'
  AND policyname LIKE '%profile%'
ORDER BY policyname;

-- Verificar buckets
SELECT 'STORAGE BUCKETS:' as info;
SELECT id, name, public
FROM storage.buckets
ORDER BY name;
