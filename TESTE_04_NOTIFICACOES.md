# 🧪 Teste 04 - Sistema de Notificações

## ✅ O que já está implementado:

### Tela de Notificações
- ✅ Listagem de notificações
- ✅ Tipos: Follow, Like, Comment
- ✅ Marcar como lida
- ✅ Marcar todas como lidas
- ✅ Deletar notificação (swipe)
- ✅ Badge de não lidas
- ✅ Navegação ao clicar
- ✅ Timestamp relativo

### Criação Automática
- ✅ Ao curtir exercício de outro usuário
- ✅ Ao comentar em exercício de outro usuário
- ✅ Ao seguir outro usuário (se implementado)

---

## 🧪 ROTEIRO DE TESTES

### Teste 4.1: Verificar Tela Vazia

**Passos:**
1. Vá para aba "Notificações" (ícone de sino)
2. Observe a tela

**Resultado Esperado:**
- ✅ Se não houver notificações: ícone grande de sino + "Nenhuma notificação"
- ✅ Tela limpa e organizada

**Verificar:**
- [ ] Empty state aparece?
- [ ] Mensagem clara?

---

### Teste 4.2: Criar Notificação de Like

**Importante:** Para testar, você precisa de 2 usuários!

**Opção A: Criar segundo usuário**
1. Faça logout
2. Crie nova conta: "teste2@gmail.com"
3. Faça login com o novo usuário

**Opção B: Usar navegador anônimo**
1. Abra uma janela anônima
2. Acesse localhost:PORTA
3. Crie/faça login com outro usuário

**Passos do Teste:**
1. **Usuário 1:** Crie um exercício PÚBLICO
2. **Usuário 2:** Vá para aba "Explorar"
3. **Usuário 2:** Encontre o exercício do Usuário 1
4. **Usuário 2:** Abra o exercício e clique em ❤️ (Like)
5. **Usuário 1:** Vá para aba "Notificações"

**Resultado Esperado:**
- ✅ Notificação aparece: "[Nome] reagiu ao seu exercício [Nome do Exercício]"
- ✅ Ícone de coração vermelho
- ✅ Badge azul (não lida)
- ✅ Timestamp ("Agora", "Há 1min", etc)

**Verificar:**
- [ ] Notificação foi criada?
- [ ] Informações corretas?
- [ ] Badge de não lida aparece?

---

### Teste 4.3: Marcar Como Lida

**Passos:**
1. Na tela de notificações, clique em uma notificação não lida
2. Volte para tela de notificações

**Resultado Esperado:**
- ✅ Badge azul desaparece
- ✅ Texto fica normal (não negrito)
- ✅ Fundo branco (não azul claro)

**Verificar:**
- [ ] Marcou como lida?
- [ ] Visual mudou?

---

### Teste 4.4: Navegação ao Clicar

**Passos:**
1. Clique em uma notificação de like/comentário
2. Observe para onde navega

**Resultado Esperado:**
- ✅ Abre a tela de detalhes do exercício
- ✅ Exercício correto é exibido
- ✅ Notificação é marcada como lida

**Verificar:**
- [ ] Navegou corretamente?
- [ ] Exercício correto?

---

### Teste 4.5: Marcar Todas Como Lidas

**Passos:**
1. Tenha pelo menos 2 notificações não lidas
2. Clique em "Marcar todas como lidas" (canto superior direito)

**Resultado Esperado:**
- ✅ Todas as notificações ficam como lidas
- ✅ Badges desaparecem
- ✅ Botão "Marcar todas" desaparece

**Verificar:**
- [ ] Todas marcadas?
- [ ] Botão sumiu?

---

### Teste 4.6: Deletar Notificação (Swipe)

**Passos:**
1. Em uma notificação, arraste da direita para esquerda
2. Continue arrastando até deletar

**Resultado Esperado:**
- ✅ Fundo vermelho aparece
- ✅ Ícone de lixeira visível
- ✅ Notificação é removida
- ✅ Lista atualiza

**Verificar:**
- [ ] Swipe funciona?
- [ ] Notificação foi deletada?

---

### Teste 4.7: Criar Notificação de Comentário

**Passos:**
1. **Usuário 2:** Vá em um exercício público do Usuário 1
2. **Usuário 2:** Adicione um comentário: "Ótimo exercício!"
3. **Usuário 1:** Vá para aba "Notificações"

**Resultado Esperado:**
- ✅ Notificação aparece: "[Nome] comentou no seu exercício [Nome]"
- ✅ Ícone de comentário verde
- ✅ Badge de não lida

**Verificar:**
- [ ] Notificação criada?
- [ ] Tipo correto (comentário)?

---

### Teste 4.8: Múltiplas Notificações

**Passos:**
1. Crie várias notificações (likes, comentários)
2. Observe a lista

**Resultado Esperado:**
- ✅ Notificações em ordem cronológica (mais recente primeiro)
- ✅ Scroll funciona
- ✅ Todas visíveis

**Verificar:**
- [ ] Ordem correta?
- [ ] Todas aparecem?

---

### Teste 4.9: Pull to Refresh

**Passos:**
1. Na tela de notificações, puxe para baixo
2. Solte

**Resultado Esperado:**
- ✅ Indicador de loading aparece
- ✅ Lista é recarregada
- ✅ Novas notificações aparecem (se houver)

**Verificar:**
- [ ] Refresh funciona?
- [ ] Lista atualiza?

---

### Teste 4.10: Timestamp Relativo

**Passos:**
1. Observe os timestamps das notificações
2. Aguarde alguns minutos
3. Recarregue a tela

**Resultado Esperado:**
- ✅ "Agora" para notificações recentes
- ✅ "Há Xmin" para minutos
- ✅ "Há Xh" para horas
- ✅ "Ontem" para 1 dia
- ✅ "Há X dias" para dias
- ✅ "Há X semanas" para semanas

**Verificar:**
- [ ] Timestamps corretos?
- [ ] Atualizam com o tempo?

---

## 🐛 PROBLEMAS ENCONTRADOS

### Problema 1:
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

### Funcionalidades Testadas:
- [ ] Tela vazia (empty state)
- [ ] Notificação de like
- [ ] Notificação de comentário
- [ ] Marcar como lida
- [ ] Marcar todas como lidas
- [ ] Deletar notificação
- [ ] Navegação ao clicar
- [ ] Pull to refresh
- [ ] Timestamps relativos

### Funcionalidades que faltam:
- [ ] Notificação de follow (se seguir usuários for implementado)
- [ ] Badge de contador na aba de notificações
- [ ] Push notifications (requer FCM)
- [ ] Som/vibração ao receber notificação
- [ ] Agrupar notificações similares

---

## 💡 Dicas para Testar:

### Como criar notificações facilmente:

1. **Abra 2 navegadores:**
   - Chrome normal: Usuário 1
   - Chrome anônimo: Usuário 2

2. **Ou use 2 dispositivos:**
   - Computador: Usuário 1
   - Celular: Usuário 2

3. **Fluxo rápido:**
   - Usuário 1: Cria exercício público
   - Usuário 2: Curte e comenta
   - Usuário 1: Vê notificações

---

## 🎯 PRÓXIMO TESTE

Após concluir este teste, seguiremos para:
**TESTE 05 - Feed Social e Interações**

