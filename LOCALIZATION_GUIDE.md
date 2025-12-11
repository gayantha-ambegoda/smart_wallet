# Localization (i18n) Implementation Guide

## Overview
The Smart Wallet app now supports internationalization (i18n) with English (en-US) as the default language. The app is configured to use the system language with automatic fallback to English if the requested language is not available.

## Setup and Configuration

### 1. Dependencies Added
- `flutter_localizations` (SDK)
- `intl: ^0.19.0`

### 2. Files Created
- `l10n.yaml` - Configuration file for Flutter's localization generation
- `lib/l10n/app_en.arb` - English (US) translation strings

### 3. Configuration in pubspec.yaml
```yaml
flutter:
  generate: true
```

### 4. Main App Configuration
The `main.dart` file has been updated to include:
```dart
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// In MaterialApp:
localizationsDelegates: const [
  AppLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
],
supportedLocales: const [
  Locale('en', 'US'), // English
],
```

## How to Generate Localization Files

Before running the app, you must generate the localization files:

```bash
flutter pub get
flutter gen-l10n
```

This will generate the necessary Dart files in `.dart_tool/flutter_gen/gen_l10n/`.

## Using Localized Strings in Code

### Import the localizations
```dart
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
```

### Access localized strings
```dart
final l10n = AppLocalizations.of(context)!;

Text(l10n.appTitle)  // Displays "Smart Wallet"
Text(l10n.addTransaction)  // Displays "Add Transaction"
```

## Available Localization Keys

The following keys are available in `lib/l10n/app_en.arb`:

### App-level
- `appTitle` - "Smart Wallet"
- `dashboard` - "Dashboard"
- `templates` - "Templates"
- `settings` - "Settings"

### Balance & Transactions
- `availableBalance` - "Available Balance"
- `totalIncome` - "Total Income"
- `totalExpense` - "Total Expense"
- `recentTransactions` - "Recent Transactions"
- `transaction` - "Transaction"
- `transfer` - "Transfer"

### Transaction Types
- `income` - "Income"
- `expense` - "Expense"

### Form Fields
- `title` - "Title"
- `amount` - "Amount"
- `type` - "Type"
- `fromAccount` - "From Account"
- `toAccount` - "To Account"
- `exchangeRate` - "Exchange Rate"
- `budget` - "Budget"
- `budgetOptional` - "Budget (Optional)"
- `tags` - "Tags"
- `tagsCommaSeparated` - "Tags (comma-separated)"
- `isTemplate` - "Is Template"
- `date` - "Date"

### Actions
- `addTransaction` - "Add Transaction"
- `updateTransaction` - "Update Transaction"
- `saveTransaction` - "Save Transaction"
- `doTransaction` - "Do Transaction"
- `delete` - "Delete"
- `update` - "Update"
- `cancel` - "Cancel"
- `yes` - "Yes"
- `create` - "Create"

### Messages
- `noTransactionsYet` - "No transactions yet"
- `addTransactionToGetStarted` - "Add a transaction to get started"
- `noTemplatesYet` - "No templates yet"
- `createTemplateToGetStarted` - "Create a template to get started"
- `noAccountsYet` - "No accounts yet"
- `createAccountToGetStarted` - "Create an account to start tracking your transactions"

### Validation Errors
- `pleaseEnterTitle` - "Please enter a title"
- `pleaseEnterAmount` - "Please enter an amount"
- `pleaseEnterValidNumber` - "Please enter a valid number"
- `pleaseSelectAccount` - "Please select an account"
- `pleaseSelectDestinationAccount` - "Please select a destination account"
- `pleaseEnterExchangeRate` - "Please enter an exchange rate"

### Dialog Messages
- `confirmDelete` - "Confirm Delete"
- `confirmTransaction` - "Confirm Transaction"
- `addAsTransaction` - "Add as Transaction"
- `selectAccount` - "Select Account"

### Parameterized Messages
- `deleteConfirmationMessage` - Uses `{title}` parameter
- `createFromTemplateMessage` - Uses `{title}` parameter
- `doTransactionConfirmationMessage` - Uses `{title}` parameter

### Success Messages
- `transactionDeletedSuccessfully` - "Transaction deleted successfully"
- `transactionExecutedSuccessfully` - "Transaction executed successfully"
- `transactionCreatedFromTemplate` - "Transaction created from template"

### Labels
- `budgetOnlyTransaction` - "Budget-Only Transaction"
- `templateTransaction` - "Template Transaction"
- `primary` - "Primary"
- `accounts` - "Accounts"
- `budgets` - "Budgets"
- `showTransactions` - "Show Transactions"
- `showTemplates` - "Show Templates"

## Adding New Languages

To add support for additional languages:

1. Create a new ARB file: `lib/l10n/app_<language_code>.arb`
   - Example: `app_es.arb` for Spanish
   - Example: `app_fr.arb` for French

2. Copy all keys from `app_en.arb` and translate the values

3. Update `main.dart` to add the new locale:
```dart
supportedLocales: const [
  Locale('en', 'US'), // English
  Locale('es', ''),   // Spanish
  Locale('fr', ''),   // French
],
```

4. Run `flutter gen-l10n` to generate the new localization files

## Files Updated for Localization

The following files have been updated to use `AppLocalizations`:

1. **lib/pages/add_transaction_page.dart**
   - Form field labels
   - Validation messages
   - Button texts
   - Transaction type labels

2. **lib/widgets/expandable_fab.dart**
   - Action button labels for "Transaction" and "Transfer"

3. **lib/pages/dashboard_page.dart**
   - Account selector dialog title
   - Other UI text elements

## Remaining Work

Some UI files still contain hardcoded strings and can be updated to use localized strings in future iterations:

- `lib/widgets/transaction_details_dialog.dart`
- `lib/pages/budget_list_page.dart`
- `lib/pages/account_list_page.dart`
- `lib/pages/settings_page.dart`
- `lib/widgets/date_filter_card.dart`
- `lib/widgets/modern_transaction_card.dart`

## Testing Localization

1. Generate localization files: `flutter gen-l10n`
2. Run the app: `flutter run`
3. The app will use the device's system language
4. If the system language is not supported, it falls back to English (en-US)

## Best Practices

1. Always use `AppLocalizations.of(context)!` to access strings
2. Add new strings to `app_en.arb` with appropriate descriptions
3. Use placeholders for dynamic content (e.g., `{title}`, `{amount}`)
4. Keep string keys descriptive and consistent
5. Run `flutter gen-l10n` after modifying ARB files
