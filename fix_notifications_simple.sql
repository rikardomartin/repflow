-- ============================================
-- CORRIGIR NOTIFICAÇÕES - VERSÃO SIMPLES
-- Execute este SQL no Supabase SQL Editor
-- ============================================

-- 1. Criar tabela
CREATE TABLE IF NOT EXISTS notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  type TEXT NOT NULL CHECK (type IN ('follow', 'like', 'comment', 'group')),
  from_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  from_user_name TEXT,
  exercise_id UUID REFERENCES exercises(id) ON DELETE CASCADE,
  exercise_name TEXT,
  is_read BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Habilitar RLS
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- 3. Remover políticas antigas
DROP POLICY IF EXISTS "Users can view their notifications" ON notifications;
DROP POLICY IF EXISTS "Users can update their notifications" ON notifications;
DROP POLICY IF EXISTS "System can create notifications" ON notifications;
DROP POLICY IF EXISTS "Anyone can create notifications" ON notifications;

-- 4. Criar políticas
CREATE POLICY "Users can view their notifications"
  ON notifications FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can update their notifications"
  ON notifications FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Anyone can create notifications"
  ON notifications FOR INSERT
  WITH CHECK (true);

-- 5. Criar índices
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON notifications(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_notifications_is_read ON notifications(is_read);

-- 6. Verificar estrutura
SELECT 'COLUNAS DA TABELA:' as info;
SELECT column_name, data_type 
FROM information_schema.columns
WHERE table_name = 'notifications'
ORDER BY ordinal_position;

-- 7. Verificar políticas
SELECT 'POLÍTICAS RLS:' as info;
SELECT policyname, cmd 
FROM pg_policies 
WHERE tablename = 'notifications';

-- 8. Ver notificações existentes (se houver)
SELECT 'NOTIFICAÇÕES EXISTENTES:' as info;
SELECT COUNT(*) as total FROM notifications;

SELECT '✅ PRONTO! Agora teste seguir um usuário no app' as status;
