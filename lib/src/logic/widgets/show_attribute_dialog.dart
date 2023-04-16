import 'package:fhelper/src/logic/collections/attribute.dart';
import 'package:fhelper/src/widgets/inputfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:isar/isar.dart';

Future<T?> showAttributeDialog<T>({
  required BuildContext context,
  required AttributeType attributeType,
  required TextEditingController controller,
  Attribute? attribute,
  bool editMode = false,
}) {
  assert(editMode ? attribute != null : attribute == null);
  return showDialog<T>(
    context: context,
    useSafeArea: false,
    builder: (context) {
      return OrientationBuilder(
        builder: (context, orientation) {
          final GlobalKey<FormState> formKey = GlobalKey<FormState>();
          if (orientation == Orientation.portrait) {
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
                    } else if (attributeType == AttributeType.account && value.contains('#/spt#/')) {
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
                  icon: const Icon(Icons.add),
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      final Isar isar = Isar.getInstance()!;
                      Attribute attr = Attribute(
                        name: controller.text,
                        type: attributeType,
                      );
                      if (editMode) {
                        attr = attribute!.copyWith(name: controller.text);
                      }
                      await isar.writeTxn(() async {
                        await isar.attributes.put(attr);
                      }).then((_) {
                        Navigator.pop(context);
                        if (editMode) {
                          Navigator.pop(context);
                        }
                      });
                    }
                  },
                  label: Text(editMode ? AppLocalizations.of(context)!.save : AppLocalizations.of(context)!.add),
                ),
              ],
            );
          }
          return Dialog.fullscreen(
            child: CustomScrollView(
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
                          Attribute attr = Attribute(
                            name: controller.text,
                            type: attributeType,
                          );
                          if (editMode) {
                            attr = attribute!.copyWith(name: controller.text);
                          }
                          await isar.writeTxn(() async {
                            await isar.attributes.put(attr);
                          }).then((_) {
                            Navigator.pop(context);
                            if (editMode) {
                              Navigator.pop(context);
                            }
                          });
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
                      child: Padding(
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
                            } else if (attributeType == AttributeType.account && value.contains('#/spt#/')) {
                              return AppLocalizations.of(context)!.invalidName;
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
