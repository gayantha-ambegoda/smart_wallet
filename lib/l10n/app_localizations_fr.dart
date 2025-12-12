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
}
