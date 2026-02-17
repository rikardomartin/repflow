# Configurar Realtime no Supabase

## Problema
Os exercícios só aparecem/desaparecem após dar F5 (refresh) porque o Realtime não está habilitado.

## Solução 1: Habilitar Realtime (Recomendado)

### Via SQL Editor:
Execute o arquivo `enable_realtime.sql` no Supabase SQL Editor.

### Via Dashboard:
1. Acesse o [Supabase Dashboard](https://app.supabase.com)
2. Vá em **Database** > **Replication**
3. Encontre a tabela **exercises**
4. Clique no toggle para habilitar o Realtime
5. Repita para outras tabelas se necessário (feeling_logs, comments, etc.)

## Solução 2: Código já implementado

O código já está preparado para usar Realtime streams. Após habilitar no Supabase, deve funcionar automaticamente.

## Verificar se funcionou

Após habilitar:
1. Crie um novo exercício
2. Deve aparecer imediatamente na lista (sem F5)
3. Delete um exercício
4. Deve desaparecer imediatamente (sem F5)

## Observação

O Supabase Realtime usa WebSockets para atualizar os dados em tempo real. No plano gratuito, há um limite de conexões simultâneas, mas para desenvolvimento é suficiente.
