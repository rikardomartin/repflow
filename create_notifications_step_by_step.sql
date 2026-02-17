-- ============================================
-- CRIAR NOTIFICAÇÕES - PASSO A PASSO
-- Execute CADA BLOCO SEPARADAMENTE no Supabase SQL Editor
-- ============================================

-- PASSO 1: Criar tabela
-- Copie e execute este bloco primeiro:

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


-- PASSO 2: Habilitar RLS
-- Copie e execute este bloco:

ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;


-- PASSO 3: Criar política de SELECT
-- Copie e execute este bloco:

DROP POLICY IF EXISTS "Users can view their notifications" ON notifications;
CREATE POLICY "Users can view their notifications"
  ON notifications FOR SELECT
  USING (auth.uid() = user_id);


-- PASSO 4: Criar política de UPDATE
-- Copie e execute este bloco:

DROP POLICY IF EXISTS "Users can update their notifications" ON notifications;
CREATE POLICY "Users can update their notifications"
  ON notifications FOR UPDATE
  USING (auth.uid() = user_id);


-- PASSO 5: Criar política de INSERT
-- Copie e execute este bloco:

DROP POLICY IF EXISTS "Anyone can create notifications" ON notifications;
CREATE POLICY "Anyone can create notifications"
  ON notifications FOR INSERT
  WITH CHECK (true);


-- PASSO 6: Criar índices
-- Copie e execute este bloco:

CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_is_read ON notifications(is_read);


-- PASSO 7: Verificar
-- Copie e execute este bloco:

SELECT 'Tabela criada com sucesso!' as status;
SELECT COUNT(*) as total_notifications FROM notifications;
