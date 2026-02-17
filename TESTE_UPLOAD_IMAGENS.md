# Teste de Upload de Imagens

## Problema Reportado

1. **Foto de Perfil**: Upload diz sucesso mas foto não aparece
2. **Foto do Exercício**: Foto aparece durante criação mas desaparece depois

## Como Testar

### Teste 1: Foto de Perfil

1. Faça logout e login novamente (para garantir que o documento do usuário existe)
2. Vá para "Meu Perfil"
3. Clique no ícone de câmera
4. Selecione uma foto
5. Aguarde a mensagem de sucesso
6. Abra o console do navegador (F12)
7. Procure por logs que começam com "DEBUG:"
8. Verifique:
   - Se o upload foi concluído
   - Se a URL foi retornada
   - Se o perfil foi atualizado ou criado
9. Recarregue a página (F5)
10. A foto deve aparecer

**Logs Esperados**:
```
DEBUG: Iniciando upload de foto de perfil para userId: xxx
DEBUG: Foto carregada com sucesso: https://...
DEBUG: Perfil encontrado, atualizando...
(ou)
DEBUG: Perfil não encontrado, criando novo...
DEBUG: Foto de perfil salva com sucesso
```

### Teste 2: Foto do Exercício

1. Vá para "Adicionar Exercício"
2. Clique na área de foto
3. Selecione uma foto (deve aparecer preview)
4. Preencha os campos
5. Clique em "Salvar"
6. Abra o console do navegador (F12)
7. Procure por logs que começam com "DEBUG:"
8. Verifique:
   - Se o exercício foi criado
   - Se o upload foi concluído
   - Se o exercício foi atualizado com a URL
9. Volte para a lista de exercícios
10. A foto deve aparecer

**Logs Esperados**:
```
DEBUG: Criando exercício...
DEBUG: Exercício criado com ID: xxx
DEBUG: Fazendo upload da imagem...
DEBUG: Iniciando upload de imagem do exercício
DEBUG: Upload progress: xxx/xxx
DEBUG: Upload concluído
DEBUG: URL de download: https://...
DEBUG: Imagem carregada: https://...
DEBUG: Atualizando exercício com URL da imagem...
DEBUG: Atualizando exercício xxx
DEBUG: Dados do exercício: {...}
DEBUG: Exercício atualizado no Firestore
DEBUG: Exercício atualizado com sucesso
```

## Possíveis Problemas

### Problema 1: Documento do Usuário Não Existe

**Sintoma**: Foto de perfil não aparece

**Solução**: 
1. Faça logout
2. Faça login novamente
3. O documento será criado automaticamente
4. Tente fazer upload novamente

### Problema 2: Cache do Navegador

**Sintoma**: Foto foi salva mas não aparece

**Solução**:
1. Recarregue a página (F5)
2. Ou limpe o cache (Ctrl+Shift+Delete)
3. Ou abra em aba anônima

### Problema 3: URL da Imagem Não Foi Salva

**Sintoma**: Logs mostram upload bem-sucedido mas URL não está no documento

**Solução**:
1. Verifique os logs de "Atualizando exercício"
2. Verifique se `machine_image_url` está nos dados
3. Verifique no Firebase Console se o campo foi salvo

### Problema 4: Permissões do Storage

**Sintoma**: Erro de permissão no upload

**Solução**:
1. Verifique se as regras do Storage foram publicadas
2. Verifique se o usuário está autenticado
3. Verifique se o tamanho da imagem está dentro do limite

## Verificar no Firebase Console

### Verificar Foto de Perfil

1. Acesse Firebase Console > Firestore Database
2. Vá para a coleção `users`
3. Encontre o documento do seu usuário (use o UID)
4. Verifique se o campo `profile_image_url` existe e tem uma URL
5. Copie a URL e cole no navegador
6. A imagem deve carregar

### Verificar Foto do Exercício

1. Acesse Firebase Console > Firestore Database
2. Vá para a coleção `exercises`
3. Encontre o documento do exercício
4. Verifique se o campo `machine_image_url` existe e tem uma URL
5. Copie a URL e cole no navegador
6. A imagem deve carregar

### Verificar Storage

1. Acesse Firebase Console > Storage
2. Vá para a pasta `profile_images` ou `exercise_images`
3. Verifique se os arquivos foram carregados
4. Clique em um arquivo
5. Copie a URL de download
6. Cole no navegador
7. A imagem deve carregar

## Comandos Úteis

### Ver Logs em Tempo Real
```
1. Abra o console (F12)
2. Vá para a aba "Console"
3. Filtre por "DEBUG:"
```

### Limpar Cache do Navegador
```
1. Pressione Ctrl+Shift+Delete
2. Selecione "Imagens e arquivos em cache"
3. Clique em "Limpar dados"
```

### Recarregar Página
```
F5 ou Ctrl+R
```

## Próximos Passos

Se os logs mostrarem que tudo foi salvo corretamente mas a imagem não aparece:

1. Verifique se a URL está correta no Firestore
2. Verifique se as regras de leitura do Storage permitem acesso
3. Verifique se há erro de CORS no console
4. Tente acessar a URL diretamente no navegador

## Correções Aplicadas

1. ✅ Adicionado criação automática de documento do usuário se não existir
2. ✅ Adicionados logs detalhados em todos os métodos de upload
3. ✅ Adicionados logs no método de atualização de exercício
4. ✅ Verificação de perfil existente antes de atualizar

## Teste Agora

1. Recarregue a aplicação (F5)
2. Tente fazer upload de uma foto de perfil
3. Tente criar um exercício com foto
4. Verifique os logs no console
5. Reporte os logs aqui se ainda houver problema
