-- ============================================
-- VERIFICAR E CORRIGIR NOTIFICAÇÕES
-- Execute este SQL no Supabase SQL Editor
-- ============================================

-- 1. Verificar se a tabela existe
SELECT 'TABELA NOTIFICATIONS:' as info;
SELECT EXISTS (
  SELECT FROM information_schema.tables 
  WHERE table_schema = 'public' 
  AND table_name = 'notifications'
) as existe;

-- 2. Criar tabela se não existir
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

-- 3. Ver estrutura da tabela
SELECT 'ESTRUTURA:' as info;
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'notifications'
ORDER BY ordinal_position;

-- 4. Habilitar RLS
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- 5. Remover políticas antigas
DROP POLICY IF EXISTS "Users can view their notifications" ON notifications;
DROP POLICY IF EXISTS "Users can update their notifications" ON notifications;
DROP POLICY IF EXISTS "System can create notifications" ON notifications;
DROP POLICY IF EXISTS "Anyone can create notifications" ON notifications;

-- 6. Criar políticas novas
CREATE POLICY "Users can view their notifications"
  ON notifications FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can update their notifications"
  ON notifications FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Anyone can create notifications"
  ON notifications FOR INSERT
  WITH CHECK (true);

-- 7. Criar índices
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON notifications(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_notifications_is_read ON notifications(is_read);

-- 8. Ver todas as notificações existentes
SELECT 'TODAS AS NOTIFICAÇÕES:' as info;
SELECT * FROM notifications
ORDER BY created_at DESC
LIMIT 10;

-- 9. Ver políticas RLS
SELECT 'POLÍTICAS RLS:' as info;
SELECT policyname, cmd, qual
FROM pg_policies
WHERE tablename = 'notifications';

-- 10. Verificar se RLS está ativo
SELECT 'RLS ATIVO:' as info;
SELECT tablename, rowsecurity
FROM pg_tables
WHERE tablename = 'notifications';

-- 11. TESTE: Criar notificação manualmente
SELECT 'TESTE: Criando notificação de teste...' as info;

-- Pegar dois usuários para teste
DO $$
DECLARE
  user1_id UUID;
  user2_id UUID;
  user1_name TEXT;
BEGIN
  -- Pegar primeiro usuário
  SELECT id, display_name INTO user1_id, user1_name
  FROM users
  ORDER BY created_at
  LIMIT 1;
  
  -- Pegar segundo usuário
  SELECT id INTO user2_id
  FROM users
  WHERE id != user1_id
  ORDER BY created_at
  LIMIT 1;
  
  -- Criar notificação de teste
  IF user1_id IS NOT NULL AND user2_id IS NOT NULL THEN
    INSERT INTO notifications (user_id, type, from_user_id, from_user_name)
    VALUES (user2_id, 'follow', user1_id, user1_name);
    
    RAISE NOTICE 'Notificação de teste criada: % seguiu %', user1_name, user2_id;
  END IF;
END $$;

-- 12. Verificar resultado
SELECT 'NOTIFICAÇÕES APÓS TESTE:' as info;
SELECT 
  n.id,
  n.type,
  n.from_user_name,
  u.display_name as para_usuario,
  n.is_read,
  n.created_at
FROM notifications n
JOIN users u ON u.id = n.user_id
ORDER BY n.created_at DESC
LIMIT 10;

SELECT '========================================' as info;
SELECT '✅ VERIFICAÇÃO COMPLETA!' as info;
SELECT '========================================' as info;
