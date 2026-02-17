# Configuração de RLS (Row Level Security) no Supabase

## Problema
O erro `PostgrestException(message: new row violates row-level security policy for table "users", code: 42501)` ocorre porque a tabela `users` não tem uma política que permite INSERT (criação de novos usuários).

## Solução Rápida ⚡

### Execute apenas o fix (Recomendado)

1. Acesse seu projeto no [Supabase Dashboard](https://app.supabase.com)
2. Vá em **SQL Editor** no menu lateral
3. Clique em **New Query**
4. Copie todo o conteúdo do arquivo `fix_users_insert_policy.sql`
5. Cole no editor e clique em **Run**

Isso vai adicionar apenas a política que está faltando, sem afetar suas outras tabelas e dados.

## Solução Completa (Se quiser recriar tudo)

Se você quiser recriar todo o schema do zero:

1. Acesse o **SQL Editor** no Supabase
2. Copie todo o conteúdo do arquivo `SQL_SCHEMA.sql`
3. Cole e execute

⚠️ **ATENÇÃO**: Isso vai deletar TODOS os dados existentes e recriar as tabelas!

## Verificação

Após aplicar a política, teste criando uma conta novamente no app. O erro deve desaparecer.

Para verificar se a política foi aplicada corretamente, você pode executar no SQL Editor:

```sql
SELECT policyname, cmd 
FROM pg_policies 
WHERE tablename = 'users';
```

Você deve ver uma política chamada "Users can insert their own profile" com cmd = 'INSERT'.

## O que a política faz?

A política criada permite que:
- ✅ Usuários autenticados possam criar seu próprio perfil na tabela `users`
- ✅ O ID do perfil deve corresponder ao ID do usuário autenticado (segurança)
- ✅ Ninguém pode criar perfis para outros usuários

## Estrutura Completa das Políticas

Seu schema já tem as seguintes políticas configuradas:

**Tabela users:**
- ✅ INSERT: Usuários podem criar seu próprio perfil (NOVA - que você vai adicionar)
- ✅ SELECT: Todos podem ver perfis (funcionalidade social)
- ✅ UPDATE: Usuários podem atualizar apenas seu próprio perfil

**Tabela exercises:**
- ✅ SELECT: Ver exercícios próprios ou públicos
- ✅ INSERT/UPDATE/DELETE: Gerenciar apenas exercícios próprios

**Outras tabelas:**
- ✅ feeling_logs, comments, notifications, followers, likes
- ✅ Todas com políticas apropriadas já configuradas

## Próximos Passos

Depois de aplicar a política, você pode:

1. ✅ Criar uma conta no app
2. ✅ Fazer login
3. ✅ Criar exercícios
4. ✅ Testar todas as funcionalidades sociais (likes, comentários, seguidores)

