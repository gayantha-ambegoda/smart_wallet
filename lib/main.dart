import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smartwallet/screen/account_screen.dart';
import 'package:smartwallet/screen/add_transaction_screen.dart';
import 'package:smartwallet/screen/budget_screen.dart';
import 'package:smartwallet/screen/calculator_screen.dart';
import 'package:smartwallet/screen/home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  GoRouter router = GoRouter(routes: [
    GoRoute(path: '/', builder: (context, state) => const Home()),
    GoRoute(path: '/calc', builder: (context, state) => Calculator()),
    GoRoute(
      path: '/account/:accountId',
      builder: (context, state) =>
          AccountScreen(accountId: state.pathParameters['accountId']!),
    ),
    GoRoute(
      path: '/add-trans',
      builder: (context, state) => AddTransactionScreen(),
    ),
    GoRoute(
      path: '/budgets',
      builder: (context, state) => const BudgetScreen(),
    )
  ]);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Smart Wallet',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
