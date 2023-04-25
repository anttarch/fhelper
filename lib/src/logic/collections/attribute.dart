import 'package:fhelper/src/logic/l10n_attributes.dart';
import 'package:flutter/widgets.dart';
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

Future<List<Attribute>> getAttributes(Isar isar, AttributeType type, {BuildContext? context}) async {
  final List<Attribute> attributes = await isar.attributes.where().filter().typeEqualTo(type).findAll();
  if (attributes.isNotEmpty && context != null) {
    for (final attribute in attributes) {
      if (attribute.id >= 0 && attribute.id <= 14 && context.mounted) {
        final index = attributes.indexOf(attribute);
        final newAttribute = attribute.copyWith(
          name: translatedDefaultAttribute(context, attribute.id),
        );
        attributes.replaceRange(index, index + 1, [newAttribute]);
      }
    }
  }
  return attributes;
}

Future<Attribute?> getAttributeFromId(Isar isar, int id, {BuildContext? context}) async {
  final Attribute? attribute = await isar.attributes.get(id);
  if (context != null && id >= 0 && id <= 14 && attribute != null && context.mounted) {
    return attribute.copyWith(name: translatedDefaultAttribute(context, id));
  }
  return attribute;
}
