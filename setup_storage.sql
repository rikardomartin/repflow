-- ============================================
-- CONFIGURAR STORAGE NO SUPABASE
-- Execute este SQL no Supabase SQL Editor
-- ============================================

-- 1. Criar bucket para imagens de exercícios (se não existir)
INSERT INTO storage.buckets (id, name, public)
VALUES ('exercise-images', 'exercise-images', true)
ON CONFLICT (id) DO UPDATE SET public = true;

-- 2. Criar bucket para fotos de perfil
INSERT INTO storage.buckets (id, name, public)
VALUES ('profile-images', 'profile-images', true)
ON CONFLICT (id) DO UPDATE SET public = true;

-- 3. REMOVER políticas antigas se existirem
DROP POLICY IF EXISTS "Users can upload exercise images" ON storage.objects;
DROP POLICY IF EXISTS "Anyone can view exercise images" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete their own exercise images" ON storage.objects;
DROP POLICY IF EXISTS "Users can upload profile images" ON storage.objects;
DROP POLICY IF EXISTS "Anyone can view profile images" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete their own profile images" ON storage.objects;

-- 4. Políticas para EXERCISE IMAGES

-- Permitir que usuários autenticados façam upload
CREATE POLICY "Users can upload exercise images"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'exercise-images');

-- Permitir que qualquer um veja as imagens (são públicas)
CREATE POLICY "Anyone can view exercise images"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'exercise-images');

-- Permitir que usuários atualizem suas próprias imagens
CREATE POLICY "Users can update their exercise images"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'exercise-images');

-- Permitir que usuários deletem suas próprias imagens
CREATE POLICY "Users can delete their exercise images"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'exercise-images');

-- 5. Políticas para PROFILE IMAGES

-- Permitir que usuários autenticados façam upload de foto de perfil
CREATE POLICY "Users can upload profile images"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'profile-images' 
  AND auth.uid()::text = (storage.foldername(name))[1]
);

-- Permitir que qualquer um veja fotos de perfil
CREATE POLICY "Anyone can view profile images"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'profile-images');

-- Permitir que usuários atualizem sua própria foto de perfil
CREATE POLICY "Users can update their profile images"
ON storage.objects FOR UPDATE
TO authenticated
USING (
  bucket_id = 'profile-images' 
  AND auth.uid()::text = (storage.foldername(name))[1]
);

-- Permitir que usuários deletem sua própria foto de perfil
CREATE POLICY "Users can delete their profile images"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'profile-images' 
  AND auth.uid()::text = (storage.foldername(name))[1]
);

-- 6. Verificar se as políticas foram criadas
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

-- 7. Verificar buckets
SELECT id, name, public 
FROM storage.buckets;
