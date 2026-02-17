-- ============================================
-- CORRIGIR POLÍTICAS DE STORAGE PARA FOTOS DE PERFIL
-- Execute este SQL no Supabase SQL Editor
-- ============================================

-- Remover políticas antigas
DROP POLICY IF EXISTS "Users can upload profile images" ON storage.objects;
DROP POLICY IF EXISTS "Anyone can view profile images" ON storage.objects;
DROP POLICY IF EXISTS "Users can update their profile images" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete their profile images" ON storage.objects;

-- Criar políticas mais permissivas para profile-images

-- Permitir que usuários autenticados façam upload
CREATE POLICY "Authenticated users can upload profile images"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'profile-images');

-- Permitir que qualquer um veja fotos de perfil
CREATE POLICY "Public can view profile images"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'profile-images');

-- Permitir que usuários atualizem fotos no bucket
CREATE POLICY "Authenticated users can update profile images"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'profile-images');

-- Permitir que usuários deletem fotos no bucket
CREATE POLICY "Authenticated users can delete profile images"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'profile-images');

-- Verificar políticas
SELECT policyname, cmd, roles
FROM pg_policies 
WHERE schemaname = 'storage' 
  AND tablename = 'objects'
  AND policyname LIKE '%profile%'
ORDER BY policyname;
