import 'package:floor/floor.dart';

@entity
class Account {
  @primaryKey
  final int? id;
  final String name;
  final String bankName;
  final String currencyCode;
  final double initialBalance;
  final bool isPrimary;

  Account({
    this.id,
    required this.name,
    required this.bankName,
    required this.currencyCode,
    required this.initialBalance,
    required this.isPrimary,
  });
}
