import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smartwallet/services/database_service.dart';

class AddTransactionScreen extends StatelessWidget {
  AddTransactionScreen({super.key});

  final TextEditingController transTitleController = TextEditingController();
  final TextEditingController transAmtController = TextEditingController();

  int toAccountData = 0;
  int fromAccountData = 0;
  int budgetAccountData = 0;

  final DatabaseService _databaseService = DatabaseService.instance;

  @override
  Widget build(BuildContext context) {
    const snackbar =
        SnackBar(content: Text('Some Required Fields are missing!'));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Transaction"),
        leading: IconButton(
            onPressed: () => GoRouter.of(context).go('/'),
            icon: const Icon(Icons.arrow_back)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: TextField(
              decoration: const InputDecoration(
                  label: Text("Transaction Title"),
                  border: OutlineInputBorder()),
              controller: transTitleController,
            ),
          ),
          Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: FutureBuilder(
                  future: _databaseService.getAllAccounts(),
                  builder: (context, sapshot) {
                    return sapshot.hasData
                        ? DropdownMenu(
                            width: MediaQuery.of(context).size.width,
                            label: const Text("From Account"),
                            onSelected: (value) {
                              if (value != null) {
                                fromAccountData = value;
                              }
                            },
                            dropdownMenuEntries: sapshot.data!
                                .map<DropdownMenuEntry<int>>((item) {
                              return DropdownMenuEntry(
                                  label: item.title,
                                  value: item.id,
                                  leadingIcon: Icon(item.type == 1
                                      ? Icons.account_balance_wallet
                                      : Icons.category));
                            }).toList(),
                          )
                        : const Text("Loading...");
                  })),
          Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: FutureBuilder(
                  future: _databaseService.getAllAccounts(),
                  builder: (context, sapshot) {
                    return sapshot.hasData
                        ? DropdownMenu(
                            width: MediaQuery.of(context).size.width,
                            label: const Text("To Account"),
                            onSelected: (account) {
                              if (account != null) {
                                toAccountData = account;
                              }
                            },
                            dropdownMenuEntries: sapshot.data!
                                .map<DropdownMenuEntry<int>>((item) {
                              return DropdownMenuEntry(
                                  label: item.title,
                                  value: item.id,
                                  leadingIcon: Icon(item.type == 1
                                      ? Icons.account_balance_wallet
                                      : Icons.category));
                            }).toList(),
                          )
                        : const Text("Loading...");
                  })),
          Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: FutureBuilder(
                  future: _databaseService.getAccounts(3),
                  builder: (context, sapshot) {
                    return sapshot.hasData
                        ? DropdownMenu(
                            width: MediaQuery.of(context).size.width,
                            label: const Text("Budget"),
                            onSelected: (value) {
                              if (value != null) {
                                budgetAccountData = value;
                              }
                            },
                            dropdownMenuEntries: sapshot.data!
                                .map<DropdownMenuEntry<int>>((item) {
                              return DropdownMenuEntry(
                                  label: item.title,
                                  value: item.id,
                                  leadingIcon: Icon(item.type == 1
                                      ? Icons.account_balance_wallet
                                      : Icons.category));
                            }).toList(),
                          )
                        : const Text("Loading...");
                  })),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: TextField(
              decoration: const InputDecoration(
                  label: Text("Transaction Amount"),
                  border: OutlineInputBorder()),
              controller: transAmtController,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: FilledButton(
                    onPressed: () {
                      var date = DateTime.now();
                      if (transAmtController.text == "" ||
                          transTitleController.text == "") {
                        ScaffoldMessenger.of(context).showSnackBar(snackbar);
                      } else {
                        double amount = double.parse(transAmtController.text);

                        _databaseService.addTransaction(
                            transTitleController.text,
                            '${date.year}/${date.month}/${date.day}',
                            fromAccountData,
                            toAccountData,
                            budgetAccountData,
                            amount);
                        transTitleController.clear();
                        transAmtController.clear();
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Successfully Inserted!")));
                      }
                    },
                    child: const Text("Save")),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: OutlinedButton(
                    onPressed: () {}, child: const Text("Clear")),
              )
            ],
          )
        ],
      ),
    );
  }
}
