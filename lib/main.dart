import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:floor/floor.dart';
import 'database/app_database.dart';
import 'providers/transaction_provider.dart';
import 'providers/budget_provider.dart';
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
