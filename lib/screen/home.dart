import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smartwallet/components/account_component.dart';
import 'package:smartwallet/components/category_component.dart';
import 'package:smartwallet/models/account_model.dart';
import 'package:smartwallet/services/database_service.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final DatabaseService _databaseService = DatabaseService.instance;

  TextEditingController accTitleController = TextEditingController();
  TextEditingController accDescController = TextEditingController();

  TextEditingController catTitleController = TextEditingController();
  TextEditingController catDescController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Smart Wallet"),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          IconButton(
              onPressed: () {
                GoRouter.of(context).go('/add-trans');
              },
              icon: const Icon(Icons.add)),
          IconButton(
              onPressed: () {
                GoRouter.of(context).go('/calc');
              },
              icon: const Icon(Icons.calculate)),
          IconButton(
              onPressed: () {
                GoRouter.of(context).go('/budgets');
              },
              icon: Icon(Icons.bar_chart_rounded))
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Padding(
                padding: EdgeInsets.all(4),
                child: Text(
                  "Accounts",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4),
                child: IconButton(
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                                title: const Text('Add Account'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(4),
                                      child: TextField(
                                        decoration: const InputDecoration(
                                            border: OutlineInputBorder(),
                                            hintText: "Title"),
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
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      onPressed: () {
                                        _databaseService.addAccount(
                                            accTitleController.text,
                                            accDescController.text,
                                            1);
                                        Navigator.pop(context);
                                        setState(() {
                                          ///
                                        });
                                      },
                                      child: const Text("Add Account"),
                                    )
                                  ],
                                ),
                              ));
                    },
                    icon: const Icon(Icons.add)),
              )
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 0, horizontal: 4),
            child: const Text("Accounts are your wallets."),
          ),
          SizedBox(
            height: 120,
            child: _accountList(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Padding(
                padding: EdgeInsets.all(4),
                child: Text(
                  "Categories",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4),
                child: IconButton(
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                                title: const Text('Add Category'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(4),
                                      child: TextField(
                                        decoration: const InputDecoration(
                                            border: OutlineInputBorder(),
                                            hintText: "Title"),
                                        controller: catTitleController,
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
                                        controller: catDescController,
                                      ),
                                    ),
                                    MaterialButton(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      onPressed: () {
                                        _databaseService.addAccount(
                                            catTitleController.text,
                                            catDescController.text,
                                            2);
                                        Navigator.pop(context);
                                        setState(() {
                                          ///
                                        });
                                      },
                                      child: const Text("Add Category"),
                                    )
                                  ],
                                ),
                              ));
                    },
                    icon: const Icon(Icons.add)),
              )
            ],
          ),
          // const Padding(
          //   padding: EdgeInsets.all(8),
          //   child: CategoryComponent(),
          // )
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 0, horizontal: 4),
            child: Text("Categories are other entities"),
          ),
          _categoryList()
        ],
      ),
    );
  }

  Widget _accountList() {
    return FutureBuilder(
        future: _databaseService.getAccounts(1),
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
                        "No Accounts found!",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                )
              ],
            );
          } else {
            return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: snapshot.data?.length ?? 0,
                itemBuilder: (context, index) {
                  AccountModel _account = snapshot.data![index];
                  return AccountComponent(
                      accTitle: _account.title,
                      accId: _account.id,
                      accDescription: _account.description);
                });
          }
        });
  }

  Widget _categoryList() {
    return FutureBuilder(
        future: _databaseService.getAccounts(2),
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
                        "No Categories found!",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                )
              ],
            );
          } else {
            return Expanded(
                child: Padding(
              padding: EdgeInsets.all(4),
              child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: snapshot.data?.length ?? 0,
                  itemBuilder: (context, index) {
                    AccountModel _account = snapshot.data![index];
                    return CategoryComponent(
                        accId: _account.id,
                        accTitle: _account.title,
                        accDescription: _account.description);
                  }),
            ));
          }
        });
  }
}
