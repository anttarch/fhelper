import 'package:fhelper/src/logic/l10n_attributes.dart';
import 'package:fhelper/src/logic/utils.dart' show IntFunctions;
import 'package:flutter/widgets.dart';
import 'package:isar/isar.dart';
import 'package:unorm_dart/unorm_dart.dart' as unorm;

part 'attribute.g.dart';

enum AttributeRole { parent, child }

enum AttributeType { account, incomeType, expenseType }

@immutable
@Collection()
class Attribute {
  const Attribute({
    required this.name,
    required this.role,
    required this.type,
    this.id = Isar.autoIncrement,
    this.parentId,
  }) : assert(
          role == AttributeRole.child ? parentId != null : parentId == null,
          'This child needs a parent',
        );

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

    return other.id == id &&
        other.name == name &&
        other.parentId == parentId &&
        other.role == role &&
        other.type == type;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      parentId.hashCode ^
      role.hashCode ^
      type.hashCode;

  @override
  String toString() {
    //ignore: lines_longer_than_80_chars
    return 'Attribute(id: $id, name: $name, parentId: $parentId, role: $role, type: $type)';
  }
}

/// Maps registred attributes from db
///
/// Will handle roles and l10n strings
Future<Map<Attribute, List<Attribute>>> getAttributes(
  Isar isar,
  AttributeType type, {
  BuildContext? context,
}) async {
  final attributes =
      await isar.attributes.where().filter().typeEqualTo(type).findAll();
  final attributeMap = <Attribute, List<Attribute>>{};
  if (attributes.isNotEmpty) {
    for (final attribute in attributes) {
      Attribute? l10nAttribute;
      // Handle l10n
      if (context != null) {
        // check if the attribute can be translated (default attribute)
        // TODO(antarch): map '#/str#/' attributes correctly
        if (attribute.id.between(0, 23) &&
            context.mounted &&
            attribute.name.contains('#/str#/')) {
          // replaces name with l10n string
          l10nAttribute = attribute.copyWith(
            name: translatedDefaultAttribute(context, attribute.id),
          );
        }
      }

      // Handle roles
      if (attribute.role == AttributeRole.parent) {
        // adds parent to map
        attributeMap.addAll({l10nAttribute ?? attribute: []});
      } else if (attributeMap.keys
          .any((element) => element.id == attribute.parentId)) {
        // get parent
        final parent = attributeMap.keys.singleWhere(
          (element) => element.id == (l10nAttribute ?? attribute).parentId,
        );

        // add child to parent's value on map
        attributeMap.update(parent, (value) {
          final list = <Attribute>[...value, l10nAttribute ?? attribute]
            ..sort((a, b) => unorm.nfd(a.name).compareTo(unorm.nfd(b.name)));
          return value = list;
        });
      }
    }
  }
  return attributeMap;
}

/// Return attribute with provided ID
///
/// Can handle l10n strings (with context)
Future<Attribute?> getAttributeFromId(
  Isar isar,
  int id, {
  BuildContext? context,
}) async {
  final attribute = await isar.attributes.get(id);
  if (context != null &&
      id.between(0, 23) &&
      attribute != null &&
      context.mounted &&
      attribute.name.contains('#/str#/')) {
    return attribute.copyWith(name: translatedDefaultAttribute(context, id));
  }
  return attribute;
}
