import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AccountComponent extends StatelessWidget {
  const AccountComponent(
      {super.key,
      required this.accTitle,
      required this.accDescription,
      required this.accId});

  final String accTitle, accDescription;
  final int accId;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 225,
      child: GestureDetector(
        onTap: () => GoRouter.of(context).go('/account/$accId'),
        child: Card(
          child: Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                children: [
                  Text(accTitle),
                  Text(accDescription),
                  //Text("Rs 120000.00")
                ],
              )),
        ),
      ),
    );
  }
}
