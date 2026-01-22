// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Smart Wallet';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get templates => 'Templates';

  @override
  String get availableBalance => 'Available Balance';

  @override
  String get totalIncome => 'Total Income';

  @override
  String get totalExpense => 'Total Expense';

  @override
  String get recentTransactions => 'Recent Transactions';

  @override
  String get noTransactionsYet => 'No transactions yet';

  @override
  String get addTransactionToGetStarted => 'Add a transaction to get started';

  @override
  String get noTemplatesYet => 'No templates yet';

  @override
  String get createTemplateToGetStarted => 'Create a template to get started';

  @override
  String get addTransaction => 'Add Transaction';

  @override
  String get updateTransaction => 'Update Transaction';

  @override
  String get transaction => 'Transaction';

  @override
  String get transfer => 'Transfer';

  @override
  String get transferIn => 'Transfer In';

  @override
  String get transferOut => 'Transfer Out';

  @override
  String get title => 'Title';

  @override
  String get amount => 'Amount';

  @override
  String get type => 'Type';

  @override
  String get fromAccount => 'From Account';

  @override
  String get toAccount => 'To Account';

  @override
  String get exchangeRate => 'Exchange Rate';

  @override
  String get budget => 'Budget';

  @override
  String get budgetOptional => 'Budget (Optional)';

  @override
  String get tags => 'Tags';

  @override
  String get tagsCommaSeparated => 'Tags (comma-separated)';

  @override
  String get isTemplate => 'Is Template';

  @override
  String get saveTransaction => 'Save Transaction';

  @override
  String get income => 'Income';

  @override
  String get expense => 'Expense';

  @override
  String get date => 'Date';

  @override
  String get delete => 'Delete';

  @override
  String get update => 'Update';

  @override
  String get cancel => 'Cancel';

  @override
  String get edit => 'Edit';

  @override
  String get yes => 'Yes';

  @override
  String get confirmDelete => 'Confirm Delete';

  @override
  String deleteConfirmationMessage(String title) {
    return 'Are you sure you want to delete \"$title\"? This action cannot be undone.';
  }

  @override
  String get transactionDeletedSuccessfully =>
      'Transaction deleted successfully';

  @override
  String get budgetOnlyTransaction => 'Budget-Only Transaction';

  @override
  String get templateTransaction => 'Template Transaction';

  @override
  String get doTransaction => 'Do Transaction';

  @override
  String get confirmTransaction => 'Confirm Transaction';

  @override
  String doTransactionConfirmationMessage(String title) {
    return 'Do you want to execute \"$title\" transaction? This will make it count towards your actual balance.';
  }

  @override
  String get transactionExecutedSuccessfully =>
      'Transaction executed successfully';

  @override
  String get addAsTransaction => 'Add as Transaction';

  @override
  String createFromTemplateMessage(String title) {
    return 'Create a new transaction from \"$title\" template?';
  }

  @override
  String get transactionCreatedFromTemplate =>
      'Transaction created from template';

  @override
  String get selectAccount => 'Select Account';

  @override
  String get primary => 'Primary';

  @override
  String get accounts => 'Accounts';

  @override
  String get budgets => 'Budgets';

  @override
  String get showTransactions => 'Show Transactions';

  @override
  String get showTemplates => 'Show Templates';

  @override
  String get settings => 'Settings';

  @override
  String get noAccountsYet => 'No accounts yet';

  @override
  String get createAccountToGetStarted =>
      'Create an account to start tracking your transactions';

  @override
  String get create => 'Create';

  @override
  String get pleaseEnterTitle => 'Please enter a title';

  @override
  String get pleaseEnterAmount => 'Please enter an amount';

  @override
  String get pleaseEnterValidNumber => 'Please enter a valid number';

  @override
  String get pleaseSelectAccount => 'Please select an account';

  @override
  String get pleaseSelectDestinationAccount =>
      'Please select a destination account';

  @override
  String get pleaseEnterExchangeRate => 'Please enter an exchange rate';

  @override
  String get budgetCreatedSuccessfully => 'Budget created successfully';

  @override
  String get budgetTitle => 'Budget Title';

  @override
  String get enterBudgetName => 'Enter budget name';

  @override
  String get pleaseEnterBudgetTitle => 'Please enter a budget title';

  @override
  String get createNewBudget => 'Create New Budget';

  @override
  String get createBudget => 'Create Budget';

  @override
  String get currencyUpdatedSuccessfully => 'Currency updated successfully';

  @override
  String get selectCurrency => 'Select Currency';

  @override
  String get currency => 'Currency';

  @override
  String get language => 'Language';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get english => 'English';

  @override
  String get french => 'French';

  @override
  String get danish => 'Danish';

  @override
  String get languageUpdatedSuccessfully => 'Language updated successfully';

  @override
  String get accountName => 'Account Name';

  @override
  String get bankName => 'Bank Name';

  @override
  String get initialBalance => 'Initial Balance';

  @override
  String get setAsPrimaryAccount => 'Set as Primary Account';

  @override
  String get primaryAccountDescription =>
      'The primary account is shown by default on the dashboard';

  @override
  String get saveAccount => 'Save Account';

  @override
  String get updateAccount => 'Update Account';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get deleteAccountConfirmation =>
      'Are you sure you want to delete this account? This action cannot be undone.';

  @override
  String get pleaseEnterAccountName => 'Please enter an account name';

  @override
  String get pleaseEnterBankName => 'Please enter a bank name';

  @override
  String get pleaseEnterInitialBalance => 'Please enter an initial balance';

  @override
  String get exampleCheckingAccount => 'e.g., Checking Account, Savings';

  @override
  String get exampleBankName => 'e.g., Bank of America, Chase';

  @override
  String get currentBalanceDescription => 'Current balance in this account';

  @override
  String get editAccount => 'Edit Account';

  @override
  String get addAccount => 'Add Account';

  @override
  String get totalBalance => 'Total Balance';

  @override
  String get noBudgetsYet => 'No budgets yet';

  @override
  String get selected => 'Selected';

  @override
  String get budgetActions => 'Budget Actions';

  @override
  String get editBudget => 'Edit Budget';

  @override
  String get deleteBudget => 'Delete Budget';

  @override
  String get duplicateBudget => 'Duplicate Budget';

  @override
  String deleteBudgetConfirmation(String title) {
    return 'Are you sure you want to delete \"$title\"? This will also delete all budget transactions. This action cannot be undone.';
  }

  @override
  String get budgetDeletedSuccessfully => 'Budget deleted successfully';

  @override
  String get budgetUpdatedSuccessfully => 'Budget updated successfully';

  @override
  String get budgetDuplicatedSuccessfully => 'Budget duplicated successfully';

  @override
  String get cannotDeleteBudgetWithTransactions =>
      'Cannot delete budget. There are transactions linked to this budget\'s items. Please remove those transactions first.';

  @override
  String duplicateOf(String title) {
    return 'Duplicate of $title';
  }

  @override
  String get saveBudget => 'Save Budget';
}
