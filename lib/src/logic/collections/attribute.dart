import 'package:fhelper/src/logic/l10n_attributes.dart';
import 'package:flutter/widgets.dart';
import 'package:isar/isar.dart';
import 'package:unorm_dart/unorm_dart.dart' as unorm;

part 'attribute.g.dart';

enum AttributeRole {
  parent,
  child,
}

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
    this.parentId,
    required this.role,
    required this.type,
  }) : assert(role == AttributeRole.child ? parentId != null : parentId == null, 'This child needs a parent');

  final Id id;
  final String name;
  final int? parentId;
  @enumerated
  final AttributeRole role;
  @enumerated
  final AttributeType type;

  Attribute copyWith({
    Id? id,
    String? name,
    int? parentId,
    AttributeRole? role,
    AttributeType? type,
  }) {
    return Attribute(
      id: id ?? this.id,
      name: name ?? this.name,
      parentId: parentId ?? this.parentId,
      role: role ?? this.role,
      type: type ?? this.type,
    );
  }

  @override
  bool operator ==(covariant Attribute other) {
    if (identical(this, other)) {
      return true;
    }

    return other.id == id && other.name == name && other.parentId == parentId && other.role == role && other.type == type;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ parentId.hashCode ^ role.hashCode ^ type.hashCode;
}

Future<Map<Attribute, List<Attribute>>> getAttributes(Isar isar, AttributeType type, {BuildContext? context}) async {
  final List<Attribute> attributes = await isar.attributes.where().filter().typeEqualTo(type).findAll();
  final Map<Attribute, List<Attribute>> attributeMap = {};
  if (attributes.isNotEmpty && context != null) {
    // Handles l10n
    for (final attribute in attributes) {
      if (attribute.id >= 0 && attribute.id <= 20 && context.mounted && attribute.name.contains('#/str#/')) {
        final index = attributes.indexOf(attribute);
        final newAttribute = attribute.copyWith(
          name: translatedDefaultAttribute(context, attribute.id),
        );
        attributes.replaceRange(index, index + 1, [newAttribute]);
      }
    }
    // Handle roles
    for (final attr in attributes) {
      if (attr.role == AttributeRole.parent) {
        attributeMap.addAll({attr: []});
      } else {
        final parent = attributeMap.keys.where((element) => element.id == attr.parentId).toList()
          ..sort((a, b) => unorm.nfd(a.name).compareTo(unorm.nfd(b.name)));
        for (final element in parent) {
          attributeMap.update(element, (value) {
            final List<Attribute> list = [...value, attr]..sort((a, b) => unorm.nfd(a.name).compareTo(unorm.nfd(b.name)));
            return value = list;
          });
        }
      }
    }
  }
  return attributeMap;
}

Future<Attribute?> getAttributeFromId(Isar isar, int id, {BuildContext? context}) async {
  final Attribute? attribute = await isar.attributes.get(id);
  if (context != null && id >= 0 && id <= 14 && attribute != null && context.mounted) {
    return attribute.copyWith(name: translatedDefaultAttribute(context, id));
  }
  return attribute;
}
