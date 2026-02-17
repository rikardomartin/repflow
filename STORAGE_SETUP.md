# Configurar Storage (Upload de Imagens)

## Problema
Erro ao fazer upload: `StorageException(message: new row violates row-level security policy, statusCode: 403)`

## Solução

### Passo 1: Executar SQL
1. Acesse o [Supabase Dashboard](https://app.supabase.com)
2. Vá em **SQL Editor**
3. Copie e execute o conteúdo de `setup_storage.sql`

### Passo 2: Verificar Buckets (Opcional)
1. Vá em **Storage** no menu lateral
2. Você deve ver dois buckets:
   - `exercise-images` (para fotos de exercícios)
   - `profile-images` (para fotos de perfil)
3. Ambos devem estar marcados como **Public**

### O que foi configurado

**Buckets criados:**
- ✅ exercise-images (público)
- ✅ profile-images (público)

**Políticas de segurança:**
- ✅ Usuários autenticados podem fazer upload
- ✅ Qualquer um pode visualizar imagens (são públicas)
- ✅ Usuários podem deletar apenas suas próprias imagens
- ✅ Fotos de perfil: usuário só pode modificar a própria

### Testar

Após executar o SQL:
1. Tente criar um exercício com foto
2. A foto deve fazer upload com sucesso
3. Deve aparecer no card do exercício

## Funcionalidades Sociais

O app está sendo preparado para ser uma rede social de fitness onde usuários podem:
- ✅ Compartilhar exercícios públicos
- ✅ Ver exercícios de outros usuários
- ⏳ Comentar em exercícios
- ⏳ Dar likes
- ⏳ Seguir outros usuários
- ⏳ Receber notificações
- ⏳ Foto de perfil personalizada
