// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Smart Wallet';

  @override
  String get dashboard => 'Tableau de bord';

  @override
  String get templates => 'Modèles';

  @override
  String get availableBalance => 'Solde disponible';

  @override
  String get totalIncome => 'Revenu total';

  @override
  String get totalExpense => 'Dépense totale';

  @override
  String get recentTransactions => 'Transactions récentes';

  @override
  String get noTransactionsYet => 'Aucune transaction pour le moment';

  @override
  String get addTransactionToGetStarted =>
      'Ajoutez une transaction pour commencer';

  @override
  String get noTemplatesYet => 'Aucun modèle pour le moment';

  @override
  String get createTemplateToGetStarted => 'Créez un modèle pour commencer';

  @override
  String get addTransaction => 'Ajouter une transaction';

  @override
  String get updateTransaction => 'Mettre à jour la transaction';

  @override
  String get transaction => 'Transaction';

  @override
  String get transfer => 'Virement';

  @override
  String get transferIn => 'Virement entrant';

  @override
  String get transferOut => 'Virement sortant';

  @override
  String get title => 'Titre';

  @override
  String get amount => 'Montant';

  @override
  String get type => 'Type';

  @override
  String get fromAccount => 'Du compte';

  @override
  String get toAccount => 'Au compte';

  @override
  String get exchangeRate => 'Taux de change';

  @override
  String get budget => 'Budget';

  @override
  String get budgetOptional => 'Budget (optionnel)';

  @override
  String get tags => 'Étiquettes';

  @override
  String get tagsCommaSeparated => 'Étiquettes (séparées par des virgules)';

  @override
  String get isTemplate => 'Est un modèle';

  @override
  String get saveTransaction => 'Enregistrer la transaction';

  @override
  String get income => 'Revenu';

  @override
  String get expense => 'Dépense';

  @override
  String get date => 'Date';

  @override
  String get delete => 'Supprimer';

  @override
  String get update => 'Mettre à jour';

  @override
  String get cancel => 'Annuler';

  @override
  String get edit => 'Modifier';

  @override
  String get yes => 'Oui';

  @override
  String get confirmDelete => 'Confirmer la suppression';

  @override
  String deleteConfirmationMessage(String title) {
    return 'Êtes-vous sûr de vouloir supprimer \"$title\" ? Cette action ne peut pas être annulée.';
  }

  @override
  String get transactionDeletedSuccessfully =>
      'Transaction supprimée avec succès';

  @override
  String get budgetOnlyTransaction => 'Transaction de budget uniquement';

  @override
  String get templateTransaction => 'Transaction modèle';

  @override
  String get doTransaction => 'Exécuter la transaction';

  @override
  String get confirmTransaction => 'Confirmer la transaction';

  @override
  String doTransactionConfirmationMessage(String title) {
    return 'Voulez-vous exécuter la transaction \"$title\" ? Cela la fera compter dans votre solde réel.';
  }

  @override
  String get transactionExecutedSuccessfully =>
      'Transaction exécutée avec succès';

  @override
  String get addAsTransaction => 'Ajouter comme transaction';

  @override
  String createFromTemplateMessage(String title) {
    return 'Créer une nouvelle transaction à partir du modèle \"$title\" ?';
  }

  @override
  String get transactionCreatedFromTemplate =>
      'Transaction créée à partir du modèle';

  @override
  String get selectAccount => 'Sélectionner un compte';

  @override
  String get primary => 'Principal';

  @override
  String get accounts => 'Comptes';

  @override
  String get budgets => 'Budgets';

  @override
  String get showTransactions => 'Afficher les transactions';

  @override
  String get showTemplates => 'Afficher les modèles';

  @override
  String get settings => 'Paramètres';

  @override
  String get noAccountsYet => 'Aucun compte pour le moment';

  @override
  String get createAccountToGetStarted =>
      'Créez un compte pour commencer à suivre vos transactions';

  @override
  String get create => 'Créer';

  @override
  String get pleaseEnterTitle => 'Veuillez entrer un titre';

  @override
  String get pleaseEnterAmount => 'Veuillez entrer un montant';

  @override
  String get pleaseEnterValidNumber => 'Veuillez entrer un nombre valide';

  @override
  String get pleaseSelectAccount => 'Veuillez sélectionner un compte';

  @override
  String get pleaseSelectDestinationAccount =>
      'Veuillez sélectionner un compte de destination';

  @override
  String get pleaseEnterExchangeRate => 'Veuillez entrer un taux de change';

  @override
  String get budgetCreatedSuccessfully => 'Budget créé avec succès';

  @override
  String get budgetTitle => 'Titre du budget';

  @override
  String get enterBudgetName => 'Entrez le nom du budget';

  @override
  String get pleaseEnterBudgetTitle => 'Veuillez entrer un titre de budget';

  @override
  String get createNewBudget => 'Créer un nouveau budget';

  @override
  String get createBudget => 'Créer un budget';

  @override
  String get currencyUpdatedSuccessfully => 'Devise mise à jour avec succès';

  @override
  String get selectCurrency => 'Sélectionner la devise';

  @override
  String get currency => 'Devise';

  @override
  String get language => 'Langue';

  @override
  String get selectLanguage => 'Sélectionner la langue';

  @override
  String get english => 'Anglais';

  @override
  String get french => 'Français';

  @override
  String get danish => 'Danois';

  @override
  String get languageUpdatedSuccessfully => 'Langue mise à jour avec succès';

  @override
  String get accountName => 'Nom du compte';

  @override
  String get bankName => 'Nom de la banque';

  @override
  String get initialBalance => 'Solde initial';

  @override
  String get setAsPrimaryAccount => 'Définir comme compte principal';

  @override
  String get primaryAccountDescription =>
      'Le compte principal est affiché par défaut sur le tableau de bord';

  @override
  String get saveAccount => 'Enregistrer le compte';

  @override
  String get updateAccount => 'Mettre à jour le compte';

  @override
  String get deleteAccount => 'Supprimer le compte';

  @override
  String get deleteAccountConfirmation =>
      'Êtes-vous sûr de vouloir supprimer ce compte ? Cette action ne peut pas être annulée.';

  @override
  String get pleaseEnterAccountName => 'Veuillez entrer un nom de compte';

  @override
  String get pleaseEnterBankName => 'Veuillez entrer un nom de banque';

  @override
  String get pleaseEnterInitialBalance => 'Veuillez entrer un solde initial';

  @override
  String get exampleCheckingAccount => 'par ex., Compte courant, Épargne';

  @override
  String get exampleBankName => 'par ex., Banque de France, BNP Paribas';

  @override
  String get currentBalanceDescription => 'Solde actuel dans ce compte';

  @override
  String get editAccount => 'Modifier le compte';

  @override
  String get addAccount => 'Ajouter un compte';

  @override
  String get totalBalance => 'Solde total';

  @override
  String get noBudgetsYet => 'Aucun budget pour le moment';

  @override
  String get selected => 'Sélectionné';

  @override
  String get createTransaction => 'Créer une transaction';

  @override
  String get budgetActions => 'Actions du budget';

  @override
  String get editBudget => 'Modifier le budget';

  @override
  String get deleteBudget => 'Supprimer le budget';

  @override
  String get duplicateBudget => 'Dupliquer le budget';

  @override
  String deleteBudgetConfirmation(String title) {
    return 'Êtes-vous sûr de vouloir supprimer \"$title\" ? Cela supprimera également toutes les transactions du budget. Cette action ne peut pas être annulée.';
  }

  @override
  String get budgetDeletedSuccessfully => 'Budget supprimé avec succès';

  @override
  String get budgetUpdatedSuccessfully => 'Budget mis à jour avec succès';

  @override
  String get budgetDuplicatedSuccessfully => 'Budget dupliqué avec succès';

  @override
  String get cannotDeleteBudgetWithTransactions =>
      'Impossible de supprimer le budget. Il y a des transactions liées aux éléments de ce budget. Veuillez d\'abord supprimer ces transactions.';

  @override
  String duplicateOf(String title) {
    return 'Copie de $title';
  }

  @override
  String get saveBudget => 'Enregistrer le budget';
}
