import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Calculator extends StatelessWidget {
  Calculator({super.key});

  TextEditingController _totalLoanController = TextEditingController();
  TextEditingController _interestController = TextEditingController();
  TextEditingController _monthsController = TextEditingController();
  TextEditingController _installmentAmount = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Calculator"),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        leading: IconButton(
            onPressed: () {
              GoRouter.of(context).go('/');
            },
            icon: const Icon(Icons.arrow_back)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: TextField(
              decoration: const InputDecoration(
                  label: Text("Total Loan"), border: OutlineInputBorder()),
              controller: _totalLoanController,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: TextField(
              decoration: const InputDecoration(
                  label: Text("Interest"), border: OutlineInputBorder()),
              controller: _interestController,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: TextField(
              decoration: const InputDecoration(
                  label: Text("No of Months"), border: OutlineInputBorder()),
              controller: _monthsController,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: TextField(
              decoration: const InputDecoration(
                  label: Text("Installment Amount"),
                  border: OutlineInputBorder()),
              controller: _installmentAmount,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: FilledButton(
                    onPressed: () => CalculateInstallment(),
                    child: const Text("Installment")),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: OutlinedButton(
                    onPressed: () => CalculateTotalLoan(),
                    child: const Text("Total")),
              )
            ],
          )
        ],
      ),
    );
  }

  void CalculateTotalLoan() {
    var interest = double.parse(_interestController.text);
    var months = double.parse(_monthsController.text);
    var installment = double.parse(_installmentAmount.text);

    assert(interest is double);
    assert(months is double);
    assert(installment is double);

    double monthlyInterestRate = interest / 12;
    monthlyInterestRate = monthlyInterestRate / 100;
    var totalLoan = installment * (pow(1 + monthlyInterestRate, months) - 1);
    totalLoan = totalLoan /
        (monthlyInterestRate * pow(1 + monthlyInterestRate, months));
    _totalLoanController.text = "$totalLoan";
  }

  void CalculateInstallment() {
    var interest = double.parse(_interestController.text);
    var months = double.parse(_monthsController.text);
    var totalLoan = double.parse(_totalLoanController.text);

    assert(interest is double);
    assert(months is double);
    assert(totalLoan is double);

    double monthlyInterestRate = interest / 12;
    monthlyInterestRate = monthlyInterestRate / 100;

    var installmentAmt = totalLoan *
        monthlyInterestRate *
        pow((1 + monthlyInterestRate), months);
    installmentAmt =
        installmentAmt / (pow(1 + monthlyInterestRate, months) - 1);

    _installmentAmount.text = "$installmentAmt";
  }
}
