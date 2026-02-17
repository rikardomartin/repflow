# 🔧 Corrigir Contadores de Membros

## Problema
Os contadores de membros não estão atualizando quando usuários entram no grupo.

## Solução

### Passo 1: Executar SQL de Debug
Execute o arquivo `debug_groups.sql` no Supabase SQL Editor para ver o estado atual.

### Passo 2: Executar SQL de Correção
Execute o arquivo `fix_group_counters.sql` no Supabase SQL Editor.

Este SQL vai:
1. ✅ Remover triggers antigos que podem estar com problema
2. ✅ Recriar triggers com `SECURITY DEFINER` (ignora RLS)
3. ✅ Corrigir contadores existentes com valores reais
4. ✅ Garantir que novos membros atualizem o contador

### Passo 3: Testar no App
1. Faça hot restart do app: `r` no terminal
2. Entre em um grupo com usuário 1
3. Entre no mesmo grupo com usuário 2
4. ✅ Contador deve mostrar 2 membros

## O que foi corrigido no código:

### 1. GroupDetailScreen
- Método `_reloadGroup()` agora busca grupo específico por ID
- Não depende mais de buscar todos os grupos públicos

### 2. GroupsService
- Novo método `fetchGroupById()` para buscar grupo específico
- Retorna dados atualizados diretamente do banco

### 3. Triggers SQL
- Adicionado `SECURITY DEFINER` para ignorar RLS
- Triggers agora funcionam mesmo com políticas de segurança

## Teste Completo:

```bash
# 1. Execute os SQLs no Supabase
# 2. No terminal do Flutter:
r  # hot restart

# 3. No app:
# - Usuário 1: Entre no grupo "Academia X"
# - Usuário 2: Entre no grupo "Academia X"
# - Ambos devem ver: "2 Membros"
```

## Se ainda não funcionar:

Execute este SQL para verificar:

```sql
-- Ver membros reais vs contador
SELECT g.name, g.members_count, COUNT(gm.id) as real
FROM groups g
LEFT JOIN group_members gm ON gm.group_id = g.id
GROUP BY g.id, g.name, g.members_count;
```

Se `members_count` for diferente de `real`, execute novamente:

```sql
UPDATE groups g
SET members_count = (
  SELECT COUNT(*)
  FROM group_members gm
  WHERE gm.group_id = g.id
);
```
