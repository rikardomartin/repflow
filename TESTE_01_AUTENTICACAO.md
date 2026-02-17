# 🧪 Teste 01 - Autenticação

## ✅ O que já está implementado:

### Tela de Login
- ✅ Validação de email (verifica se tem @)
- ✅ Validação de senha (verifica se não está vazio)
- ✅ Loading state durante login
- ✅ Exibição de mensagens de erro
- ✅ Link para tela de cadastro

### Tela de Registro
- ✅ Campo de nome (mínimo 3 caracteres)
- ✅ Campo de email (validação básica)
- ✅ Campo de senha (mínimo 6 caracteres)
- ✅ Confirmação de senha (verifica se são iguais)
- ✅ Loading state durante registro
- ✅ Exibição de mensagens de erro
- ✅ Volta para login após sucesso

### AuthProvider
- ✅ Listener de mudanças de autenticação
- ✅ Estados de loading
- ✅ Tratamento de erros
- ✅ Função de logout

---

## 🧪 ROTEIRO DE TESTES

### Teste 1.1: Cadastro de Novo Usuário

**Passos:**
1. Abra o app
2. Clique em "Cadastre-se"
3. Preencha os campos:
   - Nome: "Teste User"
   - Email: "teste@email.com"
   - Senha: "123456"
   - Confirmar Senha: "123456"
4. Clique em "Criar Conta"

**Resultado Esperado:**
- ✅ Loading aparece no botão
- ✅ Conta é criada no Firebase Auth
- ✅ Perfil é criado no Firestore
- ✅ Usuário é redirecionado para tela principal
- ✅ Volta para tela de login

**Verificar:**
- [ ] Botão mostra loading? NÃO
- [ X] Conta foi criada?
- [X ] Redirecionou corretamente?
- [ ] Algum erro apareceu? NÃO



---

### Teste 1.2: Validações de Cadastro

**Teste A: Nome muito curto** ok
- Nome: "Ab" ok
- Resultado: Deve mostrar "Nome muito curto"

**Teste B: Email inválido**
- Email: "testeemail.com" (sem @) ok
- Resultado: Deve mostrar "Email inválido"

**Teste C: Senha muito curta** ok
- Senha: "12345" (5 caracteres)
- Resultado: Deve mostrar "Senha deve ter pelo menos 6 caracteres"

**Teste D: Senhas não conferem** ok
- Senha: "123456"
- Confirmar: "654321"
- Resultado: Deve mostrar "Senhas não conferem"

**Verificar:**
- [sim ] Todas as validações funcionam?
- [ sim ] Mensagens aparecem corretamente?

---

### Teste 1.3: Login com Usuário Existente

**Passos:**
1. Na tela de login, preencha:
   - Email: "teste@email.com"
   - Senha: "123456"
2. Clique em "Entrar"

**Resultado Esperado:**
- ✅ Loading aparece no botão
- ✅ Usuário é autenticado
- ✅ Redirecionado para tela principal (MainScreen)
- ✅ Bottom navigation aparece

**Verificar:**
- [ sim] Login funcionou?
- [ sim] Redirecionou para MainScreen?
- [ sim] Bottom navigation está visível?

---

### Teste 1.4: Login com Credenciais Inválidas

**Teste A: Email não cadastrado**
- Email: "naoexiste@email.com"
- Senha: "123456"
- Resultado: Deve mostrar erro

**Teste B: Senha incorreta**
- Email: "teste@email.com"
- Senha: "senhaerrada"
- Resultado: Deve mostrar erro

**Verificar:**
- [ ] Mensagem de erro aparece?
- [ ] Mensagem é clara?
- [ ] Não trava o app?

---

### Teste 1.5: Logout

**Passos:**
1. Estando logado, vá para aba "Perfil"
2. Procure botão de logout
3. Clique em logout

**Resultado Esperado:**
- ✅ Usuário é deslogado
- ✅ Volta para tela de login
- ✅ Não há erros

**Verificar:**
- [ sim] Logout funcionou?
- [ sim] Voltou para login?
- [ sim] Dados foram limpos?

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

- [ X ] ✅ Todos os testes passaram
- [ ] ⚠️ Alguns testes falharam (listar acima)
- [ ] 🔴 Muitos problemas encontrados

---

## 🔧 CORREÇÕES NECESSÁRIAS

1. 
2. 
3. 

---

## 📝 OBSERVAÇÕES

- 
- 
- 

