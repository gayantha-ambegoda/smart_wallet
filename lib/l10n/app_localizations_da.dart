// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Danish (`da`).
class AppLocalizationsDa extends AppLocalizations {
  AppLocalizationsDa([String locale = 'da']) : super(locale);

  @override
  String get appTitle => 'Smart Wallet';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get templates => 'Skabeloner';

  @override
  String get availableBalance => 'Tilgængelig saldo';

  @override
  String get totalIncome => 'Samlet indkomst';

  @override
  String get totalExpense => 'Samlede udgifter';

  @override
  String get recentTransactions => 'Seneste transaktioner';

  @override
  String get noTransactionsYet => 'Ingen transaktioner endnu';

  @override
  String get addTransactionToGetStarted =>
      'Tilføj en transaktion for at komme i gang';

  @override
  String get noTemplatesYet => 'Ingen skabeloner endnu';

  @override
  String get createTemplateToGetStarted =>
      'Opret en skabelon for at komme i gang';

  @override
  String get addTransaction => 'Tilføj transaktion';

  @override
  String get updateTransaction => 'Opdater transaktion';

  @override
  String get transaction => 'Transaktion';

  @override
  String get transfer => 'Overførsel';

  @override
  String get transferIn => 'Indgående overførsel';

  @override
  String get transferOut => 'Udgående overførsel';

  @override
  String get title => 'Titel';

  @override
  String get amount => 'Beløb';

  @override
  String get type => 'Type';

  @override
  String get fromAccount => 'Fra konto';

  @override
  String get toAccount => 'Til konto';

  @override
  String get exchangeRate => 'Vekselkurs';

  @override
  String get budget => 'Budget';

  @override
  String get budgetOptional => 'Budget (valgfrit)';

  @override
  String get tags => 'Tags';

  @override
  String get tagsCommaSeparated => 'Tags (kommasepareret)';

  @override
  String get isTemplate => 'Er skabelon';

  @override
  String get saveTransaction => 'Gem transaktion';

  @override
  String get income => 'Indkomst';

  @override
  String get expense => 'Udgift';

  @override
  String get date => 'Dato';

  @override
  String get delete => 'Slet';

  @override
  String get update => 'Opdater';

  @override
  String get cancel => 'Annuller';

  @override
  String get edit => 'Rediger';

  @override
  String get yes => 'Ja';

  @override
  String get confirmDelete => 'Bekræft sletning';

  @override
  String deleteConfirmationMessage(String title) {
    return 'Er du sikker på, at du vil slette \"$title\"? Denne handling kan ikke fortrydes.';
  }

  @override
  String get transactionDeletedSuccessfully => 'Transaktionen blev slettet';

  @override
  String get budgetOnlyTransaction => 'Kun budget-transaktion';

  @override
  String get templateTransaction => 'Skabelon-transaktion';

  @override
  String get doTransaction => 'Udfør transaktion';

  @override
  String get confirmTransaction => 'Bekræft transaktion';

  @override
  String doTransactionConfirmationMessage(String title) {
    return 'Vil du udføre \"$title\"-transaktionen? Dette vil få den til at tælle med i din faktiske saldo.';
  }

  @override
  String get transactionExecutedSuccessfully => 'Transaktion udført';

  @override
  String get addAsTransaction => 'Tilføj som transaktion';

  @override
  String createFromTemplateMessage(String title) {
    return 'Opret en ny transaktion fra \"$title\"-skabelonen?';
  }

  @override
  String get transactionCreatedFromTemplate =>
      'Transaktion oprettet fra skabelon';

  @override
  String get selectAccount => 'Vælg konto';

  @override
  String get primary => 'Primær';

  @override
  String get accounts => 'Konti';

  @override
  String get budgets => 'Budgetter';

  @override
  String get showTransactions => 'Vis transaktioner';

  @override
  String get showTemplates => 'Vis skabeloner';

  @override
  String get settings => 'Indstillinger';

  @override
  String get noAccountsYet => 'Ingen konti endnu';

  @override
  String get createAccountToGetStarted =>
      'Opret en konto for at begynde at spore dine transaktioner';

  @override
  String get create => 'Opret';

  @override
  String get pleaseEnterTitle => 'Indtast venligst en titel';

  @override
  String get pleaseEnterAmount => 'Indtast venligst et beløb';

  @override
  String get pleaseEnterValidNumber => 'Indtast venligst et gyldigt tal';

  @override
  String get pleaseSelectAccount => 'Vælg venligst en konto';

  @override
  String get pleaseSelectDestinationAccount =>
      'Vælg venligst en destinationskonto';

  @override
  String get pleaseEnterExchangeRate => 'Indtast venligst en vekselkurs';

  @override
  String get budgetCreatedSuccessfully => 'Budget oprettet';

  @override
  String get budgetTitle => 'Budget titel';

  @override
  String get enterBudgetName => 'Indtast budgetnavn';

  @override
  String get pleaseEnterBudgetTitle => 'Indtast venligst en budget titel';

  @override
  String get createNewBudget => 'Opret nyt budget';

  @override
  String get createBudget => 'Opret budget';

  @override
  String get currencyUpdatedSuccessfully => 'Valuta opdateret';

  @override
  String get selectCurrency => 'Vælg valuta';

  @override
  String get currency => 'Valuta';

  @override
  String get language => 'Sprog';

  @override
  String get selectLanguage => 'Vælg sprog';

  @override
  String get english => 'Engelsk';

  @override
  String get french => 'Fransk';

  @override
  String get danish => 'Dansk';

  @override
  String get languageUpdatedSuccessfully => 'Sprog opdateret';

  @override
  String get accountName => 'Kontonavn';

  @override
  String get bankName => 'Banknavn';

  @override
  String get initialBalance => 'Begyndelsessaldo';

  @override
  String get setAsPrimaryAccount => 'Indstil som primær konto';

  @override
  String get primaryAccountDescription =>
      'Den primære konto vises som standard på dashboardet';

  @override
  String get saveAccount => 'Gem konto';

  @override
  String get updateAccount => 'Opdater konto';

  @override
  String get deleteAccount => 'Slet konto';

  @override
  String get deleteAccountConfirmation =>
      'Er du sikker på, at du vil slette denne konto? Denne handling kan ikke fortrydes.';

  @override
  String get pleaseEnterAccountName => 'Indtast venligst et kontonavn';

  @override
  String get pleaseEnterBankName => 'Indtast venligst et banknavn';

  @override
  String get pleaseEnterInitialBalance =>
      'Indtast venligst en begyndelsessaldo';

  @override
  String get exampleCheckingAccount => 'f.eks., Checkkonto, Opsparing';

  @override
  String get exampleBankName => 'f.eks., Danske Bank, Nordea';

  @override
  String get currentBalanceDescription => 'Nuværende saldo på denne konto';

  @override
  String get editAccount => 'Rediger konto';

  @override
  String get addAccount => 'Tilføj konto';

  @override
  String get totalBalance => 'Total saldo';

  @override
  String get noBudgetsYet => 'Ingen budgetter endnu';

  @override
  String get selected => 'Valgt';

  @override
  String get createTransaction => 'Opret transaktion';
}
