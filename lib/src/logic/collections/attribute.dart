// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:isar/isar.dart';

part 'attribute.g.dart';

enum AttributeType {
  account,
  incomeType,
  expenseType,
}

@Collection()
class Attribute {
  Attribute({
    this.id = Isar.autoIncrement,
    required this.name,
    required this.type,
  });

  final Id id;
  final String name;
  @enumerated
  final AttributeType type;

  Attribute copyWith({
    Id? id,
    String? name,
    AttributeType? type,
  }) {
    return Attribute(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
    );
  }
}

Future<List<Attribute>> getAttributes(Isar isar, AttributeType type) async {
  final List<Attribute> attributes = await isar.attributes.where().filter().typeEqualTo(type).findAll();
  return attributes;
}
