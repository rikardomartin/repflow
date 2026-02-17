# Regras de Segurança do Firebase Storage

Para que o upload de imagens funcione, você precisa configurar as regras de segurança do Firebase Storage.

## Como Configurar

1. Acesse o [Firebase Console](https://console.firebase.google.com)
2. Selecione seu projeto `repflowshow`
3. Vá em **Storage** no menu lateral
4. Clique na aba **Rules**
5. Substitua as regras existentes pelas regras abaixo
6. Clique em **Publish**

## Regras Recomendadas

```javascript
rules_version = '2';

service firebase.storage {
  match /b/{bucket}/o {
    
    // Regras para imagens de exercícios
    match /exercise_images/{imageId} {
      // Permitir leitura para todos (exercícios públicos)
      allow read: if true;
      
      // Permitir upload apenas para usuários autenticados
      allow write: if request.auth != null
                   && request.resource.size < 5 * 1024 * 1024  // Máximo 5MB
                   && request.resource.contentType.matches('image/.*');  // Apenas imagens
    }
    
    // Regras para imagens de perfil
    match /profile_images/{imageId} {
      // Permitir leitura para todos
      allow read: if true;
      
      // Permitir upload apenas para usuários autenticados
      // Idealmente, verificar se o userId no nome do arquivo corresponde ao usuário autenticado
      allow write: if request.auth != null
                   && request.resource.size < 2 * 1024 * 1024  // Máximo 2MB
                   && request.resource.contentType.matches('image/.*');  // Apenas imagens
    }
    
    // Regras para imagens de grupos (futuro)
    match /group_images/{imageId} {
      allow read: if true;
      allow write: if request.auth != null
                   && request.resource.size < 3 * 1024 * 1024
                   && request.resource.contentType.matches('image/.*');
    }
  }
}
```

## Regras Mais Restritivas (Produção)

Para produção, você pode usar regras mais restritivas que verificam se o usuário é o dono do recurso:

```javascript
rules_version = '2';

service firebase.storage {
  match /b/{bucket}/o {
    
    // Função auxiliar para extrair userId do nome do arquivo
    function getUserIdFromFilename(filename) {
      return filename.split('_')[0];
    }
    
    // Regras para imagens de exercícios
    match /exercise_images/{imageId} {
      allow read: if true;
      
      // Verificar se o exercício pertence ao usuário
      allow write: if request.auth != null
                   && request.resource.size < 5 * 1024 * 1024
                   && request.resource.contentType.matches('image/.*');
      
      // Permitir deletar apenas se for o dono
      allow delete: if request.auth != null;
    }
    
    // Regras para imagens de perfil
    match /profile_images/{imageId} {
      allow read: if true;
      
      // Verificar se o userId no nome do arquivo corresponde ao usuário autenticado
      allow write: if request.auth != null
                   && getUserIdFromFilename(imageId) == request.auth.uid
                   && request.resource.size < 2 * 1024 * 1024
                   && request.resource.contentType.matches('image/.*');
      
      allow delete: if request.auth != null
                    && getUserIdFromFilename(imageId) == request.auth.uid;
    }
  }
}
```

## Verificar se as Regras Estão Ativas

Após publicar as regras:

1. Tente fazer upload de uma imagem no app
2. Verifique o console do navegador (F12) para ver os logs de debug
3. Se houver erro de permissão, verifique se as regras foram publicadas corretamente

## Criar o Bucket do Storage

Se o Storage ainda não foi inicializado:

1. Acesse o [Firebase Console](https://console.firebase.google.com)
2. Selecione seu projeto `repflowshow`
3. Vá em **Storage** no menu lateral
4. Clique em **Get Started**
5. Escolha a localização (recomendado: us-central1 ou southamerica-east1 para Brasil)
6. Clique em **Done**

## Testar Upload

Após configurar as regras, teste:

1. Faça login no app
2. Tente adicionar uma foto de perfil
3. Tente criar um exercício com imagem
4. Verifique os logs no console do navegador (F12)
5. Verifique se as imagens aparecem no Firebase Console > Storage

## Troubleshooting

### Erro: "Firebase Storage: User does not have permission"
- Verifique se as regras foram publicadas
- Verifique se o usuário está autenticado
- Verifique se o bucket do Storage foi criado

### Erro: "Firebase Storage: Object does not exist"
- Verifique se o caminho do arquivo está correto
- Verifique se o upload foi concluído antes de tentar acessar

### Imagem não carrega após upload
- Verifique se a URL de download foi retornada corretamente
- Verifique se as regras de leitura permitem acesso público
- Verifique o console do navegador para erros de CORS
