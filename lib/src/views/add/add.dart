import 'package:dynamic_color/dynamic_color.dart';
import 'package:fhelper/src/logic/collections/attribute.dart';
import 'package:fhelper/src/logic/collections/card.dart' as fhelper;
import 'package:fhelper/src/logic/collections/card_bill.dart';
import 'package:fhelper/src/logic/collections/exchange.dart';
import 'package:fhelper/src/logic/widgets/show_attribute_dialog.dart';
import 'package:fhelper/src/logic/widgets/show_card_dialog.dart';
import 'package:fhelper/src/logic/widgets/show_selector_bottom_sheet.dart';
import 'package:fhelper/src/widgets/inputfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';

class AddView extends StatefulWidget {
  const AddView({super.key});

  @override
  State<AddView> createState() => _AddViewState();
}

class _AddViewState extends State<AddView> {
  Set<EType> _eType = {EType.income};
  (int parentIndex, int childIndex) _typeId = (-1, -1);
  (int parentIndex, int childIndex) _accountId = (-1, -1);
  int _cardIndex = -1;
  int _installments = 0;
  double _availabeLimit = 0;
  final List<String?> displayText = [
    // Date
    DateTime.now().toString(),
    // Type,
    null,
    // Account,
    null,
    // Card
    null,
    // Installments
    '1',
  ];
  final List<TextEditingController> textController = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),

    // controller for dialog
    TextEditingController(),
  ];

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    for (final element in textController) {
      element.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final languageCode = Localizations.localeOf(context).languageCode;
    return Scaffold(
      body: GestureDetector(
        onHorizontalDragUpdate: (details) {
          if (details.delta.dx < 0 && _eType != {EType.expense}) {
            setState(() {
              _eType = {EType.expense};
            });
          } else if (details.delta.dx > 0 && _eType != {EType.income}) {
            setState(() {
              _eType = {EType.income};
            });
          }
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar.medium(
              title: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  localization.add,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                color: Theme.of(context).colorScheme.background,
                child: SegmentedButton(
                  segments: [
                    ButtonSegment(
                      value: EType.income,
                      label: Text(localization.income),
                    ),
                    ButtonSegment(
                      value: EType.expense,
                      label: Text(localization.expense),
                    ),
                  ],
                  selected: _eType,
                  onSelectionChanged: (p0) {
                    _formKey.currentState!.reset();
                    setState(() {
                      _eType = p0;
                      _typeId = (-1, -1);
                      _accountId = (-1, -1);
                      _cardIndex = -1;
                      displayText[0] = DateTime.now().toString();
                    });
                    displayText.fillRange(1, 4, null);
                    for (final element in textController) {
                      element.clear();
                    }
                  },
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 24),
                        child: InputField(
                          controller: textController[0],
                          label: localization.description,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(20),
                          ],
                          validator: (value) {
                            if (value!.isEmpty) {
                              return localization.emptyField;
                            } else if (value.length < 3) {
                              return localization.threeCharactersMinimum;
                            } else if (value.contains('#/spt#/')) {
                              return localization.invalidName;
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: InputField(
                          controller: textController[1],
                          label: _eType.single == EType.income
                              ? localization.amount
                              : localization.price,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            CurrencyInputFormatter(
                              locale: languageCode,
                            )
                          ],
                          validator: (value) {
                            final price = textController[1]
                                .text
                                .replaceAll(RegExp('[^0-9]'), '');
                            if (value!.isEmpty) {
                              return localization.emptyField;
                            } else if (value.replaceAll(RegExp('[^0-9]'), '') ==
                                '000') {
                              return localization.invalidValue;
                            } else if (_cardIndex != -1 &&
                                double.parse(price) / 100 > _availabeLimit) {
                              return localization.insufficientLimit;
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: InputField(
                          label: localization.date,
                          readOnly: true,
                          placeholder: DateTime.now()
                                      .difference(
                                        DateTime.parse(displayText[0]!),
                                      )
                                      .inHours <
                                  24
                              ? DateFormat.yMd(
                                  languageCode,
                                )
                                  .add_jm()
                                  .format(DateTime.parse(displayText[0]!))
                              : DateFormat.yMd(
                                  languageCode,
                                ).format(DateTime.parse(displayText[0]!)),
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.parse(displayText[0]!),
                              firstDate: DateTime(
                                DateTime.now().year,
                                DateTime.now().month,
                              ),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) {
                              setState(
                                () {
                                  if (DateTime.now()
                                          .difference(picked)
                                          .inHours <
                                      24) {
                                    displayText[0] = DateTime.now().toString();
                                  } else {
                                    displayText[0] = picked.toString();
                                  }
                                },
                              );
                            }
                          },
                        ),
                      ),
                      FutureBuilder(
                        future: getAttributes(
                          Isar.getInstance()!,
                          _eType.single == EType.income
                              ? AttributeType.incomeType
                              : AttributeType.expenseType,
                          context: context,
                        ),
                        builder: (context, snapshot) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: InputField(
                              label: localization.type(1),
                              readOnly: true,
                              placeholder:
                                  displayText[1] ?? localization.select,
                              validator: (value) {
                                if (value!.isEmpty || displayText[1] == null) {
                                  return localization.emptyField;
                                }
                                return null;
                              },
                              onTap: () => showSelectorBottomSheet<String?>(
                                context: context,
                                groupValue: _typeId,
                                title: localization.selectType,
                                onSelect: (name, value) {
                                  setState(() {
                                    _typeId = value! as (int, int);
                                  });
                                  Navigator.pop(context, name);
                                },
                                attributeMap: snapshot.data,
                                action: TextButton.icon(
                                  onPressed: () => showAttributeDialog<void>(
                                    context: context,
                                    attributeRole: AttributeRole.child,
                                    attributeType: _eType.single == EType.income
                                        ? AttributeType.incomeType
                                        : AttributeType.expenseType,
                                    controller: textController[3],
                                  ).then(
                                    (_) => textController[3].clear(),
                                  ),
                                  icon: const Icon(Icons.add),
                                  label: Text(
                                    localization.add,
                                  ),
                                ),
                              ).then(
                                (name) => _typeId != (-1, -1) && name != null
                                    ? setState(() => displayText[1] = name)
                                    : null,
                              ),
                            ),
                          );
                        },
                      ),
                      Visibility(
                        visible: _eType.single == EType.expense,
                        child: FutureBuilder(
                          future: fhelper.getCards(Isar.getInstance()!),
                          builder: (context, snapshot) {
                            return Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 20),
                                  child: InputField(
                                    label: localization.card(1),
                                    readOnly: true,
                                    placeholder:
                                        displayText[3] ?? localization.none,
                                    onTap: () => showSelectorBottomSheet<void>(
                                      context: context,
                                      groupValue: _cardIndex,
                                      title: localization.selectCard,
                                      onSelect: (_, value) async {
                                        setState(() {
                                          _cardIndex = value! as int;
                                        });
                                        await getAvailableLimit(
                                          Isar.getInstance()!,
                                          snapshot.data![_cardIndex],
                                        ).then((freeLimit) {
                                          setState(
                                            () => _availabeLimit = freeLimit,
                                          );
                                          Navigator.pop(context);
                                        });
                                      },
                                      cardList: snapshot.data,
                                      action: TextButton.icon(
                                        onPressed: () {
                                          if (_cardIndex == -1) {
                                            showCardForm(context: context);
                                          } else {
                                            setState(() {
                                              _cardIndex = -1;
                                            });
                                            Navigator.pop(context);
                                          }
                                        },
                                        icon: Icon(
                                          _cardIndex == -1
                                              ? Icons.add
                                              : Icons.clear,
                                        ),
                                        label: Text(
                                          _cardIndex == -1
                                              ? localization.add
                                              : localization.clear,
                                        ),
                                      ),
                                    ).then(
                                      (_) async {
                                        if (_cardIndex != -1) {
                                          final name = snapshot.hasData
                                              ? snapshot.data![_cardIndex].name
                                              : null;
                                          setState(
                                            () {
                                              displayText[3] = name;
                                            },
                                          );
                                        } else {
                                          setState(() {
                                            displayText[3] = null;
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: _cardIndex != -1,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 15),
                                    child: InputField(
                                      label: localization.installments,
                                      readOnly: true,
                                      placeholder: displayText[4],
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return localization.emptyField;
                                        }
                                        return null;
                                      },
                                      onTap: () =>
                                          showSelectorBottomSheet<void>(
                                        context: context,
                                        groupValue: _installments,
                                        title: localization.installments,
                                        onSelect: (_, value) {
                                          setState(() {
                                            _installments = value! as int;
                                          });
                                          Navigator.pop(context);
                                        },
                                        intList: List.generate(
                                          48,
                                          (index) => index + 1,
                                        ),
                                      ).then(
                                        (_) {
                                          if (_installments >= 0) {
                                            setState(
                                              () => displayText[4] =
                                                  '${_installments + 1}',
                                            );
                                            final value = textController[1]
                                                .text
                                                .replaceAll(
                                                  RegExp('[^0-9]'),
                                                  '',
                                                );
                                            if (_installments > 0 &&
                                                (value != '000' ||
                                                    value.isNotEmpty)) {
                                              final price =
                                                  double.parse(value) / 100;
                                              final formatter =
                                                  NumberFormat.simpleCurrency(
                                                locale: languageCode,
                                              );
                                              setState(
                                                () => textController[2].text =
                                                    formatter.format(
                                                  price / (_installments + 1),
                                                ),
                                              );
                                            }
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: _installments > 0,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 15),
                                    child: InputField(
                                      controller: textController[2],
                                      label: localization.perInstallmentValue,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        CurrencyInputFormatter(
                                          locale: languageCode,
                                        )
                                      ],
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return localization.emptyField;
                                        } else if (value.replaceAll(
                                              RegExp('[^0-9]'),
                                              '',
                                            ) ==
                                            '000') {
                                          return localization.invalidValue;
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      if (_cardIndex == -1)
                        FutureBuilder(
                          future: getAttributes(
                            Isar.getInstance()!,
                            AttributeType.account,
                            context: context,
                          ).then((value) {
                            value.removeWhere((_, value) => value.isEmpty);
                            return value;
                          }),
                          builder: (context, snapshot) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: InputField(
                                label: localization.account(1),
                                readOnly: true,
                                placeholder:
                                    displayText[2] ?? localization.select,
                                validator: (value) {
                                  if (value!.isEmpty ||
                                      displayText[2] == null) {
                                    return localization.emptyField;
                                  }
                                  return null;
                                },
                                onTap: () => showSelectorBottomSheet<String?>(
                                  context: context,
                                  groupValue: _accountId,
                                  title: localization.selectAccount,
                                  onSelect: (name, value) {
                                    setState(() {
                                      _accountId = value! as (int, int);
                                    });
                                    Navigator.pop(context);
                                  },
                                  attributeMap: snapshot.data,
                                  action: TextButton.icon(
                                    onPressed: () => showAttributeDialog<void>(
                                      context: context,
                                      attributeType: AttributeType.account,
                                      attributeRole: AttributeRole.child,
                                      controller: textController[3],
                                    ).then(
                                      (_) => textController[3].clear(),
                                    ),
                                    icon: const Icon(Icons.add),
                                    label: Text(localization.add),
                                  ),
                                ).then(
                                  (name) => _accountId != (-1, -1) &&
                                          name != null
                                      ? setState(() => displayText[2] = name)
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
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(localization.cancel),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final value = textController[1]
                          .text
                          .replaceAll(RegExp('[^0-9]'), '');
                      final installmentValue = textController[2]
                          .text
                          .replaceAll(RegExp('[^0-9]'), '');
                      final isar = Isar.getInstance()!;
                      final types = await getAttributes(
                        isar,
                        _eType.single == EType.income
                            ? AttributeType.incomeType
                            : AttributeType.expenseType,
                        context: context,
                      );
                      final exchange = Exchange(
                        eType: _eType.single,
                        description: textController[0].text,
                        value: _eType.single == EType.income
                            ? double.parse(value) / 100
                            : -double.parse(value) / 100,
                        date: DateTime.parse(displayText[0]!),
                        typeId:
                            types.values.toList()[_typeId.$1][_typeId.$2].id,
                        accountId: _cardIndex > -1
                            ? -1
                            : (await getAttributes(
                                isar,
                                AttributeType.account,
                                context: mounted ? context : null,
                              ))
                                .values
                                .toList()[_accountId.$1][_accountId.$2]
                                .id,
                        cardId:
                            _eType.single == EType.expense && _cardIndex > -1
                                ? (await fhelper.getCards(isar))[_cardIndex].id
                                : null,
                        installments:
                            _cardIndex > -1 ? _installments + 1 : null,
                        installmentValue: _cardIndex > -1
                            ? _installments > 0
                                ? -double.parse(installmentValue) / 100
                                : null
                            : null,
                      );
                      await isar.writeTxn(() async {
                        await isar.exchanges.put(exchange);
                      }).then((_) => Navigator.pop(context));
                      if (_cardIndex != -1) {
                        await processInstallments(isar, exchange);
                      }
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: Text(localization.add),
                  style: ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll<Color>(
                      Color(
                        _eType.single == EType.income ? 0xff199225 : 0xffbd1c1c,
                      ).harmonizeWith(
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    foregroundColor: MaterialStatePropertyAll<Color>(
                      Colors.white.harmonizeWith(
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
