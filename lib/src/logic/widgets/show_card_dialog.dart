import 'package:fhelper/src/logic/collections/attribute.dart';
import 'package:fhelper/src/logic/collections/card.dart' as fhelper;
import 'package:fhelper/src/logic/widgets/show_attribute_dialog.dart';
import 'package:fhelper/src/widgets/inputfield.dart';
import 'package:fhelper/src/widgets/listchoice.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';

Future<void> showCardForm({
  required BuildContext context,
  fhelper.Card? card,
  Attribute? cardAttribute,
  bool editMode = false,
}) {
  assert(editMode ? card != null : card == null);
  final List<TextEditingController> controller = [
    TextEditingController(),
    TextEditingController(),

    // controller for dialog
    TextEditingController(),
  ];
  final List<String?> displayText = [
    // Statement Closing Date
    null,
    // Payment Due Date,
    null,
    // Account,
    null,
  ];
  int accountId = -1;
  int pdDate = -1;
  int stcDate = -1;

  void cleanForm() {
    accountId = -1;
    stcDate = -1;
    pdDate = -1;
    displayText.fillRange(0, 3, null);
    for (final element in controller) {
      element.clear();
    }
  }

  Future<void> addCard() async {
    final String value = controller[1].text.replaceAll(RegExp('[^0-9]'), '');
    final Isar isar = Isar.getInstance()!;
    final fhelper.Card card = fhelper.Card(
      name: controller[0].text,
      statementClosure: stcDate + 1,
      paymentDue: pdDate + 1,
      limit: double.parse(value) / 100,
      accountId: (await getAttributes(isar, AttributeType.account))[accountId].id,
    );
    await isar.writeTxn(() async {
      await isar.cards.put(card);
    }).then((_) => Navigator.pop(context));
    cleanForm();
  }

  Future<void> editCard(fhelper.Card originalCard) async {
    final Isar isar = Isar.getInstance()!;
    final String value = controller[1].text.replaceAll(RegExp('[^0-9]'), '');
    final fhelper.Card newCard = originalCard.copyWith(
      name: controller[0].text,
      statementClosure: stcDate + 1,
      paymentDue: pdDate + 1,
      limit: double.parse(value) / 100,
      accountId: accountId == -1 ? null : (await getAttributes(isar, AttributeType.account))[accountId].id,
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
    displayText[0] = AppLocalizations.of(context)!.dayOfMonth(card.statementClosure);
    displayText[1] = AppLocalizations.of(context)!.dayOfMonth(card.paymentDue);
    displayText[2] = cardAttribute!.name;
    controller[0].text = card.name;
    controller[1].text = NumberFormat.simpleCurrency(locale: Localizations.localeOf(context).languageCode).format(card.limit);
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
                  title: Text(editMode ? AppLocalizations.of(context)!.edit : AppLocalizations.of(context)!.addCard),
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
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 15),
                            child: InputField(
                              controller: controller[0],
                              label: AppLocalizations.of(context)!.name,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(15),
                              ],
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return AppLocalizations.of(context)!.emptyField;
                                } else if (value.length < 3) {
                                  return AppLocalizations.of(context)!.threeCharactersMinimum;
                                }
                                return null;
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 15),
                            child: InputField(
                              label: AppLocalizations.of(context)!.statementClosing,
                              readOnly: true,
                              placeholder: displayText[0],
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return AppLocalizations.of(context)!.emptyField;
                                }
                                return null;
                              },
                              onTap: () => showModalBottomSheet<void>(
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
                                              AppLocalizations.of(context)!.selectDay,
                                              style: Theme.of(context).textTheme.titleLarge,
                                            ),
                                          ),
                                          ListChoice(
                                            groupValue: stcDate,
                                            onChanged: (value) {
                                              setState(() {
                                                stcDate = value!;
                                              });
                                              Navigator.pop(context);
                                            },
                                            intList: List.generate(31, (index) => index + 1),
                                          )
                                        ],
                                      );
                                    },
                                  );
                                },
                              ).then(
                                (_) => stcDate != -1
                                    ? setState(
                                        () => displayText[0] = AppLocalizations.of(context)!.dayOfMonth(stcDate + 1),
                                      )
                                    : null,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 15),
                            child: InputField(
                              label: AppLocalizations.of(context)!.paymentDue,
                              readOnly: true,
                              placeholder: displayText[1],
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return AppLocalizations.of(context)!.emptyField;
                                }
                                return null;
                              },
                              onTap: () => showModalBottomSheet<void>(
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
                                              AppLocalizations.of(context)!.selectDay,
                                              style: Theme.of(context).textTheme.titleLarge,
                                            ),
                                          ),
                                          ListChoice(
                                            groupValue: pdDate,
                                            onChanged: (value) {
                                              setState(() {
                                                pdDate = value!;
                                              });
                                              Navigator.pop(context);
                                            },
                                            intList: List.generate(31, (index) => index + 1),
                                          )
                                        ],
                                      );
                                    },
                                  );
                                },
                              ).then(
                                (_) => pdDate != -1
                                    ? setState(
                                        () => displayText[1] = AppLocalizations.of(context)!.dayOfMonth(pdDate + 1),
                                      )
                                    : null,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 15),
                            child: InputField(
                              controller: controller[1],
                              label: AppLocalizations.of(context)!.limit,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                CurrencyInputFormatter(
                                  locale: Localizations.localeOf(context).languageCode,
                                )
                              ],
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return AppLocalizations.of(context)!.emptyField;
                                } else if (value.replaceAll(RegExp('[^0-9]'), '') == '000') {
                                  return AppLocalizations.of(context)!.invalidValue;
                                }
                                return null;
                              },
                            ),
                          ),
                          FutureBuilder(
                            future: getAttributes(
                              Isar.getInstance()!,
                              AttributeType.account,
                            ),
                            builder: (context, snapshot) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 15, bottom: 15),
                                child: InputField(
                                  label: AppLocalizations.of(context)!.account(1),
                                  readOnly: true,
                                  placeholder: displayText[2],
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return AppLocalizations.of(context)!.emptyField;
                                    }
                                    return null;
                                  },
                                  onTap: () => showModalBottomSheet<void>(
                                    context: context,
                                    constraints: BoxConstraints(
                                      minHeight: MediaQuery.of(context).size.height / 3,
                                    ),
                                    enableDrag: false,
                                    builder: (context) {
                                      int accountIndex = editMode && snapshot.hasData ? snapshot.data!.indexOf(cardAttribute!) : -1;
                                      return StatefulBuilder(
                                        builder: (context, setState) {
                                          return Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      AppLocalizations.of(context)!.selectAccount,
                                                      style: Theme.of(context).textTheme.titleLarge,
                                                    ),
                                                    TextButton.icon(
                                                      onPressed: () => showAttributeDialog<void>(
                                                        context: context,
                                                        attributeType: AttributeType.account,
                                                        controller: controller[2],
                                                      ).then((_) => controller[2].clear()),
                                                      icon: const Icon(Icons.add),
                                                      label: Text(AppLocalizations.of(context)!.add),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              ListChoice(
                                                groupValue: editMode ? accountIndex : accountId,
                                                onChanged: (value) {
                                                  setState(() {
                                                    if (editMode) {
                                                      accountIndex = value!;
                                                    }
                                                    accountId = value!;
                                                  });
                                                  Navigator.pop(context);
                                                },
                                                attributeList: snapshot.hasData ? snapshot.data! : [],
                                              )
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  ).then(
                                    (_) => accountId != -1
                                        ? setState(
                                            () => displayText[2] = snapshot.hasData ? snapshot.data![accountId].name : null,
                                          )
                                        : null,
                                  ),
                                ),
                              );
                            },
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