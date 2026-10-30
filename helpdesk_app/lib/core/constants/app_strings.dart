abstract class AppStrings {
  static const String appName = 'HELP! desk';
  static const String appSlogan = 'Seu canal direto de suporte e atendimento.';

  // Auth
  static const String loginTitle = 'Acesse sua conta';
  static const String emailLabel = 'Usuário / E-mail';
  static const String passwordLabel = 'Senha';
  static const String loginButton = 'Entrar';
  static const String forgotPassword = 'Esqueci minha senha';
  static const String needHelp =
      'Precisa de ajuda para acessar? Falar com o suporte';
  static const String loginPortal = 'Portal do Usuário';
  static const String emailHint = 'nome@empresa.com ou usuário';
  static const String passwordHint = 'Digite sua senha de acesso';
  static const String rememberDevice = 'Lembrar este dispositivo por 30 dias';
  static const String termsAndPrivacy = 'Termos   •   Privacidade   •   v2.4.0';
  static const String logoHelp = 'HELP!\n';
  static const String logoDesk = 'DESK';
  static const String supportLink = 'Falar com o suporte';
  static const String helpPrompt = 'Precisa de ajuda para acessar? ';
  static const String portal = 'Portal';
  static const String technicianRole = 'TÉCNICO';
  static const String customerRole = 'CLIENTE';
  static const String userInitial = 'U';
  static const String filterAll = 'Todos';
  static const String filterPending = 'Pendentes';
  static const String filterOpen = 'Abertos';
  static const String filterInProgress = 'Em Andamento';
  static const String filterInAction = 'Em Ação';
  static const String filterCompleted = 'Concluídos';
  static const String filterResolved = 'Resolvidos';
  static const String metricInProgress = 'Andamento';
  static const String metricFinished = 'Finalizados';
  static const String waiting = 'Aguardando';
  static const String underReview = 'Em análise';
  static const String thisMonth = 'Este mês';
  static const String newBadge = 'NOVO';
  static const String openedBy = 'Aberto por';
  static const String messageFrom = 'Mensagem de';

  // Dashboard / Tickets
  static const String newTicket = 'Novo Chamado';
  static const String emptyTickets = 'Nenhum chamado encontrado.';
  static const String errorLoadingTickets =
      'N\u00e3o foi poss\u00edvel carregar os chamados.';
  static const String retry = 'Tentar novamente';
  static const String recentTickets = 'Chamados Recentes';
  static const String myRecentTickets = 'Meus Chamados Recentes';
  static const String ticketCountLabel = 'solicitações';
  static const String technicianSearch = 'Buscar por título ou ID...';
  static const String customerSearch =
      'Buscar por ID, assunto ou palavra-chave...';
  static const String notificationsTitle = 'Notificações';
  static const String notificationEmpty =
      'Você está em dia. Nenhuma notificação por aqui.';
  static const String close = 'Fechar';
  static const String deleteTicketTitle = 'Apagar chamado?';
  static const String cancel = 'Cancelar';
  static const String delete = 'Apagar';
  static const String ticketDeleted = 'Chamado apagado.';
  static const String profileUpdated = 'Perfil atualizado.';
  static const String greeting = 'Olá';
  static const String unknownUser = 'Usuário';
  static const String technicianWelcome = 'chamados sob seu monitoramento hoje';
  static const String customerWelcome =
      'Acompanhe o andamento das suas solicitações em tempo real';
  static const List<String> technicianFilters = [
    filterAll,
    filterPending,
    filterInProgress,
    filterCompleted,
  ];
  static const List<String> customerFilters = [
    filterAll,
    filterOpen,
    filterInAction,
    filterResolved,
  ];
  static String ticketDeleteConfirmation(int id) =>
      'O chamado #$id e todo o histórico serão apagados.';
  static String unreadNotificationCount(int count) => '$count novas';

  // Form & Fields
  static const String categoryLabel = 'Categoria';
  static const String priorityLabel = 'Prioridade';
  static const String titleValidationLabel = 'O título';
  static const String descriptionValidationLabel = 'A descrição';
  static const String saveButton = 'Abrir Chamado';
  static const String openTicket = 'Abrir chamado';
  static const String ticketDetails = 'Detalhes do chamado';
  static String ticketDetailTitle(int id) => '#$id - $ticketDetails';
  static const String detailedTitle = 'Título do Problema';
  static const String detailedDescription = 'Descrição Detalhada';
  static const String titleHint = 'Ex: Erro ao sincronizar banco de dados';
  static const String descriptionHint =
      'Descreva o que aconteceu, passos para reproduzir e mensagens de erro...';
  static const String optionalAttachment = 'Anexo (opcional)';
  static const String saveChanges = 'Salvar alterações';
  static const String saving = 'Salvando...';
  static const String sending = 'Enviando...';
  static const String ticketCreated = 'Chamado aberto com sucesso!';
  static const String ticketUpdated = 'Chamado atualizado.';
  static const String loadTicketError = 'Não foi possível carregar o chamado.';
  static const String ticketNotFound = 'Chamado não encontrado.';
  static const String updateStatusError =
      'Erro ao atualizar status do chamado.';
  static const String sendMessageError = 'Erro ao enviar mensagem.';
  static const String interactionsHistory = 'Histórico de Interações';
  static const String noReplies = 'Nenhuma resposta cadastrada ainda.';
  static const String replyHint = 'Escreva uma resposta...';
  static const String editTicketAction = 'Editar chamado';
  static const String deleteTicketAction = 'Apagar chamado';
  static const String deleting = 'Apagando...';
  static const String attachOrientative =
      'Clique para selecionar ou arraste uma captura - PNG, JPG ou LOG até 15MB';
  static const String fileSizeError =
      'Arquivo sem tamanho verificável ou maior que 15 MB.';

  // Categories
  static const String catHardware = 'Hardware';
  static const String catLogin = 'Login / Acesso';
  static const String catDbInfra = 'Banco de Dados / Infra';
  static const String catFinanceiro = 'Financeiro';
  static const String catInfraSelector = 'Infra & DB';
  static const String catLoginSelector = 'Acesso & Login';
  static const String priorityLow = 'Baixa';
  static const String priorityMedium = 'Média';
  static const String priorityHigh = 'Alta';
  static const String removeFile = 'Remover arquivo';

  // Profile
  static const String profileTitle = 'Perfil do Usuário';
  static const String positionLabel = 'Cargo / Função';
  static const String corporateData = 'Dados Corporativos';
  static const String fullName = 'Nome Completo';
  static const String corporateEmail = 'E-mail Corporativo';
  static const String departmentFullLabel = 'Setor / Departamento';
  static const String employeeId = 'Matrícula';
  static const String departmentTechnology = 'Tecnologia';
  static const String departmentInfrastructure = 'Infraestrutura';
  static const String departmentHumanResources = 'Recursos Humanos';
  static const String departmentOperations = 'Operações';
  static const String departmentGeneral = 'Geral';
  static const List<String> departments = [
    departmentTechnology,
    departmentInfrastructure,
    catFinanceiro,
    departmentHumanResources,
    departmentOperations,
    departmentGeneral,
  ];
  static const String profileNotFound = 'Perfil não encontrado.';
  static const String saveProfile = 'Salvar Alterações';
  static const String disconnect = 'Desconectar da conta';
  static const String disconnecting = 'Desconectando...';
  static const String saveProfileError =
      'Não foi possível salvar as alterações.';
  static const String logoutError = 'Não foi possível desconectar da conta.';
  static const String fillProfileFields = 'Preencha nome, e-mail e cargo.';
  static const String notificationSettings = 'Canais de Alerta';
  static const String emailNotifications = 'Chamados por e-mail';
  static const String emailNotificationsDescription =
      'Receba atualizações na sua caixa de entrada';
  static const String appNotifications = 'Alertas no aplicativo';
  static const String appNotificationsDescription =
      'Avisos no painel enquanto o aplicativo estiver aberto';
  static const String statusPending = 'Pendente';
  static const String statusInProgress = 'Em Andamento';
  static const String statusCompleted = 'Concluído';
  static const String goBack = 'Voltar';
  static const String changePhoto = 'Alterar foto';
  static const String attachmentImageError =
      'Não foi possível carregar a imagem do anexo.';
  static const String attachmentName = 'Anexo';
  static const String titleFallback = 'Usuário';
  static const String newStatusTitle = 'Alterar Status do Chamado';
  static const String profileImageSizeError =
      'Não foi possível verificar o tamanho da imagem.';
  static const String profileImageTooLarge =
      'A imagem deve ter no máximo 5 MB.';
  static const String profileImageFormats = 'JPG, PNG ou WebP até 5MB';
  static const String passwordValidationLabel = 'A senha';
  static String imageOpenErrorMessage(Object error) =>
      'Não foi possível abrir a imagem: $error';
}
