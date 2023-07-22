import 'package:fhelper/src/logic/collections/attribute.dart';
import 'package:fhelper/src/logic/widgets/utils.dart' as wid_utils;
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
  assert(
    editMode ? attribute != null : attribute == null,
    editMode
        ? 'An attribute is required for editing'
        : 'An attribute is forbidden when adding',
  );
  assert(
    editMode
        ? attributeType == null && attributeRole == null && parentId == null
        : attributeType != null && attributeRole != null,
    editMode
        ? 'The type, role and parentId are contained in the editing attribute'
        : "The new attribute's type and role are required",
  );
  String? displayText;
  var groupValue = -1;
  int? parentIndex;
  var role = <AttributeRole>{AttributeRole.parent};

  final defaultSubaccounts = <String, bool>{
    AppLocalizations.of(context)!.checkingSubaccount: true,
    AppLocalizations.of(context)!.savingsSubaccount: true,
  };

  return showDialog<T>(
    context: context,
    useSafeArea: false,
    builder: (context) {
      return OrientationBuilder(
        builder: (context, orientation) {
          final formKey = GlobalKey<FormState>();
          if (orientation == Orientation.portrait &&
              (parentId != null || editMode)) {
            return AlertDialog(
              title: Text(
                editMode
                    ? AppLocalizations.of(context)!.edit
                    : AppLocalizations.of(context)!.add,
              ),
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
                      return AppLocalizations.of(context)!
                          .threeCharactersMinimum;
                    } else if (value.contains('#/spt#/') ||
                        value.contains('#/str#/')) {
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
                      final isar = Isar.getInstance()!;
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
                  label: Text(
                    editMode
                        ? AppLocalizations.of(context)!.save
                        : AppLocalizations.of(context)!.add,
                  ),
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
                      title: Text(
                        editMode
                            ? AppLocalizations.of(context)!.edit
                            : AppLocalizations.of(context)!.add,
                      ),
                      leading: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              final isar = Isar.getInstance()!;
                              late Attribute attr;
                              if (editMode) {
                                attr =
                                    attribute!.copyWith(name: controller.text);
                              } else {
                                attr = Attribute(
                                  name: controller.text,
                                  parentId: parentId ?? parentIndex,
                                  role: attributeRole ?? role.single,
                                  type: attributeType!,
                                );
                              }
                              await isar.writeTxn(() async {
                                if (role.single == AttributeRole.parent &&
                                    attributeType == AttributeType.account) {
                                  final parentId =
                                      await isar.attributes.put(attr);

                                  final strBased = <int, String>{
                                    0: '#/str#/checkingString',
                                    1: '#/str#/savingsString',
                                  };
                                  defaultSubaccounts
                                      .forEach((key, value) async {
                                    if (value) {
                                      final subaccount = Attribute(
                                        name: strBased.values.elementAt(
                                          defaultSubaccounts.keys
                                              .toList()
                                              .indexOf(key),
                                        ),
                                        parentId: parentId,
                                        role: AttributeRole.child,
                                        type: AttributeType.account,
                                      );
                                      await isar.attributes.put(subaccount);
                                    }
                                  });
                                } else {
                                  await isar.attributes.put(attr);
                                }
                              }).then((_) => Navigator.pop(context));
                            }
                          },
                          child: Text(
                            editMode
                                ? AppLocalizations.of(context)!.save
                                : AppLocalizations.of(context)!.add,
                          ),
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
                                              ? AppLocalizations.of(context)!
                                                  .account(1)
                                              : AppLocalizations.of(context)!
                                                  .type(1),
                                        ),
                                      ),
                                      ButtonSegment(
                                        value: AttributeRole.child,
                                        label: Text(
                                          attributeType == AttributeType.account
                                              ? AppLocalizations.of(context)!
                                                  .subaccount
                                              : AppLocalizations.of(context)!
                                                  .subtype,
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
                                      return AppLocalizations.of(context)!
                                          .emptyField;
                                    } else if (value.length < 3) {
                                      return AppLocalizations.of(context)!
                                          .threeCharactersMinimum;
                                    } else if (value.contains('#/spt#/') ||
                                        value.contains('#/str#/')) {
                                      return AppLocalizations.of(context)!
                                          .invalidName;
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              if (!editMode &&
                                  role.single == AttributeRole.child)
                                Padding(
                                  padding: const EdgeInsets.only(top: 15),
                                  child: InputField(
                                    label: attributeType ==
                                            AttributeType.account
                                        ? AppLocalizations.of(context)!
                                            .account(1)
                                        : AppLocalizations.of(context)!.type(1),
                                    readOnly: true,
                                    placeholder: displayText ??
                                        AppLocalizations.of(context)!.select,
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return AppLocalizations.of(context)!
                                            .emptyField;
                                      }
                                      return null;
                                    },
                                    onTap: () async {
                                      final isar = Isar.getInstance()!;
                                      final parents = await getAttributes(
                                          isar, attributeType!,
                                          context: context);
                                      final data =
                                          <Attribute, List<Attribute>>{};
                                      for (final element in parents.entries) {
                                        data.addAll(
                                          {element.key: <Attribute>[]},
                                        );
                                      }
                                      if (context.mounted) {
                                        await showModalBottomSheet<String?>(
                                          context: context,
                                          enableDrag: false,
                                          builder: (context) {
                                            return StatefulBuilder(
                                              builder: (context, setState) {
                                                return Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              20),
                                                      child: Text(
                                                        attributeType ==
                                                                AttributeType
                                                                    .account
                                                            ? AppLocalizations
                                                                    .of(
                                                                        context)!
                                                                .selectAccount
                                                            : AppLocalizations
                                                                    .of(context)!
                                                                .selectType,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .titleLarge,
                                                      ),
                                                    ),
                                                    ListChoice(
                                                      groupValue: groupValue,
                                                      onChanged: (name, value) {
                                                        setState(() {
                                                          groupValue =
                                                              value! as int;
                                                        });
                                                        Navigator.pop(
                                                            context, name);
                                                      },
                                                      attributeMap: data,
                                                      attributeListBehavior:
                                                          true,
                                                    )
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                        ).then(
                                          (name) =>
                                              groupValue != -1 && name != null
                                                  ? setState(() {
                                                      displayText = name;
                                                      parentIndex = data.keys
                                                          .elementAt(groupValue)
                                                          .id;
                                                    })
                                                  : null,
                                        );
                                      }
                                    },
                                  ),
                                ),
                              if (!editMode &&
                                  role.single == AttributeRole.parent &&
                                  attributeType == AttributeType.account)
                                Padding(
                                  padding: const EdgeInsets.only(top: 15),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        AppLocalizations.of(context)!
                                            .defaultSubaccounts,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge,
                                      ),
                                      Card(
                                        elevation: 0,
                                        margin: const EdgeInsets.only(top: 5),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          side: BorderSide(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .outlineVariant,
                                          ),
                                        ),
                                        child: ListView.separated(
                                          shrinkWrap: true,
                                          padding: EdgeInsets.zero,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount: defaultSubaccounts.length,
                                          itemBuilder: (context, index) {
                                            return CheckboxListTile(
                                              title: Text(
                                                defaultSubaccounts.keys
                                                    .elementAt(index),
                                              ),
                                              shape: wid_utils.getShapeBorder(
                                                index,
                                                defaultSubaccounts.length - 1,
                                              ),
                                              tileColor: Theme.of(context)
                                                  .colorScheme
                                                  .background,
                                              value: defaultSubaccounts.values
                                                  .elementAt(index),
                                              onChanged: (val) {
                                                setState(() {
                                                  defaultSubaccounts.update(
                                                    defaultSubaccounts.keys
                                                        .elementAt(index),
                                                    (value) => val ?? value,
                                                  );
                                                });
                                              },
                                            );
                                          },
                                          separatorBuilder: (_, __) => Divider(
                                            height: 2,
                                            thickness: 1.5,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .outlineVariant,
                                          ),
                                        ),
                                      ),
                                      Visibility(
                                        visible: !defaultSubaccounts
                                            .containsValue(true),
                                        child: Card(
                                          elevation: 0,
                                          margin:
                                              const EdgeInsets.only(top: 15),
                                          color: Theme.of(context)
                                              .colorScheme
                                              .errorContainer,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            side: BorderSide(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .error,
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: Text.rich(
                                              TextSpan(
                                                children: [
                                                  WidgetSpan(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 5),
                                                      child: Icon(
                                                        Icons.warning_amber,
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .error,
                                                      ),
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text: AppLocalizations.of(
                                                            context)!
                                                        .noSubaccountWarning,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyLarge!
                                                        .apply(
                                                          color: Theme.of(
                                                                  context)
                                                              .colorScheme
                                                              .onErrorContainer,
                                                        ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
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
