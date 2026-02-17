# Implementação de Funcionalidades Sociais

## O que será implementado:

### 1. Sistema de Seguir Usuários ✅
- Botão "Seguir/Deixar de seguir" no perfil de outros usuários
- Lista de seguidores e seguindo
- Contadores atualizados em tempo real

### 2. Grupos/Comunidades ✅
**Tipos de grupos:**
- 🏋️ Academia
- 🏘️ Bairro
- ⚽ Time
- 📁 Outro

**Funcionalidades:**
- Criar grupo (com nome, descrição, tipo, foto)
- Entrar/sair de grupos
- Compartilhar exercícios no grupo
- Feed exclusivo do grupo
- Membros do grupo (admin, moderador, membro)
- Grupos públicos/privados

### 3. Perfil de Outros Usuários ✅
- Ver perfil completo
- Ver exercícios públicos
- Botão seguir/deixar de seguir
- Estatísticas (seguidores, seguindo, exercícios)

### 4. Feed Personalizado ✅
**3 tipos de feed:**
- 📱 **Explorar**: Todos os exercícios públicos
- 👥 **Seguindo**: Apenas de quem você segue
- 🏋️ **Grupos**: Exercícios dos seus grupos

### 5. Notificações ✅
**Tipos de notificação:**
- ❤️ Alguém reagiu ao seu exercício
- 💬 Alguém comentou no seu exercício
- 👤 Alguém começou a te seguir
- 🏋️ Novo exercício no grupo

## Estrutura de Navegação:

```
Bottom Navigation:
├── Meus Exercícios (já existe)
├── Explorar
│   ├── Tab: Todos
│   ├── Tab: Seguindo
│   └── Tab: Grupos
├── Grupos
│   ├── Meus Grupos
│   ├── Descobrir Grupos
│   └── Criar Grupo
├── Notificações (novo)
└── Perfil (já existe)
```

## Próximos Passos:

1. Execute `create_groups_and_social.sql` no Supabase
2. Implementar telas de grupos
3. Implementar sistema de seguir
4. Implementar notificações
5. Atualizar feed com filtros

## Banco de Dados:

**Novas tabelas:**
- `groups` - Grupos/comunidades
- `group_members` - Membros dos grupos
- `group_exercises` - Exercícios compartilhados nos grupos

**Tabelas atualizadas:**
- `users` - Adicionado followers_count e following_count
- `followers` - Triggers para atualizar contadores

**Triggers criados:**
- Contadores de membros do grupo
- Contadores de exercícios do grupo
- Contadores de seguidores/seguindo
- Adicionar criador como admin ao criar grupo
