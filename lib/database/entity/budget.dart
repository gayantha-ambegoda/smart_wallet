import 'package:floor/floor.dart';

@entity
class Budget {
  @primaryKey
  final int? id;
  final String title;

  Budget({this.id, required this.title});
}
