-- ============================================
-- DESABILITAR CONFIRMAÇÃO DE EMAIL (apenas para desenvolvimento)
-- Execute este SQL no Supabase SQL Editor
-- ============================================

-- Isso permite criar contas sem precisar confirmar o email
-- ATENÇÃO: Use apenas em desenvolvimento!

-- Não há SQL direto para isso, você precisa ir em:
-- Authentication > Settings > Email Auth
-- E desabilitar "Enable email confirmations"

-- OU você pode limpar os usuários de teste:
-- CUIDADO: Isso vai deletar TODOS os usuários!

-- DELETE FROM auth.users WHERE email LIKE '%tecnicorikardo%';
