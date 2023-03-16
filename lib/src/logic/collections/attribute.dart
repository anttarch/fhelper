import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';

part 'attribute.g.dart';

enum AttributeType {
  account,
  incomeType,
  expenseType,
}

@immutable
@Collection()
class Attribute {
  const Attribute({
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

  @override
  bool operator ==(covariant Attribute other) {
    if (identical(this, other)) {
      return true;
    }

    return other.id == id && other.name == name && other.type == type;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ type.hashCode;
}

Future<List<Attribute>> getAttributes(Isar isar, AttributeType type) async {
  final List<Attribute> attributes = await isar.attributes.where().filter().typeEqualTo(type).findAll();
  return attributes;
}

Future<Attribute?> getAttributeFromId(Isar isar, int id) async {
  final Attribute? attribute = await isar.attributes.get(id);
  return attribute;
}
