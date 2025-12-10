import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:floor/floor.dart';
import 'database/app_database.dart';
import 'providers/transaction_provider.dart';
import 'providers/budget_provider.dart';
import 'providers/account_provider.dart';
import 'pages/dashboard_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final database =
      await $FloorAppDatabase.databaseBuilder('app_database.db').addMigrations([
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
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: const DashboardPage(),
      ),
    );
  }
}
