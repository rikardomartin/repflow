# Problemas Identificados e Soluções

## Problema 1: Grupos não aparecem após criação

### Causa Raiz
O campo `isPublic` estava sendo usado na query, mas o documento é salvo com `is_public` (snake_case).

### Correção Aplicada
✅ Corrigido o método `fetchPublicGroups()` para usar `is_public` em vez de `isPublic`

### Logs de Debug Adicionados
Adicionei logs detalhados em:
- `fetchUserGroups()` - para ver se os membros estão sendo encontrados
- `fetchPublicGroups()` - para ver se os grupos públicos estão sendo encontrados

### Como Testar
1. Crie um novo grupo
2. Abra o console do navegador (F12)
3. Vá para a aba "Grupos"
4. Verifique os logs que começam com "DEBUG:"
5. Os logs mostrarão:
   - Quantos grupos foram encontrados no Firestore
   - Dados dos grupos
   - Erros ao criar objetos Group (se houver)

### Possíveis Problemas Adicionais

Se ainda não aparecer, verifique:

1. **Timestamps nulos**: O modelo Group já foi ajustado para lidar com timestamps nulos
2. **Permissões do Firestore**: Verifique se as regras de segurança permitem leitura
3. **Dados corrompidos**: Verifique no Firebase Console se os documentos foram criados corretamente

## Problema 2: Upload de fotos não funciona

### Causas Possíveis

1. **Firebase Storage não configurado**
   - O bucket do Storage precisa ser criado
   - Siga as instruções em `FIREBASE_STORAGE_RULES.md`

2. **Regras de segurança bloqueando**
   - As regras padrão do Storage bloqueiam todos os uploads
   - Configure as regras conforme `FIREBASE_STORAGE_RULES.md`

3. **Erro no código**
   - Adicionei logs detalhados para identificar onde falha

### Logs de Debug Adicionados

Adicionei logs detalhados em:
- `uploadExerciseImage()` - mostra cada etapa do upload
- `uploadProfileImage()` - mostra cada etapa do upload

### Como Testar

1. Configure o Firebase Storage seguindo `FIREBASE_STORAGE_RULES.md`
2. Tente fazer upload de uma foto
3. Abra o console do navegador (F12)
4. Verifique os logs que começam com "DEBUG:"
5. Os logs mostrarão:
   - Caminho da imagem selecionada
   - Tamanho em bytes
   - Progresso do upload
   - URL de download (se sucesso)
   - Erro detalhado (se falhar)

### Passos para Configurar Storage

1. **Criar o bucket**:
   - Acesse Firebase Console > Storage
   - Clique em "Get Started"
   - Escolha localização (southamerica-east1 para Brasil)

2. **Configurar regras**:
   - Vá em Storage > Rules
   - Cole as regras de `FIREBASE_STORAGE_RULES.md`
   - Clique em "Publish"

3. **Testar**:
   - Faça login no app
   - Tente adicionar foto de perfil
   - Verifique os logs no console

## Próximos Passos

### Imediato
1. ✅ Testar criação de grupos com os logs
2. ⏳ Configurar Firebase Storage
3. ⏳ Testar upload de fotos

### Melhorias Futuras
1. Criar índices compostos no Firestore (ver `FIREBASE_INDEXES.md`)
2. Implementar regras de segurança mais restritivas
3. Adicionar validação de tamanho de imagem no frontend
4. Implementar compressão de imagens antes do upload
5. Adicionar indicador de progresso visual durante upload

## Comandos Úteis

### Ver logs em tempo real
```bash
# No console do navegador (F12), filtre por "DEBUG:"
```

### Reiniciar o app
```bash
flutter run -d chrome
```

### Limpar cache
```bash
flutter clean
flutter pub get
```

## Documentos de Referência

- `FIREBASE_INDEXES.md` - Instruções para criar índices
- `FIREBASE_STORAGE_RULES.md` - Regras de segurança do Storage
- `PROBLEMAS_E_SOLUCOES.md` - Este documento
