# 📋 Lista de Funcionalidades do Aplicativo RepFlow

Aqui está um resumo de todas as funcionalidades implementadas ou em desenvolvimento no aplicativo, organizadas por módulo.

## 🔐 1. Autenticação e Usuário
*   **Login**: Acesso via Email e Senha.
*   **Cadastro**: Criação de nova conta (Nome, Email, Senha).
*   **Perfil de Usuário**:
    *   Visualização de foto de perfil e nome.
    *   Estatísticas de uso (Total de exercícios, Públicos vs Privados).
    *   **Edição de Perfil**: Alterar nome e foto de perfil (Upload de imagem).
    *   Logout.

## 🏋️‍♂️ 2. Gestão de Exercícios (Core)
*   **Meus Exercícios**: Listagem de todos os exercícios cadastrados pelo usuário.
*   **Criar Exercício**:
    *   Definir Nome.
    *   Selecionar Grupo Muscular (Peito, Costas, Pernas, etc.).
    *   Adicionar Instruções/Observações.
    *   **Adicionar Foto**: Upload de foto do aparelho/exercício (Câmera ou Galeria).
    *   Definir Visibilidade (Público ou Privado).
*   **Editar Exercício**: Alterar dados e substituir foto.
*   **Excluir Exercício**: Remove o exercício e a foto associada.
*   **Filtros**: Filtrar lista por grupo muscular.

## 📊 3. Logs e Histórico (Feeling)
*   **Registrar Treino/Feeling**:
    *   Registrar como foi a execução do exercício (Peso, Repetições, Sentimento).
    *   Histórico de execuções passadas por exercício.
*   **Gráficos/Evolução** *(Planejado)*: Visualizar progresso de carga.

## 👥 4. Social e Feed
*   **Feed de Exercícios**:
    *   Visualizar exercícios públicos de outros usuários.
    *   Filtrar por "Populares" ou "Recentes".
*   **Interações**:
    *   **Reações Personalizadas**: Curtir ("Like"), "Valeu", "Amém" (💪, 🙏, 👍).
    *   **Comentários**: Adicionar e visualizar comentários em exercícios.
*   **Seguidores**:
    *   Seguir outros usuários.
    *   Ver lista de quem você segue e quem te segue.

## 🏘️ 5. Grupos de Treino (Comunidade)
*   **Criar Grupo**:
    *   Nome, Descrição, Tipo de Grupo.
    *   Público ou Privado.
*   **Listar Grupos**: Ver grupos públicos disponíveis e grupos que participo.
*   **Entrar/Sair de Grupos**.
*   **Compartilhar em Grupo**: Postar um exercício dentro de um grupo específico para os membros verem.
*   **Administração**:
    *   Criador pode remover membros ou excluir o grupo.

## 🔔 6. Notificações
*   **Central de Notificações**:
    *   Alertas de novos seguidores.
    *   Alertas de curtidas/reações em seus exercícios.
    *   Alertas de comentários.
    *   Marcar como lida/não lida.

## ⚙️ 7. Configurações e Sistema
*   **Tema**: Suporte a Dark Mode (automático do sistema/app).
*   **Cache**: Armazenamento local de imagens para economia de dados.
*   **Sincronização em Tempo Real**: Atualizações automáticas de feed, chat e dados via Firestore.
