import 'package:isar/isar.dart';

part 'property.g.dart';

enum PropertyType {
  account,
  incomeType,
  expenseType,
}

@Collection()
class Property {
  Property({
    this.id = Isar.autoIncrement,
    required this.name,
    required this.type,
  });

  final Id id;
  final String name;
  @enumerated
  final PropertyType type;
}
