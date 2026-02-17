# 🧪 Teste 03 - Perfil e Funcionalidades Sociais

## ✅ O que já está implementado:

### Perfil
- ✅ Visualização de perfil próprio
- ✅ Foto de perfil
- ✅ Nome e email
- ✅ Estatísticas (exercícios, públicos, privados)
- ✅ Upload de foto de perfil
- ✅ Tela de edição de perfil

### Social
- ✅ Feed de exercícios públicos
- ✅ Sistema de reações (Like, Valeu, Amém)
- ✅ Comentários
- ✅ Visualizar perfil de outros usuários

---

## 🧪 ROTEIRO DE TESTES

### Teste 3.1: Visualizar Próprio Perfil

**Passos:**
1. Na barra inferior, clique na aba **"Perfil"** (ícone de pessoa)
2. Observe as informações exibidas

**Resultado Esperado:**
- ✅ Foto de perfil ou iniciais aparecem
- ✅ Nome do usuário exibido
- ✅ Email exibido
- ✅ Estatísticas corretas:
  - Total de exercícios
  - Exercícios públicos
  - Exercícios privados

**Verificar:**
- [ok ] Foto/iniciais aparecem?
- [ok ] Nome está correto?
- [ok ] Estatísticas batem com os exercícios criados?

---

### Teste 3.2: Alterar Foto de Perfil

**Passos:**
1. Na tela de perfil, clique no **ícone de câmera** sobre a foto
2. Selecione uma imagem da galeria
3. Aguarde o upload

**Resultado Esperado:**
- ✅ Loading aparece durante upload
- ✅ Foto é atualizada
- ✅ Mensagem "Foto de perfil atualizada!"
- ✅ Nova foto aparece imediatamente

**Verificar:**
- [ ] Upload funcionou?
- [ ] Foto aparece corretamente?
- [ ] Mensagem de sucesso apareceu?

---

### Teste 3.3: Editar Perfil (se implementado)

**Passos:**
1. Na tela de perfil, procure por "Editar Perfil"
2. Clique para editar
3. Tente alterar nome ou bio

**Resultado Esperado:**
- ✅ Tela de edição abre
- ✅ Campos preenchidos com dados atuais
- ✅ Consegue salvar alterações

**Verificar:**
- [ ] Tela de edição existe?
- [ ] Consegue alterar dados?
- [ ] Alterações são salvas?

---

### Teste 3.4: Feed de Exercícios Públicos

**Passos:**
1. Na barra inferior, clique na aba **"Explorar"** (ícone de bússola)
2. Observe os exercícios listados

**Resultado Esperado:**
- ✅ Apenas exercícios PÚBLICOS aparecem
- ✅ Exercícios de todos os usuários (não só seus)
- ✅ Mostra foto, nome, instruções
- ✅ Mostra nome do autor

**Verificar:**
- [ ] Feed carrega?
- [ ] Mostra exercícios públicos?
- [ ] Seus exercícios públicos aparecem?
- [ ] Exercícios de outros usuários aparecem (se houver)?

---

### Teste 3.5: Reações em Exercícios Públicos

**Passos:**
1. No feed, clique em um exercício público
2. Na tela de detalhes, teste as reações:
   - Clique no ❤️ (Like)
   - Clique no 👍 (Valeu)
   - Clique no 🙏 (Amém)
3. Clique novamente para remover

**Resultado Esperado:**
- ✅ Contador aumenta ao clicar
- ✅ Botão fica destacado (azul)
- ✅ Contador diminui ao remover
- ✅ Botão volta ao normal
- ✅ Mudanças são salvas

**Verificar:**
- [ ] Like funciona?
- [ ] Valeu funciona?
- [ ] Amém funciona?
- [ ] Toggle on/off funciona?
- [ ] Contadores atualizam?

---

### Teste 3.6: Comentários

**Passos:**
1. Em um exercício público, role até a seção de comentários
2. Digite um comentário: "Ótimo exercício!"
3. Envie
4. Verifique se aparece na lista

**Resultado Esperado:**
- ✅ Campo de comentário visível
- ✅ Comentário é enviado
- ✅ Aparece na lista imediatamente
- ✅ Mostra seu nome e foto
- ✅ Mostra timestamp

**Verificar:**
- [ ] Consegue comentar?
- [ ] Comentário aparece?
- [ ] Nome e foto corretos?
- [ ] Timestamp aparece?

---

### Teste 3.7: Visualizar Comentários de Outros

**Passos:**
1. Se houver comentários de outros usuários, verifique
2. Observe as informações exibidas

**Resultado Esperado:**
- ✅ Comentários de outros aparecem
- ✅ Nome do autor visível
- ✅ Foto do autor visível
- ✅ Timestamp correto

**Verificar:**
- [ ] Comentários de outros aparecem?
- [ ] Informações corretas?

---

### Teste 3.8: Excluir Próprio Comentário (se implementado)

**Passos:**
1. Em um comentário seu, procure opção de excluir
2. Tente excluir

**Resultado Esperado:**
- ✅ Opção de excluir disponível
- ✅ Confirmação antes de excluir
- ✅ Comentário é removido

**Verificar:**
- [ ] Consegue excluir?
- [ ] Pede confirmação?
- [ ] Remove da lista?

---

### Teste 3.9: Feeling Logs (Notas Pessoais)

**Passos:**
1. Abra um exercício SEU
2. Role até "Como estou me sentindo"
3. Adicione uma nota: "3x12 com 60kg, treino pesado"
4. Envie
5. Adicione mais 2-3 notas

**Resultado Esperado:**
- ✅ Nota é salva
- ✅ Aparece na lista
- ✅ Mostra timestamp relativo ("Há 1 min", "Hoje às 14:30")
- ✅ Lista em ordem cronológica (mais recente primeiro)

**Verificar:**
- [ ] Notas são salvas?
- [ ] Aparecem na lista?
- [ ] Timestamp correto?
- [ ] Ordem correta?

---

### Teste 3.10: Visualizar Perfil de Outro Usuário (se implementado)

**Passos:**
1. No feed, clique no nome de outro usuário
2. Observe o perfil dele

**Resultado Esperado:**
- ✅ Abre perfil do usuário
- ✅ Mostra foto e nome
- ✅ Mostra exercícios públicos dele
- ✅ Mostra estatísticas

**Verificar:**
- [ ] Consegue ver perfil de outros?
- [ ] Informações corretas?
- [ ] Mostra apenas exercícios públicos?

---

### Teste 3.11: Seguir/Deixar de Seguir (se implementado)

**Passos:**
1. No perfil de outro usuário, procure botão "Seguir"
2. Clique para seguir
3. Clique novamente para deixar de seguir

**Resultado Esperado:**
- ✅ Botão "Seguir" disponível
- ✅ Muda para "Seguindo" após clicar
- ✅ Contador de seguidores atualiza
- ✅ Pode deixar de seguir

**Verificar:**
- [ ] Funcionalidade existe?
- [ ] Consegue seguir?
- [ ] Contadores atualizam?
- [ ] Consegue deixar de seguir?

---

## 🐛 PROBLEMAS ENCONTRADOS

### Problema 1:
**Descrição:**
**Como reproduzir:**
**Erro exibido:**

### Problema 2:
**Descrição:**
**Como reproduzir:**
**Erro exibido:**

---

## 📊 RESULTADO FINAL

- [ ] ✅ Todos os testes passaram
- [ ] ⚠️ Alguns testes falharam (listar acima)
- [ ] 🔴 Muitos problemas encontrados

---

## 🔧 CORREÇÕES NECESSÁRIAS

1. 
2. 
3. 

---

## 📝 OBSERVAÇÕES

### Funcionalidades que faltam implementar:
- [ ] Editar nome/bio no perfil
- [ ] Excluir próprio comentário
- [ ] Seguir/deixar de seguir usuários
- [ ] Lista de seguidores/seguindo
- [ ] Filtros no feed (populares, recentes)
- [ ] Buscar usuários

### Melhorias sugeridas:
- [ ] Paginação no feed
- [ ] Infinite scroll
- [ ] Notificações de novas reações/comentários
- [ ] Compartilhar exercício

---

## 🎯 PRÓXIMO TESTE

Após concluir este teste, seguiremos para:
**TESTE 04 - Grupos de Treino**

