# 🔧 Solução: Contador Mostrando 0

## Problema
Ao entrar no grupo, o contador mostra 0 membros ao invés do número correto.

## Causa Provável
1. Triggers não estão executando corretamente
2. Políticas RLS podem estar bloqueando UPDATE
3. Funções sem `SECURITY DEFINER` adequado

## Solução Completa

### PASSO 1: Diagnóstico (Opcional)
Execute `diagnose_complete.sql` para ver o estado atual.

### PASSO 2: Correção Total
Execute `fix_groups_from_scratch.sql` no Supabase SQL Editor.

Este SQL vai:
- ✅ Remover TODOS os triggers e funções antigas
- ✅ Corrigir contadores existentes com valores reais
- ✅ Criar funções novas com `SECURITY DEFINER` e logs
- ✅ Criar triggers novos
- ✅ Corrigir políticas RLS
- ✅ Mostrar verificação completa no final

### PASSO 3: Hot Restart
```bash
r
```

### PASSO 4: Teste Completo

#### Teste 1: Criar Grupo Novo
```
1. Crie um grupo chamado "Teste Contador"
2. ✅ Deve mostrar "1 Membro" imediatamente
3. Se mostrar 0, o trigger de criação não funcionou
```

#### Teste 2: Entrar no Grupo
```
1. Com outro usuário, entre no grupo "Teste Contador"
2. Aguarde 1 segundo
3. ✅ Deve mostrar "2 Membros"
4. Se mostrar 0 ou 1, o trigger de incremento não funcionou
```

#### Teste 3: Sair do Grupo
```
1. Clique em "Sair do Grupo"
2. Aguarde 1 segundo
3. ✅ Contador deve diminuir
```

### PASSO 5: Verificar no Supabase

Se ainda não funcionar, execute este SQL para ver os logs:

```sql
-- Ver contadores reais vs salvos
SELECT 
  g.name,
  g.members_count as contador_salvo,
  COUNT(gm.id) as membros_reais
FROM groups g
LEFT JOIN group_members gm ON gm.group_id = g.id
GROUP BY g.id, g.name, g.members_count;
```

Se `contador_salvo` for diferente de `membros_reais`, execute:

```sql
-- Forçar atualização manual
UPDATE groups g
SET members_count = (
  SELECT COUNT(*)
  FROM group_members gm
  WHERE gm.group_id = g.id
);
```

## O que foi corrigido no código:

### 1. SQL (fix_groups_from_scratch.sql)
- Funções com `SECURITY DEFINER` e `SET search_path = public`
- Logs com `RAISE NOTICE` para debug
- Política RLS unificada para DELETE
- Correção de contadores existentes

### 2. Dart (group_detail_screen.dart)
- Adicionado delay de 500ms após entrar/sair
- Garante que trigger execute antes de recarregar
- Recarrega grupo E verifica membership

## Logs de Debug

Após executar o SQL, você pode ver os logs no Supabase:

1. Vá em "Database" → "Logs"
2. Procure por mensagens como:
   - "Incrementando membros do grupo..."
   - "Decrementando membros do grupo..."
   - "Promovido novo admin..."

Se não aparecer nenhum log, os triggers não estão executando!

## Checklist de Verificação

Execute cada item e marque:

- [ ] SQL executado sem erros
- [ ] Triggers aparecem na verificação final
- [ ] Contadores corrigidos (real = salvo)
- [ ] Hot restart feito
- [ ] Criar grupo mostra 1 membro
- [ ] Entrar no grupo incrementa contador
- [ ] Sair do grupo decrementa contador
- [ ] Logs aparecem no Supabase

## Se AINDA não funcionar:

Execute este SQL para testar manualmente:

```sql
-- 1. Criar grupo de teste
INSERT INTO groups (name, type, created_by, is_public)
VALUES ('Teste Manual', 'outro', auth.uid(), true)
RETURNING id, name, members_count;

-- 2. Ver se criador foi adicionado
SELECT * FROM group_members 
WHERE group_id = (SELECT id FROM groups WHERE name = 'Teste Manual')
ORDER BY joined_at;

-- 3. Ver contador
SELECT name, members_count 
FROM groups 
WHERE name = 'Teste Manual';
```

Se o contador estiver correto no SQL mas errado no app, o problema é no código Dart.
Se o contador estiver errado no SQL também, o problema é nos triggers.

## Contato para Debug

Se nada funcionar, me envie o resultado destes SQLs:

```sql
-- 1. Ver triggers
SELECT trigger_name, event_manipulation 
FROM information_schema.triggers
WHERE event_object_table = 'group_members';

-- 2. Ver um grupo específico
SELECT * FROM groups WHERE name = 'destri';

-- 3. Ver membros desse grupo
SELECT * FROM group_members 
WHERE group_id = (SELECT id FROM groups WHERE name = 'destri');
```
