import 'package:floor/floor.dart';
import 'budget.dart';

enum BudgetTransactionType { income, expense }

class BudgetTransactionTypeConverter extends TypeConverter<BudgetTransactionType, String> {
  @override
  BudgetTransactionType decode(String databaseValue) {
    return BudgetTransactionType.values.firstWhere((e) => e.name == databaseValue);
  }

  @override
  String encode(BudgetTransactionType value) {
    return value.name;
  }
}

class BudgetTagsConverter extends TypeConverter<List<String>, String> {
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

@TypeConverters([BudgetTagsConverter, BudgetTransactionTypeConverter])
@entity
class BudgetTransaction {
  @primaryKey
  final int? id;
  final String title;
  final double amount;
  final int date;
  final List<String> tags;
  final BudgetTransactionType type;

  @ForeignKey(childColumns: ['budgetId'], parentColumns: ['id'], entity: Budget)
  final int budgetId;

  BudgetTransaction({
    this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.tags,
    required this.type,
    required this.budgetId,
  });
}
