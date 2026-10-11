// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appName => 'ExpenseMate';

  @override
  String get navHome => 'Início';

  @override
  String get navExpenses => 'Despesas';

  @override
  String get navGrocery => 'Mercado';

  @override
  String get navBudget => 'Orçamento';

  @override
  String get navMore => 'Mais';

  @override
  String get actionSave => 'Salvar';

  @override
  String get actionCancel => 'Cancelar';

  @override
  String get actionDelete => 'Excluir';

  @override
  String get actionEdit => 'Editar';

  @override
  String get actionDone => 'Concluir';

  @override
  String get actionSkip => 'Pular';

  @override
  String get actionNext => 'Próximo';

  @override
  String get actionBack => 'Voltar';

  @override
  String get actionAdd => 'Adicionar';

  @override
  String get actionSearch => 'Buscar';

  @override
  String get actionRetry => 'Tentar novamente';

  @override
  String get actionContinue => 'Continuar';

  @override
  String get actionGetStarted => 'Começar';

  @override
  String get actionAllow => 'Permitir';

  @override
  String get actionRemove => 'Remover';

  @override
  String get actionUndo => 'DESFAZER';

  @override
  String get actionReset => 'Redefinir';

  @override
  String get commonToday => 'Hoje';

  @override
  String get commonThisMonth => 'Este mês';

  @override
  String get commonThisWeek => 'Esta semana';

  @override
  String get commonNextBill => 'Próxima conta';

  @override
  String get commonUpcomingBills => 'Próximas contas';

  @override
  String get commonTransactions => 'Transações';

  @override
  String get commonRecentTransactions => 'Transações recentes';

  @override
  String get commonViewAll => 'Ver tudo';

  @override
  String get commonOverspending =>
      'Gasto excessivo — reduza categorias opcionais.';

  @override
  String get commonPurchased => 'Comprado';

  @override
  String get commonEstimated => 'Estimado';

  @override
  String get commonTotal => 'Total';

  @override
  String get commonActual => 'Real';

  @override
  String get commonEst => 'Est.';

  @override
  String get commonAmount => 'Valor';

  @override
  String get commonMerchant => 'Estabelecimento';

  @override
  String get commonDate => 'Data';

  @override
  String get commonNotes => 'Notas';

  @override
  String get commonCategory => 'Categoria';

  @override
  String get commonDetails => 'Detalhes';

  @override
  String get commonReceipt => 'Recibo';

  @override
  String get commonFavorite => 'Favorito';

  @override
  String get commonActive => 'Ativo';

  @override
  String get commonPaymentMethod => 'Forma de pagamento';

  @override
  String get commonMonth => 'Mês';

  @override
  String get commonWeek => 'Semana';

  @override
  String get commonTwoWeeks => '2 sem';

  @override
  String get commonYear => 'Ano';

  @override
  String get dashboardTitle => 'ExpenseMate';

  @override
  String get dashboardOverview => 'Visão geral';

  @override
  String dashboardGreeting(String name) {
    return 'Olá, $name';
  }

  @override
  String get onboardNameTitle => 'Como podemos te chamar?';

  @override
  String get onboardNameSubtitle => 'Para te cumprimentar quando abrir o app.';

  @override
  String get onboardNameHint => 'Seu nome';

  @override
  String get dashboardMonthlyIncome => 'Renda mensal';

  @override
  String get dashboardMonthlyExpenses => 'Despesas do mês';

  @override
  String get dashboardRemainingBudget => 'Orçamento restante';

  @override
  String get dashboardSavings => 'Poupança';

  @override
  String get dashboardBudgetUtilization => 'Uso do orçamento';

  @override
  String get dashboardSpendingByCategory => 'Gasto por categoria';

  @override
  String get dashboardMonthlyTrend => 'Tendência mensal';

  @override
  String get dashboardQuickAdd => 'Adicionar';

  @override
  String get dashboardScanReceipt => 'Escanear recibo';

  @override
  String get dashboardScanReceiptSubtitle =>
      'Preenche valor, estabelecimento e data';

  @override
  String get dashboardEnterManually => 'Digitar manualmente';

  @override
  String get dashboardEnterManuallySubtitle =>
      'Preencha o formulário você mesmo';

  @override
  String get dashboardEmptyTitle => 'Sem transações ainda';

  @override
  String get dashboardEmptySubtitle =>
      'Toque em Adicionar para registrar sua primeira despesa.';

  @override
  String get dashboardLiveDemo => 'Demo ao vivo — dados de exemplo';

  @override
  String get dashboardLiveDemoSubtitle =>
      'Tudo aqui é simulado. Compre o código-fonte completo.';

  @override
  String get expensesTitle => 'Despesas';

  @override
  String get expensesAdd => 'Adicionar despesa';

  @override
  String get expensesEdit => 'Editar despesa';

  @override
  String get expensesEmptyTitle => 'Nenhuma despesa encontrada';

  @override
  String get expensesEmptySubtitle =>
      'Mude os filtros ou toque + para adicionar.';

  @override
  String get expensesFilter => 'Filtrar';

  @override
  String get expensesDeleted => 'Despesa excluída';

  @override
  String get expensesDeleteConfirmTitle => 'Excluir despesa?';

  @override
  String get expensesDeleteConfirmBody => 'A despesa será removida.';

  @override
  String get expensesDuplicate => 'Duplicar';

  @override
  String get expensesUnfavorite => 'Tirar dos favoritos';

  @override
  String get expensesEnterAmount => 'Digite um valor';

  @override
  String get expensesPickCategory => 'Escolha uma categoria';

  @override
  String get expensesSaveExpense => 'Salvar despesa';

  @override
  String get expensesUpdateExpense => 'Atualizar despesa';

  @override
  String get expensesNoReceipt => 'Sem recibo anexado';

  @override
  String get expensesAttached => 'Anexado';

  @override
  String get expensesAttach => 'Anexar';

  @override
  String get budgetTitle => 'Orçamento';

  @override
  String get budgetMonthlyPlan => 'Plano mensal';

  @override
  String get budgetMonthlyIncomePlan => 'Renda mensal (plano)';

  @override
  String get budgetSpendingLimit => 'Limite de gastos';

  @override
  String get budgetSavingsGoal => 'Meta de poupança';

  @override
  String get budgetCategoryBudgets => 'Orçamentos por categoria';

  @override
  String get budgetLogIncome => 'Registrar renda';

  @override
  String get budgetSavePlan => 'Salvar plano';

  @override
  String get budgetSavingsProgress => 'Progresso da poupança';

  @override
  String get budgetSaved => 'Orçamento salvo';

  @override
  String get budgetActualIncome => 'Renda real';

  @override
  String get budgetSpent => 'Gasto';

  @override
  String get budgetSource => 'Fonte';

  @override
  String get budgetSalary => 'Salário';

  @override
  String get budgetSetGoal => 'Defina uma meta para acompanhar o progresso';

  @override
  String get groceryTitle => 'Mercado';

  @override
  String get groceryYourLists => 'Suas listas';

  @override
  String get groceryEmptyTitle => 'Sem listas de compras';

  @override
  String get groceryEmptySubtitle => 'Crie sua primeira lista para começar.';

  @override
  String get groceryNewList => 'Nova lista';

  @override
  String get groceryNewShoppingList => 'Nova lista de compras';

  @override
  String get groceryListName => 'Nome da lista';

  @override
  String get groceryEnterName => 'Digite um nome';

  @override
  String get groceryMarkFavorite => 'Marcar como favorito';

  @override
  String get groceryCreateList => 'Criar lista';

  @override
  String get groceryUpdated => 'Atualizada';

  @override
  String get groceryDuplicate => 'Duplicar';

  @override
  String get groceryArchive => 'Arquivar';

  @override
  String get groceryEmptyItemsTitle => 'Sem itens ainda';

  @override
  String get groceryEmptyItemsSubtitle => 'Toque + para adicionar o primeiro.';

  @override
  String get groceryAddItem => 'Adicionar item';

  @override
  String get groceryEditItem => 'Editar item';

  @override
  String get groceryItemName => 'Nome do item';

  @override
  String get groceryQty => 'Qtd';

  @override
  String get groceryUnit => 'Unidade';

  @override
  String get groceryStore => 'Loja';

  @override
  String get groceryDuplicateList => 'Duplicar lista';

  @override
  String get groceryDeleteList => 'Excluir lista';

  @override
  String get reportsTitle => 'Relatórios';

  @override
  String get reportsMonthly => 'Mensal';

  @override
  String get reportsYearly => 'Anual';

  @override
  String get reportsCategory => 'Categoria';

  @override
  String get reportsIncomeVsExpense => 'Renda vs Despesa';

  @override
  String get reportsSavings => 'Poupança';

  @override
  String get reportsCsv => 'CSV';

  @override
  String get reportsExcel => 'Excel';

  @override
  String get reportsPdf => 'PDF';

  @override
  String get reportsLastSixMonths => 'Últimos 6 meses';

  @override
  String get reportsExpensesByMonth => 'Despesas por mês';

  @override
  String get reportsIncomeByMonth => 'Renda por mês';

  @override
  String get reportsIncomeMo => 'Renda (mês)';

  @override
  String get reportsExpensesMo => 'Despesas (mês)';

  @override
  String get reportsSavingsPerMonth => 'Poupança por mês';

  @override
  String get calendarTitle => 'Calendário';

  @override
  String get calendarNothingOnDay => 'Nada neste dia';

  @override
  String get calendarNothingOnDaySubtitle =>
      'Toque em um dia com ponto para ver as transações.';

  @override
  String calendarTransactionsCount(int count) {
    return '$count transações';
  }

  @override
  String get recurringTitle => 'Despesas recorrentes';

  @override
  String get recurringNewRule => 'Nova regra';

  @override
  String get recurringNewRuleTitle => 'Nova regra recorrente';

  @override
  String get recurringEditRule => 'Editar regra';

  @override
  String get recurringEmptyTitle => 'Nenhuma regra recorrente';

  @override
  String get recurringEmptySubtitle =>
      'Adicione assinaturas como Netflix, aluguel ou seguros. Registram-se automaticamente no vencimento.';

  @override
  String get recurringNext => 'Próximo';

  @override
  String get recurringFrequency => 'Frequência';

  @override
  String get recurringNextDue => 'Próximo vencimento';

  @override
  String get recurringEnterMerchant => 'Digite um estabelecimento';

  @override
  String get recurringCreateRule => 'Criar regra';

  @override
  String get recurringSaveRule => 'Salvar regra';

  @override
  String get recurringDeleteRule => 'Excluir regra?';

  @override
  String recurringDeleteBody(String merchant) {
    return 'Isso não remove despesas passadas. $merchant deixará de ser registrado automaticamente.';
  }

  @override
  String get recurringDaily => 'Diário';

  @override
  String get recurringWeekly => 'Semanal';

  @override
  String get recurringMonthly => 'Mensal';

  @override
  String get recurringYearly => 'Anual';

  @override
  String get scanTitle => 'Escanear recibo';

  @override
  String get scanPoint => 'Aponte a câmera para o recibo';

  @override
  String get scanAutoFill =>
      'Vamos ler total, estabelecimento e data automaticamente.';

  @override
  String get scanOpenCamera => 'Abrir câmera';

  @override
  String get scanPickGallery => 'Escolher da galeria';

  @override
  String get scanReading => 'Lendo recibo…';

  @override
  String get scanCantRead =>
      'Não conseguimos ler o recibo. Tente novamente ou preencha manualmente.';

  @override
  String get scanWhatFound => 'O que encontramos';

  @override
  String get scanContinueForm => 'Continuar para o formulário';

  @override
  String get scanRetake => 'Refazer';

  @override
  String get scanRead => 'Lido';

  @override
  String scanItemsDetected(int count) {
    return '$count itens detectados';
  }

  @override
  String get scanFullListNote => 'A lista completa será salva nas notas.';

  @override
  String get scanReceiptItems => 'Itens do recibo:';

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get settingsAppearance => 'Aparência';

  @override
  String get settingsSystem => 'Sistema';

  @override
  String get settingsLight => 'Claro';

  @override
  String get settingsDark => 'Escuro';

  @override
  String get settingsPreferences => 'Preferências';

  @override
  String get settingsCurrency => 'Moeda';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsDateFormat => 'Formato de data';

  @override
  String get settingsFirstDayOfWeek => 'Primeiro dia da semana';

  @override
  String get settingsSecurity => 'Segurança';

  @override
  String get settingsSetPin => 'Definir PIN';

  @override
  String get settingsChangePin => 'Alterar PIN';

  @override
  String get settingsPinEnabled => 'Bloqueio por PIN ativo';

  @override
  String get settingsPinDisabled => 'App desbloqueado';

  @override
  String get settingsRemovePin => 'Remover PIN';

  @override
  String get settingsRemovePinBody => 'O app não será mais bloqueado.';

  @override
  String get settingsBiometric => 'Desbloqueio biométrico';

  @override
  String get settingsBiometricAvailable => 'Face ID / Digital';

  @override
  String get settingsBiometricUnavailable => 'Não disponível neste aparelho';

  @override
  String get settingsBiometricNeedsPin =>
      'Defina um PIN primeiro para ativar a biometria';

  @override
  String get settingsData => 'Dados';

  @override
  String get settingsBackup => 'Backup e restauração';

  @override
  String get settingsReports => 'Relatórios e exportar';

  @override
  String get settingsResetDemo => 'Redefinir dados de demo';

  @override
  String get settingsResetDemoSubtitle =>
      'Apaga entradas e recarrega os dados de demo';

  @override
  String get settingsResetConfirmTitle => 'Redefinir dados de demo?';

  @override
  String get settingsResetConfirmBody =>
      'Isso apaga despesas, receitas, orçamentos e listas, depois recarrega a demo. Seu PIN, moeda e tema são mantidos.';

  @override
  String get settingsResetSuccess => 'Dados de demo recarregados';

  @override
  String get settingsAbout => 'Sobre';

  @override
  String settingsVersion(String version) {
    return 'Versão $version · Sem conexão · Sem nuvem';
  }

  @override
  String get settingsNotifications => 'Notificações';

  @override
  String get settingsDailyReminder => 'Lembrete diário';

  @override
  String settingsDailyReminderSubtitle(String time) {
    return 'Às $time';
  }

  @override
  String get settingsReminderTime => 'Horário do lembrete';

  @override
  String get settingsWeeklyReview => 'Resumo semanal';

  @override
  String get settingsWeeklyReviewSubtitle => 'Domingo 18h · resumo de gastos';

  @override
  String get settingsBudgetAlerts => 'Alertas de orçamento';

  @override
  String get settingsBudgetAlertsSubtitle => 'Aviso ao 80% e 100% do orçamento';

  @override
  String get settingsBillReminders => 'Lembretes de contas';

  @override
  String get settingsBillRemindersSubtitle =>
      '1 dia antes das despesas recorrentes';

  @override
  String get settingsChooseCurrency => 'Escolher moeda';

  @override
  String settingsCurrenciesAvailable(int count) {
    return '$count disponíveis';
  }

  @override
  String get settingsChooseLanguage => 'Escolher idioma';

  @override
  String get onboardTrackTitle => 'Cada real, registrado';

  @override
  String get onboardTrackSubtitle =>
      'Registre despesas em segundos. Categorize, favorite e anexe recibos — tudo offline.';

  @override
  String get onboardGroceryTitle => 'Listas de compras que funcionam';

  @override
  String get onboardGrocerySubtitle =>
      'Planeje com preços estimados, marque no mercado e veja o total real.';

  @override
  String get onboardSecurityTitle => 'Protegido com Face ID';

  @override
  String get onboardSecuritySubtitle =>
      'PIN de 4 dígitos e biometria opcionais. Suas finanças, só para você.';

  @override
  String get onboardOwnDataTitle => 'Seus dados, seu aparelho';

  @override
  String get onboardOwnDataSubtitle =>
      'Sem contas. Sem nuvem. Faça backup e exporte quando quiser.';

  @override
  String get onboardFreeTitle => 'Grátis para sempre';

  @override
  String get onboardFreeSubtitle =>
      'Sem assinatura. Sem anúncios. Sem conta. Um rastreador premium que funciona.';

  @override
  String get categoryGroceries => 'Mercado';

  @override
  String get categoryFuel => 'Combustível';

  @override
  String get categoryRent => 'Aluguel';

  @override
  String get categoryUtilities => 'Contas de casa';

  @override
  String get categoryDining => 'Restaurantes';

  @override
  String get categoryShopping => 'Compras';

  @override
  String get categoryEntertainment => 'Entretenimento';

  @override
  String get categoryHealthcare => 'Saúde';

  @override
  String get categoryTransportation => 'Transporte';

  @override
  String get categoryInsurance => 'Seguros';

  @override
  String get categoryEducation => 'Educação';

  @override
  String get categoryTravel => 'Viagens';

  @override
  String get categoryGifts => 'Presentes';

  @override
  String get categoryMiscellaneous => 'Diversos';

  @override
  String get paymentCash => 'Dinheiro';

  @override
  String get paymentDebitCard => 'Cartão de débito';

  @override
  String get paymentCreditCard => 'Cartão de crédito';

  @override
  String get paymentBankTransfer => 'Transferência (Pix)';

  @override
  String get paymentDigitalWallet => 'Carteira digital';

  @override
  String get paymentOther => 'Outro';

  @override
  String get lockEnterPin => 'Digite o PIN';

  @override
  String get lockUnlock => 'Desbloquear ExpenseMate';

  @override
  String get pinSetupTitle => 'Definir PIN';

  @override
  String get pinCreateSubtitle =>
      'Crie um PIN de 4 dígitos para proteger seus dados.';

  @override
  String get pinNew => 'Novo PIN';

  @override
  String get pinConfirm => 'Confirmar PIN';

  @override
  String get pinSavePin => 'Salvar PIN';

  @override
  String get pinMustBe4 => 'O PIN precisa ter 4 dígitos';

  @override
  String get pinNoMatch => 'Os PINs não coincidem';

  @override
  String get pinSet => 'PIN definido';

  @override
  String get commonAll => 'Todos';

  @override
  String get commonAny => 'Qualquer';

  @override
  String get commonError => 'Erro';

  @override
  String get commonNoData => 'Sem dados ainda';

  @override
  String get actionClear => 'Limpar';

  @override
  String get actionApply => 'Aplicar';

  @override
  String get actionAttach => 'Anexar';

  @override
  String get expensesFavorites => 'Favoritos';

  @override
  String get expensesScanTooltip => 'Escanear recibo';

  @override
  String get expensesFilterDateRange => 'Período';

  @override
  String get moreLockNow => 'Bloquear agora';

  @override
  String get groceryDetailFallbackTitle => 'Lista';

  @override
  String get backupExportDatabase => 'Exportar banco de dados';

  @override
  String get backupExportDatabaseBody =>
      'Salva uma cópia do banco SQLite e compartilha.';

  @override
  String get backupExportShare => 'Exportar e compartilhar';

  @override
  String get backupRestoreDatabase => 'Restaurar banco de dados';

  @override
  String get backupRestoreDatabaseBody =>
      'Substitui os dados atuais por um backup.';

  @override
  String get backupRestore => 'Restaurar';

  @override
  String get backupExportCsvTitle => 'Exportar despesas em CSV';

  @override
  String get backupExportCsvBody => 'Para planilhas ou análise manual.';

  @override
  String get backupExportExcelTitle => 'Exportar despesas em Excel';

  @override
  String get backupExportExcelBody => 'Arquivo XLSX com todas as despesas.';

  @override
  String get backupExportPdfTitle => 'Exportar despesas em PDF';

  @override
  String get backupExportPdfBody => 'Relatório em PDF das despesas.';

  @override
  String get backupExportCsvAction => 'Exportar CSV';

  @override
  String get backupExportExcelAction => 'Exportar Excel';

  @override
  String get backupExportPdfAction => 'Exportar PDF';

  @override
  String backupPdfPreparedFor(String name) {
    return 'Preparado para $name';
  }

  @override
  String get backupRestoreSuccessTitle => 'Restauração concluída';

  @override
  String get backupRestoreSuccessBody =>
      'O ExpenseMate precisa fechar para carregar os dados restaurados. Reabra pelo ícone na tela inicial.';

  @override
  String get backupRestoreCloseApp => 'Fechar app';

  @override
  String get backupRestoreInvalidFile =>
      'Esse arquivo não é um backup válido do ExpenseMate.';

  @override
  String get backupRestoreCancelled => 'Restauração cancelada.';

  @override
  String get backupRestoreError =>
      'A restauração falhou. Seus dados atuais estão seguros.';

  @override
  String get backupRestoreConfirmTitle => 'Restaurar backup?';

  @override
  String get backupRestoreConfirmBody =>
      'Isto substituirá seus dados atuais. Você precisará reiniciar o app.';

  @override
  String get searchHint => 'Buscar despesas, listas, notas…';

  @override
  String get searchTitleFallback => 'Busque qualquer coisa';

  @override
  String get searchSubtitleFallback =>
      'Encontre despesas, categorias, listas e notas.';

  @override
  String get searchNoExpenses => 'Nenhuma despesa encontrada';

  @override
  String get searchNoLists => 'Nenhuma lista encontrada';

  @override
  String get searchNoCategories => 'Nenhuma categoria encontrada';

  @override
  String get searchShoppingLists => 'Listas de compras';

  @override
  String get searchCategories => 'Categorias';

  @override
  String get moreCalendarTitle => 'Calendário';

  @override
  String get moreCalendarSubtitle => 'Ver gastos por dia';

  @override
  String get moreReportsTitle => 'Relatórios';

  @override
  String get moreReportsSubtitle => 'Gráficos e exportação';

  @override
  String get moreRecurringTitle => 'Despesas recorrentes';

  @override
  String get moreRecurringSubtitle =>
      'Registre automaticamente aluguel, assinaturas e mais';

  @override
  String get moreSearchTitle => 'Buscar';

  @override
  String get moreSearchSubtitle => 'Encontre qualquer coisa';

  @override
  String get moreBackupTitle => 'Backup e restauração';

  @override
  String get moreBackupSubtitle => 'Backups locais';

  @override
  String get moreSettingsTitle => 'Configurações';

  @override
  String get moreSettingsSubtitle => 'Personalize seu aplicativo';

  @override
  String get moreOnboardingTitle => 'Introdução';

  @override
  String get moreOnboardingSubtitle => 'Ver introdução novamente';

  @override
  String get filterThisMonth => 'Este mês';

  @override
  String get filterThisYear => 'Este ano';

  @override
  String get filterAllTime => 'Sempre';

  @override
  String get filterCustom => 'Personalizado';

  @override
  String get dashboardOverspendingTitle => 'Orçamento excedido este mês';

  @override
  String dashboardOverspendingBy(String amount) {
    return '$amount a mais';
  }

  @override
  String get dashboardOverspendingViewBudget => 'Ver Orçamento';

  @override
  String dashboardOverspendingMore(int count) {
    return '+$count mais';
  }

  @override
  String get lockUnlockApp => 'Desbloquear ExpenseMate';

  @override
  String get backupExportTitle => 'Backup e Exportação';

  @override
  String get calendarUpcomingBills => 'Contas futuras';

  @override
  String get calendarTransactionsHeader => 'Transações';

  @override
  String get calendarAutoLog => 'Registro automático';

  @override
  String settingsSampleLabel(String value) {
    return 'Exemplo: $value';
  }

  @override
  String get weekdaySunday => 'Domingo';

  @override
  String get weekdayMonday => 'Segunda-feira';

  @override
  String get paywallTitleTrial => 'Desbloqueie o ExpenseMate';

  @override
  String get paywallTitleExpired => 'Seu teste grátis terminou';

  @override
  String paywallSubtitleTrial(int days) {
    return 'Restam $days dias do seu teste grátis. Desbloqueie para sempre com um pagamento único.';
  }

  @override
  String get paywallSubtitleExpired =>
      'Continue acompanhando seu dinheiro — pagamento único, sem assinatura.';

  @override
  String get paywallFeatureOffline => 'Funciona totalmente offline';

  @override
  String get paywallFeatureScanner => 'Scanner de recibos inteligente';

  @override
  String get paywallFeatureReports => 'Relatórios e gráficos detalhados';

  @override
  String get paywallFeatureBudgets => 'Orçamentos e lembretes';

  @override
  String get paywallFeaturePrivacy => 'Bloqueio por PIN e biometria';

  @override
  String get paywallFeatureLanguages => '6 idiomas';

  @override
  String paywallBuyButton(String price) {
    return 'Desbloquear · $price';
  }

  @override
  String get paywallRestore => 'Restaurar compra';

  @override
  String get paywallFinePrint =>
      'Pagamento único. Sem assinatura. Sem renovação automática.';

  @override
  String get paywallErrorGeneric =>
      'A compra não pôde iniciar. Tente novamente.';

  @override
  String get paywallProductUnavailable =>
      'A loja não está acessível agora. Verifique sua conexão e tente novamente.';

  @override
  String get paywallRestoreNone =>
      'Nenhuma compra anterior encontrada nesta conta.';

  @override
  String get paywallPending =>
      'Sua compra está sendo processada. Você terá acesso quando for confirmada.';

  @override
  String get paywallRetry => 'Tentar novamente';
}
