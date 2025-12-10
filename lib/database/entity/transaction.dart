import 'package:floor/floor.dart';
import 'budget.dart';
import 'account.dart';

enum TransactionType { income, expense, transfer }

class TagsConverter extends TypeConverter<List<String>, String> {
  @override
  List<String> decode(String databaseValue) {
    if (databaseValue.isEmpty) return [];
    return databaseValue.split(',');
  }

  @override
  String encode(List<String> value) {
    return value.join(',');
  }
}

class TransactionTypeConverter extends TypeConverter<TransactionType, String> {
  @override
  TransactionType decode(String databaseValue) {
    return TransactionType.values.firstWhere((e) => e.name == databaseValue);
  }

  @override
  String encode(TransactionType value) {
    return value.name;
  }
}

@TypeConverters([TagsConverter, TransactionTypeConverter])
@entity
class Transaction {
  @primaryKey
  final int? id;
  final String title;
  final double amount;
  final int date;
  final List<String> tags;
  final TransactionType type;
  final bool isTemplate;
  final bool onlyBudget;

  @ForeignKey(childColumns: ['budgetId'], parentColumns: ['id'], entity: Budget)
  final int? budgetId;

  @ForeignKey(childColumns: ['accountId'], parentColumns: ['id'], entity: Account)
  final int? accountId;

  // For transfers: the destination account
  @ForeignKey(childColumns: ['toAccountId'], parentColumns: ['id'], entity: Account)
  final int? toAccountId;

  // Exchange rate used for transfer (if different currencies)
  final double? exchangeRate;

  Transaction({
    this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.tags,
    required this.type,
    required this.isTemplate,
    required this.onlyBudget,
    this.budgetId,
    this.accountId,
    this.toAccountId,
    this.exchangeRate,
  });
}
