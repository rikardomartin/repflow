# Instruções para Corrigir Likes e Upload de Foto

## Problema Identificado

1. **Likes não somam para outros usuários** - Políticas de RLS ou triggers com problema
2. **Upload de foto de perfil falha** - Políticas de storage incorretas

## Solução

### Passo 1: Execute o SQL de Correção Completa

1. Abra o [Supabase Dashboard](https://app.supabase.com)
2. Vá em **SQL Editor**
3. Copie TODO o conteúdo do arquivo `fix_likes_and_storage_complete.sql`
4. Cole e clique em **Run**
5. Aguarde a execução completa

### Passo 2: Verifique os Resultados

O SQL vai mostrar no final:
- ✅ Políticas de likes criadas
- ✅ Triggers de likes funcionando
- ✅ Contadores corrigidos
- ✅ Políticas de storage criadas
- ✅ Buckets configurados

### Passo 3: Teste no App

Após executar o SQL:

**Teste de Likes:**
1. Com usuário A, crie um exercício público
2. Faça logout
3. Entre com usuário B
4. Vá em "Explorar"
5. Abra o exercício do usuário A
6. Clique no coração (like)
7. O contador deve aumentar de 0 para 1
8. O coração deve ficar vermelho

**Teste de Foto de Perfil:**
1. Vá na aba "Perfil"
2. Clique no ícone de câmera
3. Selecione uma foto
4. Deve fazer upload com sucesso
5. A foto deve aparecer no perfil

## O que o SQL Faz

### Correção de Likes:
- Remove políticas antigas que podem estar conflitando
- Cria políticas novas e corretas:
  - Qualquer um pode VER likes
  - Usuários autenticados podem DAR like
  - Usuários podem REMOVER apenas seus próprios likes
- Recria os triggers que atualizam o contador automaticamente
- Corrige todos os contadores existentes

### Correção de Storage:
- Remove políticas antigas de profile-images
- Cria políticas simples e permissivas:
  - Usuários autenticados podem fazer upload
  - Qualquer um pode ver fotos (são públicas)
  - Usuários autenticados podem atualizar/deletar

## Se Ainda Não Funcionar

Execute o `diagnostico_completo.sql` e me envie os resultados para análise.

## Observações Importantes

- Os triggers atualizam o contador automaticamente
- Não precisa recarregar a página após dar like
- O contador deve atualizar em tempo real
- Fotos de perfil são públicas (qualquer um pode ver)
