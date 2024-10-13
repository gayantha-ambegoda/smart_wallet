class AccountModel {
  final int id, type;
  final String title, description;

  AccountModel(
      {required this.id,
      required this.type,
      required this.title,
      required this.description});
}

class AccounInExp {
  final int id;
  final String date;
  final double amount;
  AccounInExp({required this.id, required this.date, required this.amount});
}
