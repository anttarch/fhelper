import 'package:dynamic_color/dynamic_color.dart';
import 'package:fhelper/src/logic/collections/attribute.dart';
import 'package:fhelper/src/logic/collections/card.dart' as fhelper;
import 'package:fhelper/src/logic/collections/card_bill.dart';
import 'package:fhelper/src/logic/collections/exchange.dart';
import 'package:fhelper/src/logic/widgets/show_attribute_dialog.dart';
import 'package:fhelper/src/logic/widgets/show_card_dialog.dart';
import 'package:fhelper/src/widgets/inputfield.dart';
import 'package:fhelper/src/widgets/listchoice.dart';
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
  int _typeId = -1;
  int _accountId = -1;
  int _cardIndex = -1;
  int _installments = 0;
  bool _accountFieldLock = false;
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
                  AppLocalizations.of(context)!.add,
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
                      label: Text(AppLocalizations.of(context)!.income),
                    ),
                    ButtonSegment(
                      value: EType.expense,
                      label: Text(AppLocalizations.of(context)!.expense),
                    ),
                  ],
                  selected: _eType,
                  onSelectionChanged: (p0) {
                    _formKey.currentState!.reset();
                    setState(() {
                      _eType = p0;
                      _typeId = -1;
                      _accountId = -1;
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
                          label: AppLocalizations.of(context)!.description,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(20),
                          ],
                          validator: (value) {
                            if (value!.isEmpty) {
                              return AppLocalizations.of(context)!.emptyField;
                            } else if (value.length < 3) {
                              return AppLocalizations.of(context)!.threeCharactersMinimum;
                            } else if (value.contains('#/spt#/')) {
                              return AppLocalizations.of(context)!.invalidName;
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: InputField(
                          controller: textController[1],
                          label: _eType.single == EType.income ? AppLocalizations.of(context)!.amount : AppLocalizations.of(context)!.price,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            CurrencyInputFormatter(
                              locale: Localizations.localeOf(context).languageCode,
                            )
                          ],
                          validator: (value) {
                            final String price = textController[1].text.replaceAll(RegExp('[^0-9]'), '');
                            if (value!.isEmpty) {
                              return AppLocalizations.of(context)!.emptyField;
                            } else if (value.replaceAll(RegExp('[^0-9]'), '') == '000') {
                              return AppLocalizations.of(context)!.invalidValue;
                            } else if (_cardIndex != -1 && double.parse(price) / 100 > _availabeLimit) {
                              return AppLocalizations.of(context)!.insufficientLimit;
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: InputField(
                          label: AppLocalizations.of(context)!.date,
                          readOnly: true,
                          placeholder: DateTime.now().difference(DateTime.parse(displayText[0]!)).inHours < 24
                              ? DateFormat.yMd(
                                  Localizations.localeOf(context).languageCode,
                                ).add_jm().format(DateTime.parse(displayText[0]!))
                              : DateFormat.yMd(
                                  Localizations.localeOf(context).languageCode,
                                ).format(DateTime.parse(displayText[0]!)),
                          onTap: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.parse(displayText[0]!),
                              firstDate: DateTime(DateTime.now().year, DateTime.now().month),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) {
                              setState(
                                () {
                                  if (DateTime.now().difference(picked).inHours < 24) {
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
                          _eType.single == EType.income ? AttributeType.incomeType : AttributeType.expenseType,
                          context: context,
                        ),
                        builder: (context, snapshot) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: InputField(
                              label: AppLocalizations.of(context)!.type(1),
                              readOnly: true,
                              placeholder: displayText[1] ?? AppLocalizations.of(context)!.select,
                              validator: (value) {
                                if (value!.isEmpty || displayText[1] == null) {
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
                                                  AppLocalizations.of(context)!.selectType,
                                                  style: Theme.of(context).textTheme.titleLarge,
                                                ),
                                                TextButton.icon(
                                                  onPressed: () => showAttributeDialog<void>(
                                                    context: context,
                                                    attributeType: _eType.single == EType.income ? AttributeType.incomeType : AttributeType.expenseType,
                                                    controller: textController[3],
                                                  ).then((_) => textController[3].clear()),
                                                  icon: const Icon(Icons.add),
                                                  label: Text(AppLocalizations.of(context)!.add),
                                                ),
                                              ],
                                            ),
                                          ),
                                          ListChoice(
                                            groupValue: _typeId,
                                            onChanged: (value) {
                                              setState(() {
                                                _typeId = value!;
                                              });
                                              Navigator.pop(context);
                                            },
                                            attributeList: snapshot.hasData ? snapshot.data! : null,
                                          )
                                        ],
                                      );
                                    },
                                  );
                                },
                              ).then(
                                (_) => _typeId != -1
                                    ? setState(
                                        () => displayText[1] = snapshot.hasData ? snapshot.data![_typeId].name : null,
                                      )
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
                                    label: AppLocalizations.of(context)!.card(1),
                                    readOnly: true,
                                    placeholder: displayText[3] ?? AppLocalizations.of(context)!.none,
                                    onTap: () => showModalBottomSheet<void>(
                                      context: context,
                                      constraints: BoxConstraints(
                                        minHeight: MediaQuery.of(context).size.height / 3,
                                      ),
                                      enableDrag: false,
                                      builder: (context) {
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
                                                        AppLocalizations.of(context)!.selectCard,
                                                        style: Theme.of(context).textTheme.titleLarge,
                                                      ),
                                                      if (_cardIndex == -1)
                                                        TextButton.icon(
                                                          onPressed: () => showCardForm(context: context),
                                                          icon: const Icon(Icons.add),
                                                          label: Text(AppLocalizations.of(context)!.add),
                                                        )
                                                      else
                                                        TextButton.icon(
                                                          onPressed: () {
                                                            setState(() {
                                                              _cardIndex = -1;
                                                            });
                                                            Navigator.pop(context);
                                                          },
                                                          icon: const Icon(Icons.clear),
                                                          label: Text(AppLocalizations.of(context)!.clear),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                                ListChoice(
                                                  groupValue: _cardIndex,
                                                  onChanged: (value) async {
                                                    setState(() {
                                                      _cardIndex = value!;
                                                    });
                                                    await getAvailableLimit(
                                                      Isar.getInstance()!,
                                                      snapshot.data![_cardIndex],
                                                    ).then((freeLimit) {
                                                      setState(() => _availabeLimit = freeLimit);
                                                      Navigator.pop(context);
                                                    });
                                                  },
                                                  cardList: snapshot.hasData ? snapshot.data! : null,
                                                )
                                              ],
                                            );
                                          },
                                        );
                                      },
                                    ).then(
                                      (_) async {
                                        if (_cardIndex != -1) {
                                          final Attribute? account =
                                              await getAttributeFromId(Isar.getInstance()!, snapshot.data![_cardIndex].accountId, context: context);
                                          setState(
                                            () {
                                              displayText[3] = snapshot.hasData ? snapshot.data![_cardIndex].name : null;
                                              if (snapshot.hasData) {
                                                displayText[2] = account!.name;
                                                _accountFieldLock = true;
                                              }
                                            },
                                          );
                                        } else if (_accountFieldLock == true) {
                                          setState(() {
                                            _accountFieldLock = false;
                                            displayText[2] = null;
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
                                      label: AppLocalizations.of(context)!.installments,
                                      readOnly: true,
                                      placeholder: displayText[4],
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
                                                      AppLocalizations.of(context)!.installments,
                                                      style: Theme.of(context).textTheme.titleLarge,
                                                    ),
                                                  ),
                                                  ListChoice(
                                                    groupValue: _installments,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        _installments = value!;
                                                      });
                                                      Navigator.pop(context);
                                                    },
                                                    intList: List.generate(48, (index) => index + 1),
                                                  )
                                                ],
                                              );
                                            },
                                          );
                                        },
                                      ).then(
                                        (_) {
                                          if (_installments >= 0) {
                                            setState(() => displayText[4] = '${_installments + 1}');
                                            final String value = textController[1].text.replaceAll(RegExp('[^0-9]'), '');
                                            if (_installments > 0 && (value != '000' || value.isNotEmpty)) {
                                              final double price = double.parse(value) / 100;
                                              setState(
                                                () => textController[2].text = NumberFormat.simpleCurrency(locale: Localizations.localeOf(context).languageCode)
                                                    .format(price / (_installments + 1)),
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
                                      label: AppLocalizations.of(context)!.perInstallmentValue,
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
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      FutureBuilder(
                        future: getAttributes(Isar.getInstance()!, AttributeType.account, context: context),
                        builder: (context, snapshot) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: InputField(
                              label: AppLocalizations.of(context)!.account(1),
                              locked: _accountFieldLock,
                              readOnly: true,
                              placeholder: displayText[2] ?? AppLocalizations.of(context)!.select,
                              validator: (value) {
                                if (value!.isEmpty || displayText[2] == null) {
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
                                                    controller: textController[3],
                                                  ).then((_) => textController[3].clear()),
                                                  icon: const Icon(Icons.add),
                                                  label: Text(AppLocalizations.of(context)!.add),
                                                ),
                                              ],
                                            ),
                                          ),
                                          ListChoice(
                                            groupValue: _accountId,
                                            onChanged: (value) {
                                              setState(() {
                                                _accountId = value!;
                                              });
                                              Navigator.pop(context);
                                            },
                                            attributeList: snapshot.hasData ? snapshot.data! : [],
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ).then(
                                (_) => _accountId != -1
                                    ? setState(
                                        () => displayText[2] = snapshot.hasData ? snapshot.data![_accountId].name : null,
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
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final String value = textController[1].text.replaceAll(RegExp('[^0-9]'), '');
                      final String installmentValue = textController[2].text.replaceAll(RegExp('[^0-9]'), '');
                      final Isar isar = Isar.getInstance()!;
                      final Exchange exchange = Exchange(
                        eType: _eType.single,
                        description: textController[0].text,
                        value: _eType.single == EType.income ? double.parse(value) / 100 : -double.parse(value) / 100,
                        date: DateTime.parse(displayText[0]!),
                        typeId: (await getAttributes(isar, _eType.single == EType.income ? AttributeType.incomeType : AttributeType.expenseType))[_typeId].id,
                        accountId: _cardIndex > -1
                            ? (await fhelper.getCards(isar))[_cardIndex].accountId
                            : (await getAttributes(isar, AttributeType.account))[_accountId].id,
                        cardId: _eType.single == EType.expense && _cardIndex > -1 ? (await fhelper.getCards(isar))[_cardIndex].id : null,
                        installments: _cardIndex > -1 ? _installments + 1 : null,
                        installmentValue: _cardIndex > -1
                            ? _installments > 0
                                ? double.parse(installmentValue) / 100
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
                  label: Text(AppLocalizations.of(context)!.add),
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
