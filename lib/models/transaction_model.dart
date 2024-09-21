class TransactionModel {
  final int id, fromAcc, toAcc, budget, status;
  final String title, date;
  final double amount;

  TransactionModel(
      {required this.id,
      required this.fromAcc,
      required this.toAcc,
      required this.budget,
      required this.status,
      required this.title,
      required this.date,
      required this.amount});
}
