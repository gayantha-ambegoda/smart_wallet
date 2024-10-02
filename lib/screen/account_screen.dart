import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smartwallet/models/account_model.dart';
import 'package:smartwallet/models/extended_transaction_model.dart';
import 'package:smartwallet/services/database_service.dart';

class AccountScreen extends StatelessWidget {
  AccountScreen({super.key, required this.accountId});

  final String accountId;
  final DatabaseService _databaseService = DatabaseService.instance;

  TextEditingController transTitleController = TextEditingController();
  TextEditingController amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _databaseService.getAccount(int.parse(accountId)),
        builder: (context, snapshot) {
          AccountModel? accountModel = snapshot.data;

          return Scaffold(
              appBar: AppBar(
                title: Text(accountModel?.title ?? ""),
                leading: IconButton(
                    onPressed: () => GoRouter.of(context).go('/'),
                    icon: const Icon(Icons.arrow_back)),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              body: FutureBuilder(
                  future: _databaseService
                      .getAllExtendedTransactions(int.parse(accountId)),
                  builder: (context, snapshot) {
                    if (snapshot.data == null || snapshot.data!.isEmpty) {
                      return const Text("There are no any tansactions!");
                    } else {
                      return ListView.builder(
                        itemCount: snapshot.data?.length ?? 0,
                        itemBuilder: (context, index) {
                          ExtendedTransactionModel transModel =
                              snapshot.data![index];
                          return accountModel?.type != 3
                              ? _transactionComponent(
                                  context, transModel, int.parse(accountId))
                              : _transactionBudgetComponent(
                                  context, transModel, int.parse(accountId));
                        },
                      );
                    }
                  }));
        });
  }

  Widget _transactionComponent(BuildContext context,
      ExtendedTransactionModel transModel, int thisAccId) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Text(transModel.title),
              Text(transModel.fromAcc == thisAccId
                  ? transModel.toAccTitle
                  : transModel.fromAccTitle),
              Text(transModel.budgetTitle),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(transModel.date.toString()),
                  Text(transModel.amount.toString())
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _transactionBudgetComponent(BuildContext context,
      ExtendedTransactionModel transModel, int thisAccId) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Text(transModel.title),
              Text(transModel.fromAccTitle),
              Text(transModel.toAccTitle),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(transModel.date.toString()),
                  Text(transModel.amount.toString())
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
