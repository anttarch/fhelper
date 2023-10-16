import 'package:fhelper/src/logic/collections/card.dart' as fhelper;
import 'package:fhelper/src/logic/widgets/show_selector_bottom_sheet.dart';
import 'package:fhelper/src/widgets/inputfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';

Future<void> showCardForm({
  required BuildContext context,
  fhelper.Card? card,
  bool editMode = false,
}) {
  assert(
    editMode ? card != null : card == null,
    editMode ? 'Need a card to edit' : 'Cannot add an existing card',
  );
  final controller = <TextEditingController>[
    TextEditingController(),
    TextEditingController(),

    // controller for dialog
    TextEditingController(),
  ];
  final displayText = <String?>[
    // Statement Closing Date
    null,
    // Payment Due Date,
    null,
  ];
  var pdDate = -1;
  var stcDate = -1;
  final localization = AppLocalizations.of(context)!;

  void cleanForm() {
    stcDate = -1;
    pdDate = -1;
    displayText.fillRange(0, 2, null);
    for (final element in controller) {
      element.clear();
    }
  }

  Future<void> addCard() async {
    final value = controller[1].text.replaceAll(RegExp('[^0-9]'), '');
    final isar = Isar.getInstance()!;
    final card = fhelper.Card(
      name: controller[0].text,
      statementClosure: stcDate + 1,
      paymentDue: pdDate + 1,
      limit: double.parse(value) / 100,
    );
    await isar.writeTxn(() async {
      await isar.cards.put(card);
    }).then((_) => Navigator.pop(context));
    cleanForm();
  }

  Future<void> editCard(fhelper.Card originalCard) async {
    final isar = Isar.getInstance()!;
    final value = controller[1].text.replaceAll(RegExp('[^0-9]'), '');
    final newCard = originalCard.copyWith(
      name: controller[0].text,
      statementClosure: stcDate + 1,
      paymentDue: pdDate + 1,
      limit: double.parse(value) / 100,
    );
    await isar.writeTxn(() async {
      await isar.cards.put(newCard);
    }).then((_) {
      Navigator.pop(context);
      cleanForm();
    });
  }

  if (card != null && editMode) {
    stcDate = card.statementClosure - 1;
    pdDate = card.paymentDue - 1;
    displayText[0] = localization.dayOfMonth(card.statementClosure);
    displayText[1] = localization.dayOfMonth(card.paymentDue);
    controller[0].text = card.name;
    controller[1].text = NumberFormat.simpleCurrency(
      locale: Localizations.localeOf(context).languageCode,
    ).format(card.limit);
  }
  return showDialog<void>(
    context: context,
    useSafeArea: false,
    builder: (context) {
      final formKey = GlobalKey<FormState>();
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog.fullscreen(
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  forceElevated: true,
                  title: Text(
                    editMode ? localization.edit : localization.addCard,
                  ),
                  leading: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                      cleanForm();
                    },
                    icon: const Icon(Icons.close),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          if (editMode) {
                            await editCard(card!);
                          } else {
                            await addCard();
                          }
                        }
                      },
                      child: Text(
                        editMode ? localization.save : localization.add,
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
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 15),
                            child: InputField(
                              controller: controller[0],
                              label: localization.name,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(15),
                              ],
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return localization.emptyField;
                                } else if (value.length < 3) {
                                  return localization.threeCharactersMinimum;
                                }
                                return null;
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 15),
                            child: InputField(
                              label: localization.statementClosing,
                              readOnly: true,
                              placeholder:
                                  displayText[0] ?? localization.select,
                              validator: (value) {
                                if (value!.isEmpty || displayText[0] == null) {
                                  return localization.emptyField;
                                }
                                return null;
                              },
                              onTap: () => showSelectorBottomSheet<void>(
                                context: context,
                                groupValue: stcDate,
                                title: localization.selectDay,
                                onSelect: (_, value) {
                                  setState(() {
                                    stcDate = value! as int;
                                  });
                                  Navigator.pop(context);
                                },
                                intList:
                                    List.generate(31, (index) => index + 1),
                              ).then(
                                (_) {
                                  if (stcDate != -1) {
                                    setState(
                                      () => displayText[0] =
                                          localization.dayOfMonth(stcDate + 1),
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 15),
                            child: InputField(
                              label: localization.paymentDue,
                              readOnly: true,
                              placeholder:
                                  displayText[1] ?? localization.select,
                              validator: (value) {
                                if (value!.isEmpty || displayText[1] == null) {
                                  return localization.emptyField;
                                }
                                return null;
                              },
                              onTap: () => showSelectorBottomSheet<void>(
                                context: context,
                                groupValue: pdDate,
                                title: localization.selectDay,
                                onSelect: (_, value) {
                                  setState(() {
                                    pdDate = value! as int;
                                  });
                                  Navigator.pop(context);
                                },
                                intList:
                                    List.generate(31, (index) => index + 1),
                              ).then(
                                (_) {
                                  if (pdDate != -1) {
                                    setState(
                                      () => displayText[1] =
                                          localization.dayOfMonth(pdDate + 1),
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 15),
                            child: InputField(
                              controller: controller[1],
                              label: localization.limit,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                CurrencyInputFormatter(
                                  locale: Localizations.localeOf(context)
                                      .languageCode,
                                ),
                              ],
                              validator: (value) {
                                final parsedValue = value!.replaceAll(
                                  RegExp('[^0-9]'),
                                  '',
                                );
                                if (value.isEmpty) {
                                  return localization.emptyField;
                                } else if (parsedValue == '000') {
                                  return localization.invalidValue;
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
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
