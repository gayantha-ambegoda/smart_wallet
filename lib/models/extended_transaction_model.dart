class ExtendedTransactionModel {
  final int id, status, fromAcc, toAcc, budget;
  final String fromAccTitle, toAccTitle, budgetTitle;
  final String fromAccDes, toAccDes, budgetDes;
  final String title, date;
  final double amount;

  ExtendedTransactionModel(
      {required this.id,
      required this.fromAcc,
      required this.toAcc,
      required this.budget,
      required this.fromAccTitle,
      required this.toAccTitle,
      required this.budgetTitle,
      required this.fromAccDes,
      required this.toAccDes,
      required this.budgetDes,
      required this.status,
      required this.title,
      required this.date,
      required this.amount});
}
