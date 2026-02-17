-- ============================================
-- HABILITAR REALTIME NO SUPABASE
-- Execute este SQL no Supabase SQL Editor
-- ============================================

-- Habilitar realtime para a tabela exercises
ALTER PUBLICATION supabase_realtime ADD TABLE exercises;

-- Verificar se foi habilitado
SELECT schemaname, tablename 
FROM pg_publication_tables 
WHERE pubname = 'supabase_realtime';
