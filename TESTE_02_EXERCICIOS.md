# 🧪 Teste 02 - Criar e Gerenciar Exercícios

## ✅ O que já está implementado:

### Tela Home (Listagem)
- ✅ Listagem de exercícios do usuário
- ✅ Agrupamento por grupo de treino
- ✅ Preview de imagem ou placeholder
- ✅ Indicador de exercício público
- ✅ Empty state (quando não há exercícios)
- ✅ Botão flutuante para adicionar

### Tela de Adicionar Exercício
- ✅ Upload de foto (galeria)
- ✅ Campo nome (obrigatório)
- ✅ Dropdown de grupo de treino
- ✅ Campo instruções (obrigatório)
- ✅ Toggle público/privado
- ✅ Preview da imagem selecionada
- ✅ Loading state durante salvamento

### Tela de Detalhes
- ✅ Exibição de imagem
- ✅ Chip do grupo de treino
- ✅ Instruções completas
- ✅ Botão de excluir
- ✅ Confirmação antes de excluir
- ✅ Sistema de reações (Like, Valeu, Amém)
- ✅ Seção de comentários
- ✅ Feeling logs (notas pessoais)
- ✅ Compartilhar em grupo

---

## 🧪 ROTEIRO DE TESTES

### Teste 2.1: Criar Primeiro Exercício

**Passos:**
1. Na tela Home, clique no botão "Novo Exercício" (botão flutuante +)
2. Clique na área de foto e selecione uma imagem da galeria
3. Preencha os campos:
   - Nome: "Supino Reto"
   - Grupo: "Treino A"
   - Instruções: "Deitar no banco, segurar a barra com pegada média, descer até o peito e empurrar"
4. Deixe como "Privado" (toggle desligado)
5. Clique em "Salvar Exercício"

**Resultado Esperado:**
- ✅ Preview da imagem aparece
- ✅ Loading aparece no botão
- ✅ Volta para tela Home
- ✅ Mensagem "Exercício adicionado com sucesso!"
- ✅ Exercício aparece na lista sob "Treino A"
- ✅ Imagem é exibida no card

**Verificar:**
- [ X ] Foto foi carregada?
- [ x ] Exercício apareceu na lista?
- [ ] Está no grupo correto?
- [ ] Imagem está visível?

---

### Teste 2.2: Criar Exercício Público

**Passos:**
1. Clique em "Novo Exercício"
2. Adicione foto
3. Preencha:
   - Nome: "Agachamento Livre"
   - Grupo: "Treino B"
   - Instruções: "Pés na largura dos ombros, descer até 90 graus"
4. **Ative o toggle "Tornar público"**
5. Salvar

**Resultado Esperado:**
- ✅ Exercício criado
- ✅ Aparece com ícone de "Público" no card
- ✅ Ícone de globo visível

**Verificar:**
- [ ] Toggle funcionou?
- [ ] Ícone "Público" aparece?
- [ ] Exercício está na lista?

---

### Teste 2.3: Criar Exercício sem Foto

**Passos:**
1. Criar novo exercício
2. **NÃO adicionar foto**
3. Preencher nome e instruções
4. Salvar

**Resultado Esperado:**
- ✅ Exercício é criado normalmente
- ✅ Placeholder de imagem aparece (ícone de haltere)

**Verificar:**
- [ ] Criou sem foto?
- [ ] Placeholder aparece?

---

### Teste 2.4: Validações de Formulário

**Teste A: Nome vazio**
- Deixar nome em branco
- Tentar salvar
- Resultado: "Digite o nome do exercício"

**Teste B: Instruções vazias**
- Deixar instruções em branco
- Tentar salvar
- Resultado: "Digite as instruções"

**Verificar:**
- [ ] Validações funcionam?
- [ ] Não permite salvar?

---

### Teste 2.5: Visualizar Detalhes do Exercício

**Passos:**
1. Na lista, clique em um exercício
2. Observe a tela de detalhes

**Resultado Esperado:**
- ✅ Imagem aparece no topo (ou placeholder)
- ✅ Chip do grupo de treino visível
- ✅ Instruções completas exibidas
- ✅ Seção "Como estou me sentindo" visível
- ✅ Se público: botões de reação visíveis

**Verificar:**
- [ ] Todas as informações aparecem?
- [ ] Layout está correto?
- [ ] Imagem carrega?

---

### Teste 2.6: Adicionar Feeling Log (Nota Pessoal)

**Passos:**
1. Na tela de detalhes de um exercício
2. Role até "Como estou me sentindo"
3. Digite uma nota: "Treino pesado hoje, 3x12 com 60kg"
4. Clique no botão de enviar (ícone de avião)

**Resultado Esperado:**
- ✅ Nota é adicionada
- ✅ Aparece na lista abaixo
- ✅ Mostra timestamp (ex: "Há 1 min")
- ✅ Campo de texto é limpo

**Verificar:**
- [ ] Nota foi salva?
- [ ] Aparece na lista?
- [ ] Timestamp correto?

---

### Teste 2.7: Reações em Exercício Público

**Passos:**
1. Abra um exercício PÚBLICO
2. Clique no botão de coração (Like)
3. Clique no botão 👍 (Valeu)
4. Clique no botão 🙏 (Amém)
5. Clique novamente em cada um para remover

**Resultado Esperado:**
- ✅ Contador aumenta ao clicar
- ✅ Botão fica destacado (azul)
- ✅ Contador diminui ao clicar novamente
- ✅ Botão volta ao normal

**Verificar:**
- [ ] Like funciona?
- [ ] Valeu funciona?
- [ ] Amém funciona?
- [ ] Contadores atualizam?
- [ ] Toggle on/off funciona?

---

### Teste 2.8: Excluir Exercício

**Passos:**
1. Na tela de detalhes, clique no ícone de lixeira (canto superior direito)
2. Confirme a exclusão

**Resultado Esperado:**
- ✅ Dialog de confirmação aparece
- ✅ Mensagem clara sobre exclusão permanente
- ✅ Ao confirmar: volta para Home
- ✅ Exercício removido da lista
- ✅ Mensagem "Exercício excluído"

**Verificar:**
- [ ] Confirmação aparece?
- [ ] Excluiu corretamente?
- [ ] Removeu da lista?
- [ ] Foto foi deletada do storage?

---

### Teste 2.9: Criar Múltiplos Exercícios

**Passos:**
1. Criar 3 exercícios no "Treino A"
2. Criar 2 exercícios no "Treino B"
3. Criar 1 exercício no "Cardio"

**Resultado Esperado:**
- ✅ Exercícios são agrupados por treino
- ✅ Grupos aparecem em ordem alfabética
- ✅ Cada grupo mostra seus exercícios

**Verificar:**
- [ ] Agrupamento funciona?
- [ ] Ordem está correta?
- [ ] Todos aparecem?

---

### Teste 2.10: Compartilhar em Grupo (se público)

**Passos:**
1. Abra um exercício PÚBLICO
2. Clique no ícone de compartilhar (canto superior direito)
3. Selecione um grupo (se tiver criado)
4. Confirme

**Resultado Esperado:**
- ✅ Dialog de seleção de grupo aparece
- ✅ Lista de grupos disponíveis
- ✅ Ao confirmar: mensagem de sucesso

**Verificar:**
- [ ] Dialog abre?
- [ ] Grupos aparecem?
- [ ] Compartilhamento funciona?

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

- [x] ✅ Todos os testes principais passaram
- [x] ✅ Criar exercício COM foto - FUNCIONANDO
- [x] ✅ Criar exercício SEM foto - FUNCIONANDO
- [x] ✅ Exercício público - FUNCIONANDO
- [x] ✅ Exercício privado - FUNCIONANDO
- [x] ✅ Upload de imagens - FUNCIONANDO (após configurar CORS)
- [x] ✅ Visualização de imagens - FUNCIONANDO

---

## 🔧 CORREÇÕES NECESSÁRIAS

✅ **RESOLVIDO:**
1. ✅ Erro ao criar exercício com foto - CORRIGIDO (mudança no fluxo de upload)
2. ✅ CORS configurado no Firebase Storage
3. ✅ Upload e visualização de imagens funcionando

## 🎯 Funcionalidades Testadas e Aprovadas:

- [x] Criar exercício privado sem foto
- [x] Criar exercício privado com foto
- [x] Criar exercício público sem foto
- [x] Criar exercício público com foto
- [x] Upload de imagens para Firebase Storage
- [x] Visualização de imagens
- [x] Listagem de exercícios
- [x] Agrupamento por treino

---

## 📝 OBSERVAÇÕES

### Funcionalidades que faltam implementar:
- [ ] Editar exercício existente
- [ ] Filtrar exercícios por grupo
- [ ] Buscar exercícios
- [ ] Ordenar exercícios

### Melhorias sugeridas:
- [ ] Adicionar mais grupos de treino
- [ ] Permitir criar grupos personalizados
- [ ] Adicionar campos de séries/repetições
- [ ] Histórico de cargas

---

## 🎯 PRÓXIMO TESTE

Após concluir este teste, seguiremos para:
**TESTE 03 - Perfil e Edição de Perfil**

