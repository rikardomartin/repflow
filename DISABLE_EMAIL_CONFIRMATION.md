# Como Desabilitar Confirmação de Email no Supabase

## Problema
O Supabase tem um limite de 2 emails por hora no plano gratuito. Durante o desenvolvimento, isso impede testes rápidos de cadastro.

## Solução: Desabilitar Confirmação de Email

### Passo a Passo:

1. Acesse o [Supabase Dashboard](https://app.supabase.com)
2. Selecione seu projeto
3. No menu lateral, clique em **Authentication**
4. Clique em **Providers** (ou **Email Provider**)
5. Role até encontrar **"Confirm email"** ou **"Enable email confirmations"**
6. **Desabilite** essa opção (toggle para OFF)
7. Clique em **Save** (Salvar)

### O que isso faz?

- ✅ Permite criar contas sem precisar confirmar o email
- ✅ Usuários podem fazer login imediatamente após o cadastro
- ✅ Perfeito para desenvolvimento e testes
- ⚠️ Em produção, você deve reabilitar para segurança

### Alternativa: Aguardar

Se preferir manter a confirmação de email ativada:
- Aguarde 1 hora para o rate limit resetar
- Você poderá enviar mais 2 emails de confirmação

### Após desabilitar:

1. Tente criar uma nova conta no app
2. Deve funcionar imediatamente sem precisar confirmar email
3. Você será logado automaticamente

## Observação

Como você já conseguiu fazer login com sua conta, o app está funcionando corretamente! O problema de RLS foi resolvido. Agora é só uma questão de configuração de email para facilitar os testes.
