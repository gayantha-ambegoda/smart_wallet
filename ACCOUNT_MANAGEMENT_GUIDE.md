# Account Management Feature - Testing Guide

## Overview
This document describes the new account management features added to the Smart Wallet app.

## New Features

### 1. Account Management
- **Create Accounts**: Users can create multiple accounts with different banks and currencies
- **Account Properties**:
  - Name (e.g., "Checking Account", "Savings")
  - Bank Name (e.g., "Bank of America", "Chase")
  - Currency (supports 30+ currencies including USD, EUR, GBP, INR, etc.)
  - Initial Balance
  - Primary Account flag

### 2. Dashboard Account Selector
- The dashboard AppBar now shows the selected account name and bank
- Click on the account name to open a selector modal
- Select any account to view account-specific transactions and balance
- Primary account is automatically selected on app start

### 3. Account-Specific Transactions
- Transactions are now associated with accounts
- Dashboard filters transactions by selected account
- Balance calculations include account's initial balance
- Income/Expense totals are calculated per account

### 4. Transfer Between Accounts
- New transaction type: "Transfer"
- Select source and destination accounts
- Automatic currency conversion support
- Enter exchange rate when transferring between different currencies

### 5. Multi-Currency Support
- Each account can have its own currency
- Transaction amounts displayed in account currency
- Exchange rates tracked for transfers between different currencies

## Database Schema Changes

### Migration from v2 to v3:
1. **New Table: Account**
   - id (INTEGER, PRIMARY KEY)
   - name (TEXT)
   - bankName (TEXT)
   - currencyCode (TEXT)
   - initialBalance (REAL)
   - isPrimary (INTEGER)

2. **Updated Table: Transaction**
   - Added: accountId (INTEGER, FOREIGN KEY)
   - Added: toAccountId (INTEGER, FOREIGN KEY) - for transfers
   - Added: exchangeRate (REAL) - for currency conversion
   - Added: onlyBudget (INTEGER) - flag for budget-specific transactions

3. **New Transaction Type**
   - Added "transfer" to existing income/expense types

## UI Components

### New Pages:
1. **AccountListPage** (`lib/pages/account_list_page.dart`)
   - Lists all accounts with balance and currency
   - Shows primary account badge
   - Navigate to add/edit account page

2. **AddAccountPage** (`lib/pages/add_account_page.dart`)
   - Create new accounts
   - Edit existing accounts
   - Delete accounts
   - Set primary account flag

### Updated Pages:
1. **DashboardPage**
   - Account selector in AppBar
   - Account-specific balance display
   - Filtered transaction list by account
   - Warning banner when no accounts exist

2. **AddTransactionPage**
   - Account selection dropdown (required)
   - Transfer type support
   - Destination account selector for transfers
   - Exchange rate input for cross-currency transfers

### Updated Widgets:
1. **ModernTransactionCard**
   - Display transfer transactions with blue color
   - Show transfer icon (swap horizontal)
   - Handle transfer amount display

## Testing Workflow

### 1. First Time Setup
1. Launch app
2. See "No accounts yet" warning banner
3. Click "Create" or navigate to Accounts via AppBar icon
4. Create your first account (automatically becomes primary)

### 2. Create Multiple Accounts
1. Go to Accounts page
2. Add accounts with different currencies:
   - Checking (USD)
   - Savings (USD)
   - Travel Fund (EUR)
3. Set one as primary

### 3. Add Transactions
1. From dashboard, click "Add Transaction"
2. Select account from dropdown
3. Enter transaction details
4. Choose type: income, expense, or transfer
5. For transfers: select destination account and exchange rate

### 4. View Account Balances
1. Dashboard shows selected account balance
2. Click account name to switch accounts
3. Balance includes initial balance + income - expenses
4. Transfers deduct from source account

### 5. Filter Transactions
1. Select different accounts from dashboard selector
2. View only transactions for that account
3. Use date filters for time-based filtering

## Known Considerations

1. **Account Deletion**: Deleting an account doesn't delete its transactions (they remain orphaned)
2. **Primary Account**: Only one account can be primary at a time
3. **Currency Display**: Dashboard shows currency of selected account
4. **Transfer Logic**: Transfers are recorded in the source account
5. **Budget Support**: Budgets remain separate from accounts (can span multiple accounts)

## API Reference

### AccountProvider Methods:
- `loadAccounts()`: Load all accounts from database
- `addAccount(Account)`: Create new account
- `updateAccountData(Account)`: Update existing account
- `removeAccount(Account)`: Delete account
- `selectAccount(Account)`: Set currently selected account
- `getAccountBalance(int)`: Calculate account balance with transactions

### TransactionDao New Queries:
- `findTransactionsByAccountId(int)`: Get transactions for specific account
- `getTotalIncomeByAccount(int)`: Sum income for account
- `getTotalExpenseByAccount(int)`: Sum expenses for account

## Migration Notes

- The app automatically migrates from database version 2 to 3
- Existing transactions get `accountId` as NULL (need to be assigned to accounts manually)
- The `onlyBudget` column is added with default value 0 for existing transactions
