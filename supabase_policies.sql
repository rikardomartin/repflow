-- ============================================
-- SUPABASE RLS POLICIES
-- Execute este SQL no Supabase SQL Editor
-- ============================================

-- Habilitar RLS em todas as tabelas
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE exercises ENABLE ROW LEVEL SECURITY;
ALTER TABLE feeling_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE followers ENABLE ROW LEVEL SECURITY;
ALTER TABLE likes ENABLE ROW LEVEL SECURITY;

-- ============================================
-- POLÍTICAS PARA TABELA USERS
-- ============================================

-- Permitir que usuários criem seu próprio perfil durante o registro
CREATE POLICY "Users can insert their own profile"
ON users FOR INSERT
WITH CHECK (auth.uid() = id);

-- Permitir que usuários leiam qualquer perfil (para funcionalidade social)
CREATE POLICY "Users can view all profiles"
ON users FOR SELECT
USING (true);

-- Permitir que usuários atualizem apenas seu próprio perfil
CREATE POLICY "Users can update their own profile"
ON users FOR UPDATE
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);

-- ============================================
-- POLÍTICAS PARA TABELA EXERCISES
-- ============================================

-- Permitir que usuários criem seus próprios exercícios
CREATE POLICY "Users can insert their own exercises"
ON exercises FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- Permitir que usuários vejam exercícios públicos ou seus próprios
CREATE POLICY "Users can view public exercises or their own"
ON exercises FOR SELECT
USING (is_public = true OR auth.uid() = user_id);

-- Permitir que usuários atualizem apenas seus próprios exercícios
CREATE POLICY "Users can update their own exercises"
ON exercises FOR UPDATE
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Permitir que usuários deletem apenas seus próprios exercícios
CREATE POLICY "Users can delete their own exercises"
ON exercises FOR DELETE
USING (auth.uid() = user_id);

-- ============================================
-- POLÍTICAS PARA TABELA FEELING_LOGS
-- ============================================

-- Permitir que usuários criem seus próprios logs
CREATE POLICY "Users can insert their own feeling logs"
ON feeling_logs FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- Permitir que usuários vejam apenas seus próprios logs
CREATE POLICY "Users can view their own feeling logs"
ON feeling_logs FOR SELECT
USING (auth.uid() = user_id);

-- Permitir que usuários atualizem apenas seus próprios logs
CREATE POLICY "Users can update their own feeling logs"
ON feeling_logs FOR UPDATE
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Permitir que usuários deletem apenas seus próprios logs
CREATE POLICY "Users can delete their own feeling logs"
ON feeling_logs FOR DELETE
USING (auth.uid() = user_id);

-- ============================================
-- POLÍTICAS PARA TABELA COMMENTS
-- ============================================

-- Permitir que usuários autenticados criem comentários
CREATE POLICY "Authenticated users can insert comments"
ON comments FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- Permitir que todos vejam comentários de exercícios públicos
CREATE POLICY "Users can view comments on public exercises"
ON comments FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM exercises 
    WHERE exercises.id = comments.exercise_id 
    AND (exercises.is_public = true OR exercises.user_id = auth.uid())
  )
);

-- Permitir que usuários atualizem apenas seus próprios comentários
CREATE POLICY "Users can update their own comments"
ON comments FOR UPDATE
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Permitir que usuários deletem seus próprios comentários
CREATE POLICY "Users can delete their own comments"
ON comments FOR DELETE
USING (auth.uid() = user_id);

-- ============================================
-- POLÍTICAS PARA TABELA NOTIFICATIONS
-- ============================================

-- Sistema pode criar notificações (via trigger ou função)
CREATE POLICY "System can insert notifications"
ON notifications FOR INSERT
WITH CHECK (true);

-- Usuários podem ver apenas suas próprias notificações
CREATE POLICY "Users can view their own notifications"
ON notifications FOR SELECT
USING (auth.uid() = user_id);

-- Usuários podem atualizar apenas suas próprias notificações (marcar como lida)
CREATE POLICY "Users can update their own notifications"
ON notifications FOR UPDATE
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Usuários podem deletar suas próprias notificações
CREATE POLICY "Users can delete their own notifications"
ON notifications FOR DELETE
USING (auth.uid() = user_id);

-- ============================================
-- POLÍTICAS PARA TABELA FOLLOWERS
-- ============================================

-- Usuários podem seguir outros usuários
CREATE POLICY "Users can follow others"
ON followers FOR INSERT
WITH CHECK (auth.uid() = follower_id);

-- Todos podem ver relacionamentos de seguidores
CREATE POLICY "Users can view follower relationships"
ON followers FOR SELECT
USING (true);

-- Usuários podem deixar de seguir
CREATE POLICY "Users can unfollow"
ON followers FOR DELETE
USING (auth.uid() = follower_id);

-- ============================================
-- POLÍTICAS PARA TABELA LIKES
-- ============================================

-- Usuários podem dar like em exercícios
CREATE POLICY "Users can like exercises"
ON likes FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- Todos podem ver likes de exercícios públicos
CREATE POLICY "Users can view likes on public exercises"
ON likes FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM exercises 
    WHERE exercises.id = likes.exercise_id 
    AND (exercises.is_public = true OR exercises.user_id = auth.uid())
  )
);

-- Usuários podem remover seus próprios likes
CREATE POLICY "Users can remove their own likes"
ON likes FOR DELETE
USING (auth.uid() = user_id);

-- ============================================
-- STORAGE POLICIES (Buckets)
-- ============================================

-- Criar bucket para imagens de exercícios (se não existir)
INSERT INTO storage.buckets (id, name, public)
VALUES ('exercise-images', 'exercise-images', true)
ON CONFLICT (id) DO NOTHING;

-- Permitir upload de imagens
CREATE POLICY "Users can upload exercise images"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'exercise-images' 
  AND auth.uid()::text = (storage.foldername(name))[1]
);

-- Permitir visualização de imagens públicas
CREATE POLICY "Anyone can view exercise images"
ON storage.objects FOR SELECT
USING (bucket_id = 'exercise-images');

-- Permitir que usuários deletem suas próprias imagens
CREATE POLICY "Users can delete their own images"
ON storage.objects FOR DELETE
USING (
  bucket_id = 'exercise-images' 
  AND auth.uid()::text = (storage.foldername(name))[1]
);
