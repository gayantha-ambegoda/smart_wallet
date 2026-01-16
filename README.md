# SmartWallet

A comprehensive personal finance management application that helps users track accounts, budgets, and transactions across multiple currencies.

## Database Structure

SmartWallet uses a **SQLite database** (via Floor ORM) with the following tables:

### 1. **Account Table**
Stores user bank accounts and financial holdings.

**Fields:**
- `id` (Integer, Primary Key) - Unique identifier for the account
- `name` (String) - Account name (e.g., "Savings Account")
- `bankName` (String) - Associated bank or financial institution name
- `currencyCode` (String) - Currency code for the account (e.g., "USD", "EUR")
- `initialBalance` (Double) - Starting balance for the account
- `isPrimary` (Boolean) - Indicates if this is the primary account

### 2. **Transaction Table**
Records all financial transactions including income, expenses, and transfers.

**Fields:**
- `id` (Integer, Primary Key) - Unique transaction identifier
- `title` (String) - Description of the transaction
- `amount` (Double) - Transaction amount
- `date` (Integer) - Transaction date (timestamp)
- `tags` (List<String>) - Categorization tags for the transaction
- `type` (Enum: income, expense, transfer) - Type of transaction
- `isTemplate` (Boolean) - Whether the transaction is a reusable template
- `onlyBudget` (Boolean) - Whether the transaction is only budgeted (not executed)
- `budgetId` (Foreign Key) - Links to associated budget
- `accountId` (Foreign Key) - Source account for the transaction
- `toAccountId` (Foreign Key) - Destination account (for transfers)
- `exchangeRate` (Double, Optional) - Exchange rate for cross-currency transfers

### 3. **Budget Table**
Stores budget records for tracking spending limits.

**Fields:**
- `id` (Integer, Primary Key) - Unique budget identifier
- `title` (String) - Budget name/category

### 4. **Currency Support**
Built-in support for multiple currencies including:
- USD (US Dollar)
- EUR (Euro)
- GBP (British Pound)
- JPY (Japanese Yen)
- CAD (Canadian Dollar)
- AUD (Australian Dollar)
- INR (Indian Rupee)
- CNY (Chinese Yuan)
- And many more...

---

## Available Features

### 📊 Dashboard
- Overview of account balances and financial health
- Quick access to key metrics and statistics
- Visual representation of financial data

### 💳 Account Management
- **Create and manage multiple accounts** with different currencies
- **View account details** including balance and associated bank
- **Set primary account** for default transactions
- Support for multiple currencies per account

### 💰 Transaction Tracking
- **Record three types of transactions:**
  - Income - Money received
  - Expense - Money spent
  - Transfer - Move funds between accounts
  
- **Transaction features:**
  - Add descriptive titles and amounts
  - Tag transactions for better categorization
  - Save transactions as templates for recurring entries
  - Track both executed and budgeted transactions
  - Support for cross-currency transfers with exchange rate tracking

### 💸 Budget Management
- **Create and manage budgets** for expense control
- **Link transactions to budgets** for tracking
- **View budget details** and spending progress
- **Budget analytics** to monitor financial goals

### ⚙️ Settings
- User preferences and configuration options
- Application settings management

### 🌍 Multi-Language Support
- English (EN)
- Danish (DA)
- French (FR)
- Additional languages can be added via localization files

---

## Building the App

### Quick Build - Android AAB

To build a signed Android App Bundle (AAB) without opening Android Studio:

```cmd
build-aab.bat
```

For detailed instructions on setting up app signing and building for release, see [BUILD_GUIDE.md](BUILD_GUIDE.md).

---

## Project Architecture

- **Database Layer:** SQLite with Floor ORM for type-safe database access
- **Data Access Objects (DAO):** Separate DAOs for Accounts, Budgets, and Transactions
- **Localization:** ARB (Application Resource Bundle) file format for translations
- **Multi-Platform Support:** iOS, Android, Web, Windows, macOS, and Linux
