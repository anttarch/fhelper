import 'package:fhelper/src/logic/collections/attribute.dart';
import 'package:fhelper/src/widgets/inputfield.dart';
import 'package:fhelper/src/widgets/listchoice.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:isar/isar.dart';

Future<T?> showAttributeDialog<T>({
  required BuildContext context,
  required TextEditingController controller,
  Attribute? attribute,
  AttributeRole? attributeRole,
  AttributeType? attributeType,
  bool editMode = false,
  int? parentId,
}) {
  assert(editMode ? attribute != null : attribute == null);
  assert(editMode ? attributeType == null && attributeRole == null && parentId == null : attributeType != null && attributeRole != null);
  String? displayText;
  int groupValue = -1;
  int? parentIndex;
  Set<AttributeRole> role = {AttributeRole.parent};
  return showDialog<T>(
    context: context,
    useSafeArea: false,
    builder: (context) {
      return OrientationBuilder(
        builder: (context, orientation) {
          final GlobalKey<FormState> formKey = GlobalKey<FormState>();
          if (orientation == Orientation.portrait && (parentId != null || editMode)) {
            return AlertDialog(
              title: Text(editMode ? AppLocalizations.of(context)!.edit : AppLocalizations.of(context)!.add),
              icon: Icon(editMode ? Icons.edit : Icons.add),
              content: Form(
                key: formKey,
                child: InputField(
                  controller: controller,
                  label: AppLocalizations.of(context)!.name,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(15),
                  ],
                  validator: (value) {
                    if (value!.isEmpty) {
                      return AppLocalizations.of(context)!.emptyField;
                    } else if (value.length < 3) {
                      return AppLocalizations.of(context)!.threeCharactersMinimum;
                    } else if (value.contains('#/spt#/') || value.contains('#/str#/')) {
                      return AppLocalizations.of(context)!.invalidName;
                    }
                    return null;
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    AppLocalizations.of(context)!.cancel,
                  ),
                ),
                FilledButton.tonalIcon(
                  icon: Icon(editMode ? Icons.save : Icons.add),
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      final Isar isar = Isar.getInstance()!;
                      late Attribute attr;
                      if (editMode) {
                        attr = attribute!.copyWith(name: controller.text);
                      } else {
                        attr = Attribute(
                          name: controller.text,
                          parentId: parentId,
                          role: attributeRole!,
                          type: attributeType!,
                        );
                      }
                      await isar.writeTxn(() async {
                        await isar.attributes.put(attr);
                      }).then((_) => Navigator.pop(context));
                    }
                  },
                  label: Text(editMode ? AppLocalizations.of(context)!.save : AppLocalizations.of(context)!.add),
                ),
              ],
            );
          }
          return Dialog.fullscreen(
            child: StatefulBuilder(
              builder: (context, setState) {
                return CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      pinned: true,
                      forceElevated: true,
                      title: Text(editMode ? AppLocalizations.of(context)!.edit : AppLocalizations.of(context)!.add),
                      leading: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              final Isar isar = Isar.getInstance()!;
                              late Attribute attr;
                              if (editMode) {
                                attr = attribute!.copyWith(name: controller.text);
                              } else {
                                if (parentId != null) {
                                  attr = Attribute(
                                    name: controller.text,
                                    parentId: parentId,
                                    role: attributeRole!,
                                    type: attributeType!,
                                  );
                                } else {
                                  attr = Attribute(
                                    name: controller.text,
                                    parentId: parentIndex,
                                    role: role.single,
                                    type: attributeType!,
                                  );
                                }
                              }
                              await isar.writeTxn(() async {
                                await isar.attributes.put(attr);
                              }).then((_) => Navigator.pop(context));
                            }
                          },
                          child: Text(editMode ? AppLocalizations.of(context)!.save : AppLocalizations.of(context)!.add),
                        ),
                      ],
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Form(
                          key: formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (!editMode)
                                Padding(
                                  padding: const EdgeInsets.only(top: 15),
                                  child: SegmentedButton(
                                    segments: [
                                      ButtonSegment(
                                        value: AttributeRole.parent,
                                        label: Text(
                                          attributeType == AttributeType.account
                                              ? AppLocalizations.of(context)!.account(1)
                                              : AppLocalizations.of(context)!.type(1),
                                        ),
                                      ),
                                      ButtonSegment(
                                        value: AttributeRole.child,
                                        label: Text(
                                          attributeType == AttributeType.account
                                              ? AppLocalizations.of(context)!.subaccount
                                              : AppLocalizations.of(context)!.subtype,
                                        ),
                                      ),
                                    ],
                                    selected: role,
                                    onSelectionChanged: (p0) {
                                      setState(() => role = p0);
                                    },
                                  ),
                                ),
                              Padding(
                                padding: const EdgeInsets.only(top: 15),
                                child: InputField(
                                  controller: controller,
                                  label: AppLocalizations.of(context)!.name,
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(15),
                                  ],
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return AppLocalizations.of(context)!.emptyField;
                                    } else if (value.length < 3) {
                                      return AppLocalizations.of(context)!.threeCharactersMinimum;
                                    } else if (value.contains('#/spt#/') || value.contains('#/str#/')) {
                                      return AppLocalizations.of(context)!.invalidName;
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              if (!editMode && role.single == AttributeRole.child)
                                Padding(
                                  padding: const EdgeInsets.only(top: 15),
                                  child: InputField(
                                    label: attributeType == AttributeType.account
                                        ? AppLocalizations.of(context)!.account(1)
                                        : AppLocalizations.of(context)!.type(1),
                                    readOnly: true,
                                    placeholder: displayText ?? AppLocalizations.of(context)!.select,
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return AppLocalizations.of(context)!.emptyField;
                                      }
                                      return null;
                                    },
                                    onTap: () async {
                                      final isar = Isar.getInstance()!;
                                      final parents = await getAttributes(isar, attributeType!, context: context);
                                      final Map<Attribute, List<Attribute>> data = {};
                                      for (final element in parents.entries) {
                                        data.addAll({element.key: <Attribute>[]});
                                      }
                                      if (context.mounted) {
                                        await showModalBottomSheet<String?>(
                                          context: context,
                                          enableDrag: false,
                                          builder: (context) {
                                            return StatefulBuilder(
                                              builder: (context, setState) {
                                                return Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets.all(20),
                                                      child: Text(
                                                        attributeType == AttributeType.account
                                                            ? AppLocalizations.of(context)!.selectAccount
                                                            : AppLocalizations.of(context)!.selectType,
                                                        style: Theme.of(context).textTheme.titleLarge,
                                                      ),
                                                    ),
                                                    ListChoice(
                                                      groupValue: groupValue,
                                                      onChanged: (name, value) {
                                                        setState(() {
                                                          groupValue = value! as int;
                                                        });
                                                        Navigator.pop(context, name);
                                                      },
                                                      attributeMap: data,
                                                      attributeListBehavior: true,
                                                    )
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                        ).then(
                                          (name) => groupValue != -1 && name != null
                                              ? setState(() {
                                                  displayText = name;
                                                  parentIndex = data.keys.elementAt(groupValue).id;
                                                })
                                              : null,
                                        );
                                      }
                                    },
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      );
    },
  );
}
