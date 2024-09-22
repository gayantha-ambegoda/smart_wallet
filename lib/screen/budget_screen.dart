import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smartwallet/components/account_component.dart';
import 'package:smartwallet/models/account_model.dart';
import 'package:smartwallet/services/database_service.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _budgetState();
}

class _budgetState extends State<BudgetScreen> {
  final DatabaseService _databaseService = DatabaseService.instance;

  TextEditingController accTitleController = TextEditingController();
  TextEditingController accDescController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Budgets"),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        leading: IconButton(
            onPressed: () {
              GoRouter.of(context).go('/');
            },
            icon: const Icon(Icons.arrow_back)),
        actions: [
          IconButton(
              onPressed: () {
                showDialog(context: context, builder: (_) => addAlert(context));
              },
              icon: const Icon(Icons.add))
        ],
      ),
      body: _contentList(),
    );
  }

  Widget _contentList() {
    return FutureBuilder(
        future: _databaseService.getAccounts(3),
        builder: (context, snapshot) {
          if (snapshot.data == null || snapshot.data!.length == 0) {
            return const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Card.filled(
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      child: Text(
                        "No Budgets found!",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                )
              ],
            );
          } else {
            return ListView.builder(
                itemCount: snapshot.data?.length ?? 0,
                itemBuilder: (context, index) {
                  AccountModel _account = snapshot.data![index];
                  return AccountComponent(
                      accTitle: _account.title,
                      accDescription: _account.description,
                      accId: _account.id);
                });
          }
        });
  }

  Widget addAlert(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Budget'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(4),
            child: TextField(
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), hintText: "Title"),
              controller: accTitleController,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(4),
            child: TextField(
              maxLines: 3,
              minLines: 2,
              decoration: const InputDecoration(
                  hintMaxLines: 3,
                  border: OutlineInputBorder(),
                  hintText: "Description"),
              controller: accDescController,
            ),
          ),
          MaterialButton(
            color: Theme.of(context).colorScheme.primary,
            onPressed: () {
              _databaseService.addAccount(
                  accTitleController.text, accDescController.text, 3);
              Navigator.pop(context);
              setState(() {
                //
              });
            },
            child: const Text("Add Budget"),
          )
        ],
      ),
    );
  }
}
