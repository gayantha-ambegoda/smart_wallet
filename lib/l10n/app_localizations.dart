import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_da.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('da'),
    Locale('en'),
    Locale('fr'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Smart Wallet'**
  String get appTitle;

  /// Dashboard page title
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// Templates page title
  ///
  /// In en, this message translates to:
  /// **'Templates'**
  String get templates;

  /// Label for available balance display
  ///
  /// In en, this message translates to:
  /// **'Available Balance'**
  String get availableBalance;

  /// Label for total income
  ///
  /// In en, this message translates to:
  /// **'Total Income'**
  String get totalIncome;

  /// Label for total expense
  ///
  /// In en, this message translates to:
  /// **'Total Expense'**
  String get totalExpense;

  /// Label for recent transactions section
  ///
  /// In en, this message translates to:
  /// **'Recent Transactions'**
  String get recentTransactions;

  /// Message when no transactions exist
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get noTransactionsYet;

  /// Prompt to add first transaction
  ///
  /// In en, this message translates to:
  /// **'Add a transaction to get started'**
  String get addTransactionToGetStarted;

  /// Message when no templates exist
  ///
  /// In en, this message translates to:
  /// **'No templates yet'**
  String get noTemplatesYet;

  /// Prompt to create first template
  ///
  /// In en, this message translates to:
  /// **'Create a template to get started'**
  String get createTemplateToGetStarted;

  /// Button text to add transaction
  ///
  /// In en, this message translates to:
  /// **'Add Transaction'**
  String get addTransaction;

  /// Button text to update transaction
  ///
  /// In en, this message translates to:
  /// **'Update Transaction'**
  String get updateTransaction;

  /// Label for transaction
  ///
  /// In en, this message translates to:
  /// **'Transaction'**
  String get transaction;

  /// Label for transfer
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get transfer;

  /// Label for incoming transfer
  ///
  /// In en, this message translates to:
  /// **'Transfer In'**
  String get transferIn;

  /// Label for outgoing transfer
  ///
  /// In en, this message translates to:
  /// **'Transfer Out'**
  String get transferOut;

  /// Label for title field
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// Label for amount field
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// Label for type field
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// Label for from account field
  ///
  /// In en, this message translates to:
  /// **'From Account'**
  String get fromAccount;

  /// Label for to account field
  ///
  /// In en, this message translates to:
  /// **'To Account'**
  String get toAccount;

  /// Label for exchange rate field
  ///
  /// In en, this message translates to:
  /// **'Exchange Rate'**
  String get exchangeRate;

  /// Label for budget
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get budget;

  /// Label for optional budget field
  ///
  /// In en, this message translates to:
  /// **'Budget (Optional)'**
  String get budgetOptional;

  /// Label for tags
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get tags;

  /// Label for tags field with instruction
  ///
  /// In en, this message translates to:
  /// **'Tags (comma-separated)'**
  String get tagsCommaSeparated;

  /// Label for template checkbox
  ///
  /// In en, this message translates to:
  /// **'Is Template'**
  String get isTemplate;

  /// Button text to save transaction
  ///
  /// In en, this message translates to:
  /// **'Save Transaction'**
  String get saveTransaction;

  /// Income transaction type
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get income;

  /// Expense transaction type
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expense;

  /// Label for date
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// Button text to delete
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Button text to update
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// Button text to cancel
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Button text to edit
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Button text for yes
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// Confirm delete dialog title
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get confirmDelete;

  /// Delete confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{title}\"? This action cannot be undone.'**
  String deleteConfirmationMessage(String title);

  /// Success message for transaction deletion
  ///
  /// In en, this message translates to:
  /// **'Transaction deleted successfully'**
  String get transactionDeletedSuccessfully;

  /// Label for budget-only transaction
  ///
  /// In en, this message translates to:
  /// **'Budget-Only Transaction'**
  String get budgetOnlyTransaction;

  /// Label for template transaction
  ///
  /// In en, this message translates to:
  /// **'Template Transaction'**
  String get templateTransaction;

  /// Button text to execute transaction
  ///
  /// In en, this message translates to:
  /// **'Do Transaction'**
  String get doTransaction;

  /// Confirm transaction dialog title
  ///
  /// In en, this message translates to:
  /// **'Confirm Transaction'**
  String get confirmTransaction;

  /// Do transaction confirmation message
  ///
  /// In en, this message translates to:
  /// **'Do you want to execute \"{title}\" transaction? This will make it count towards your actual balance.'**
  String doTransactionConfirmationMessage(String title);

  /// Success message for transaction execution
  ///
  /// In en, this message translates to:
  /// **'Transaction executed successfully'**
  String get transactionExecutedSuccessfully;

  /// Dialog title for creating transaction from template
  ///
  /// In en, this message translates to:
  /// **'Add as Transaction'**
  String get addAsTransaction;

  /// Confirmation message for creating transaction from template
  ///
  /// In en, this message translates to:
  /// **'Create a new transaction from \"{title}\" template?'**
  String createFromTemplateMessage(String title);

  /// Success message for transaction created from template
  ///
  /// In en, this message translates to:
  /// **'Transaction created from template'**
  String get transactionCreatedFromTemplate;

  /// Dialog title for account selection
  ///
  /// In en, this message translates to:
  /// **'Select Account'**
  String get selectAccount;

  /// Label for primary account
  ///
  /// In en, this message translates to:
  /// **'Primary'**
  String get primary;

  /// Label for accounts
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get accounts;

  /// Label for budgets
  ///
  /// In en, this message translates to:
  /// **'Budgets'**
  String get budgets;

  /// Tooltip for showing transactions
  ///
  /// In en, this message translates to:
  /// **'Show Transactions'**
  String get showTransactions;

  /// Tooltip for showing templates
  ///
  /// In en, this message translates to:
  /// **'Show Templates'**
  String get showTemplates;

  /// Label for settings
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Message when no accounts exist
  ///
  /// In en, this message translates to:
  /// **'No accounts yet'**
  String get noAccountsYet;

  /// Prompt to create first account
  ///
  /// In en, this message translates to:
  /// **'Create an account to start tracking your transactions'**
  String get createAccountToGetStarted;

  /// Button text to create
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// Validation error for empty title
  ///
  /// In en, this message translates to:
  /// **'Please enter a title'**
  String get pleaseEnterTitle;

  /// Validation error for empty amount
  ///
  /// In en, this message translates to:
  /// **'Please enter an amount'**
  String get pleaseEnterAmount;

  /// Validation error for invalid number
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number'**
  String get pleaseEnterValidNumber;

  /// Validation error for unselected account
  ///
  /// In en, this message translates to:
  /// **'Please select an account'**
  String get pleaseSelectAccount;

  /// Validation error for unselected destination account
  ///
  /// In en, this message translates to:
  /// **'Please select a destination account'**
  String get pleaseSelectDestinationAccount;

  /// Validation error for empty exchange rate
  ///
  /// In en, this message translates to:
  /// **'Please enter an exchange rate'**
  String get pleaseEnterExchangeRate;

  /// Success message for budget creation
  ///
  /// In en, this message translates to:
  /// **'Budget created successfully'**
  String get budgetCreatedSuccessfully;

  /// Label for budget title field
  ///
  /// In en, this message translates to:
  /// **'Budget Title'**
  String get budgetTitle;

  /// Hint text for budget name field
  ///
  /// In en, this message translates to:
  /// **'Enter budget name'**
  String get enterBudgetName;

  /// Validation error for empty budget title
  ///
  /// In en, this message translates to:
  /// **'Please enter a budget title'**
  String get pleaseEnterBudgetTitle;

  /// Title for create new budget page
  ///
  /// In en, this message translates to:
  /// **'Create New Budget'**
  String get createNewBudget;

  /// Button text to create budget
  ///
  /// In en, this message translates to:
  /// **'Create Budget'**
  String get createBudget;

  /// Success message for currency update
  ///
  /// In en, this message translates to:
  /// **'Currency updated successfully'**
  String get currencyUpdatedSuccessfully;

  /// Label for currency selection field
  ///
  /// In en, this message translates to:
  /// **'Select Currency'**
  String get selectCurrency;

  /// Label for currency
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// Label for language
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Label for language selection field
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// English language name
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// French language name
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get french;

  /// Danish language name
  ///
  /// In en, this message translates to:
  /// **'Danish'**
  String get danish;

  /// Success message for language update
  ///
  /// In en, this message translates to:
  /// **'Language updated successfully'**
  String get languageUpdatedSuccessfully;

  /// Label for account name field
  ///
  /// In en, this message translates to:
  /// **'Account Name'**
  String get accountName;

  /// Label for bank name field
  ///
  /// In en, this message translates to:
  /// **'Bank Name'**
  String get bankName;

  /// Label for initial balance field
  ///
  /// In en, this message translates to:
  /// **'Initial Balance'**
  String get initialBalance;

  /// Label for primary account switch
  ///
  /// In en, this message translates to:
  /// **'Set as Primary Account'**
  String get setAsPrimaryAccount;

  /// Description for primary account switch
  ///
  /// In en, this message translates to:
  /// **'The primary account is shown by default on the dashboard'**
  String get primaryAccountDescription;

  /// Button text to save account
  ///
  /// In en, this message translates to:
  /// **'Save Account'**
  String get saveAccount;

  /// Button text to update account
  ///
  /// In en, this message translates to:
  /// **'Update Account'**
  String get updateAccount;

  /// Button text/title to delete account
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// Confirmation message for account deletion
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this account? This action cannot be undone.'**
  String get deleteAccountConfirmation;

  /// Validation error for empty account name
  ///
  /// In en, this message translates to:
  /// **'Please enter an account name'**
  String get pleaseEnterAccountName;

  /// Validation error for empty bank name
  ///
  /// In en, this message translates to:
  /// **'Please enter a bank name'**
  String get pleaseEnterBankName;

  /// Validation error for empty initial balance
  ///
  /// In en, this message translates to:
  /// **'Please enter an initial balance'**
  String get pleaseEnterInitialBalance;

  /// Example text for account name
  ///
  /// In en, this message translates to:
  /// **'e.g., Checking Account, Savings'**
  String get exampleCheckingAccount;

  /// Example text for bank name
  ///
  /// In en, this message translates to:
  /// **'e.g., Bank of America, Chase'**
  String get exampleBankName;

  /// Helper text for initial balance field
  ///
  /// In en, this message translates to:
  /// **'Current balance in this account'**
  String get currentBalanceDescription;

  /// Title for edit account page
  ///
  /// In en, this message translates to:
  /// **'Edit Account'**
  String get editAccount;

  /// Title for add account page
  ///
  /// In en, this message translates to:
  /// **'Add Account'**
  String get addAccount;

  /// Label for total balance
  ///
  /// In en, this message translates to:
  /// **'Total Balance'**
  String get totalBalance;

  /// Message when no budgets exist
  ///
  /// In en, this message translates to:
  /// **'No budgets yet'**
  String get noBudgetsYet;

  /// Label for selected item
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get selected;

  /// Button text to create a transaction from budget transaction
  ///
  /// In en, this message translates to:
  /// **'Create Transaction'**
  String get createTransaction;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['da', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'da':
      return AppLocalizationsDa();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
