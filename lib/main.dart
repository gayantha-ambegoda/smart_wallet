import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:floor/floor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database/app_database.dart';
import 'providers/transaction_provider.dart';
import 'providers/budget_provider.dart';
import 'providers/account_provider.dart';
import 'pages/dashboard_page.dart';
import '../l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Enable edge-to-edge display for Android 15+ compatibility
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
  );
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );

  final database = await $FloorAppDatabase.databaseBuilder('app_database.db').addMigrations([
    Migration(1, 2, (database) async {
      await database.execute('DROP TABLE IF EXISTS `Transaction`');
      await database.execute('''
            CREATE TABLE IF NOT EXISTS `Transaction` (
              `id` INTEGER PRIMARY KEY AUTOINCREMENT,
              `title` TEXT NOT NULL,
              `amount` REAL NOT NULL,
              `date` INTEGER NOT NULL,
              `tags` TEXT NOT NULL,
              `type` TEXT NOT NULL,
              `isTemplate` INTEGER NOT NULL,
              `budgetId` INTEGER,
              FOREIGN KEY (`budgetId`) REFERENCES `Budget` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION
            )
          ''');
    }),
    Migration(2, 3, (database) async {
      // Create Account table
      await database.execute('''
            CREATE TABLE IF NOT EXISTS `Account` (
              `id` INTEGER PRIMARY KEY AUTOINCREMENT,
              `name` TEXT NOT NULL,
              `bankName` TEXT NOT NULL,
              `currencyCode` TEXT NOT NULL,
              `initialBalance` REAL NOT NULL,
              `isPrimary` INTEGER NOT NULL
            )
          ''');

      // Add account-related columns to Transaction table
      // Use try-catch to handle cases where columns already exist
      try {
        await database.execute(
          'ALTER TABLE `Transaction` ADD COLUMN `accountId` INTEGER',
        );
      } catch (e) {
        print('Column accountId might already exist: $e');
      }

      try {
        await database.execute(
          'ALTER TABLE `Transaction` ADD COLUMN `toAccountId` INTEGER',
        );
      } catch (e) {
        print('Column toAccountId might already exist: $e');
      }

      try {
        await database.execute(
          'ALTER TABLE `Transaction` ADD COLUMN `exchangeRate` REAL',
        );
      } catch (e) {
        print('Column exchangeRate might already exist: $e');
      }

      try {
        await database.execute(
          'ALTER TABLE `Transaction` ADD COLUMN `onlyBudget` INTEGER DEFAULT 0',
        );
      } catch (e) {
        print('Column onlyBudget might already exist: $e');
      }

      // Check if there are any transactions without an account
      final transactionsWithoutAccount = await database.rawQuery(
        'SELECT COUNT(*) as count FROM `Transaction` WHERE accountId IS NULL',
      );
      final count = transactionsWithoutAccount.first['count'] as int;

      if (count > 0) {
        print(
          'Found $count transactions without account. Creating default account...',
        );

        // Get default currency from settings or use USD as fallback
        String defaultCurrency = 'USD';
        try {
          final prefs = await SharedPreferences.getInstance();
          defaultCurrency = prefs.getString('currency_code') ?? 'USD';
        } catch (e) {
          print('Could not load currency preference, using USD: $e');
        }

        // Check if a default account already exists
        final existingDefaultAccount = await database.rawQuery(
          'SELECT id FROM `Account` WHERE name = "Default Account" AND bankName = "System" LIMIT 1',
        );

        int defaultAccountId;

        if (existingDefaultAccount.isEmpty) {
          // Create a default account for orphaned transactions
          await database.execute(
            '''
                INSERT INTO `Account` (name, bankName, currencyCode, initialBalance, isPrimary)
                VALUES ('Default Account', 'System', ?, 0.0, 1)
              ''',
            [defaultCurrency],
          );

          // Get the ID of the newly created account
          final defaultAccountResult = await database.rawQuery(
            'SELECT id FROM `Account` WHERE name = "Default Account" AND bankName = "System" ORDER BY id DESC LIMIT 1',
          );

          defaultAccountId = defaultAccountResult.first['id'] as int;
          print(
            'Created default account (ID: $defaultAccountId) with currency: $defaultCurrency',
          );
        } else {
          defaultAccountId = existingDefaultAccount.first['id'] as int;
          print('Using existing default account (ID: $defaultAccountId)');
        }

        // Update all transactions without an account to use the default account
        await database.execute(
          'UPDATE `Transaction` SET accountId = ? WHERE accountId IS NULL',
          [defaultAccountId],
        );

        print('Assigned $count transactions to default account');
      }
    }),
  ]).build();

  runApp(MyApp(database: database));
}

class MyApp extends StatelessWidget {
  final AppDatabase database;

  const MyApp({super.key, required this.database});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => TransactionProvider(database),
        ),
        ChangeNotifierProvider(create: (context) => BudgetProvider(database)),
        ChangeNotifierProvider(create: (context) => AccountProvider(database)),
      ],
      child: MaterialApp(
        title: 'Smart Wallet',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        themeMode: ThemeMode.system,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const DashboardPage(),
      ),
    );
  }
}
