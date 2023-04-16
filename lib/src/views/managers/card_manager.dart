import 'package:fhelper/src/logic/collections/attribute.dart';
import 'package:fhelper/src/logic/collections/card.dart' as fhelper;
import 'package:fhelper/src/logic/collections/exchange.dart';
import 'package:fhelper/src/widgets/inputfield.dart';
import 'package:fhelper/src/widgets/listchoice.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';

class CardManager extends StatefulWidget {
  const CardManager({super.key});

  @override
  State<CardManager> createState() => _CardManagerState();
}

class _CardManagerState extends State<CardManager> {
  int _accountId = -1;
  int _stcDate = -1;
  int _pdDate = -1;
  final List<TextEditingController> _controller = [
    TextEditingController(),
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

  Future<void> _addCard() async {
    final String value = _controller[1].text.replaceAll(RegExp('[^0-9]'), '');
    final Isar isar = Isar.getInstance()!;
    final fhelper.Card card = fhelper.Card(
      name: _controller[0].text,
      statementClosure: _stcDate + 1,
      paymentDue: _pdDate + 1,
      limit: double.parse(value) / 100,
      accountId: (await getAttributes(isar, AttributeType.account))[_accountId].id,
    );
    await isar.writeTxn(() async {
      await isar.cards.put(card);
    }).then((_) => Navigator.pop(context));
    cleanForm();
  }

  Future<void> _editCard(fhelper.Card originalCard) async {
    final Isar isar = Isar.getInstance()!;
    final String value = _controller[1].text.replaceAll(RegExp('[^0-9]'), '');
    final fhelper.Card newCard = originalCard.copyWith(
      name: _controller[0].text,
      statementClosure: _stcDate + 1,
      paymentDue: _pdDate + 1,
      limit: double.parse(value) / 100,
      accountId: _accountId == -1 ? null : (await getAttributes(isar, AttributeType.account))[_accountId].id,
    );
    await isar.writeTxn(() async {
      await isar.cards.put(newCard);
    }).then((_) {
      Navigator.pop(context);
      Navigator.pop(context);
      cleanForm();
    });
  }

  void cleanForm() {
    setState(() {
      _accountId = -1;
      _stcDate = -1;
      _pdDate = -1;
    });
    displayText.fillRange(0, 3, null);
    for (final element in _controller) {
      element.clear();
    }
  }

  void _addAccountDialog() {
    final TextEditingController controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (context) {
        final formKey = GlobalKey<FormState>();
        return AlertDialog(
          title: Text(
            AppLocalizations.of(context)!.add,
          ),
          icon: const Icon(Icons.add),
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
                  final Attribute attribute = Attribute(
                    name: controller.text,
                    type: AttributeType.account,
                  );
                  await isar.writeTxn(() async {
                    await isar.attributes.put(attribute);
                  }).then((_) {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  });
                }
              },
              label: Text(AppLocalizations.of(context)!.add),
            ),
          ],
        );
      },
    ).then((_) => controller.clear());
  }

  @override
  void dispose() {
    for (final element in _controller) {
      element.dispose();
    }
    super.dispose();
  }

  Future<void> _showFullscreenForm({bool edit = false, fhelper.Card? card, Attribute? cardAttribute}) {
    if (card != null && edit) {
      setState(() {
        _stcDate = card.statementClosure - 1;
        _pdDate = card.paymentDue - 1;
        displayText[0] = AppLocalizations.of(context)!.dayOfMonth(card.statementClosure);
        displayText[1] = AppLocalizations.of(context)!.dayOfMonth(card.paymentDue);
        displayText[2] = cardAttribute!.name;
        _controller[0].text = card.name;
        _controller[1].text = NumberFormat.simpleCurrency(locale: Localizations.localeOf(context).languageCode).format(card.limit);
      });
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
                    title: Text(edit ? AppLocalizations.of(context)!.edit : AppLocalizations.of(context)!.addCard),
                    leading: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                        if (edit) {
                          Navigator.pop(context);
                        }
                        cleanForm();
                      },
                      icon: const Icon(Icons.close),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            if (edit) {
                              await _editCard(card!);
                            } else {
                              await _addCard();
                            }
                          }
                        },
                        child: Text(edit ? AppLocalizations.of(context)!.save : AppLocalizations.of(context)!.add),
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
                                controller: _controller[0],
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
                                              groupValue: _stcDate,
                                              onChanged: (value) {
                                                setState(() {
                                                  _stcDate = value!;
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
                                  (_) => _stcDate != -1
                                      ? setState(
                                          () => displayText[0] = AppLocalizations.of(context)!.dayOfMonth(_stcDate + 1),
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
                                              groupValue: _pdDate,
                                              onChanged: (value) {
                                                setState(() {
                                                  _pdDate = value!;
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
                                  (_) => _pdDate != -1
                                      ? setState(
                                          () => displayText[1] = AppLocalizations.of(context)!.dayOfMonth(_pdDate + 1),
                                        )
                                      : null,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 15),
                              child: InputField(
                                controller: _controller[1],
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
                                        int accountIndex = edit && snapshot.hasData ? snapshot.data!.indexOf(cardAttribute!) : -1;
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
                                                        onPressed: _addAccountDialog,
                                                        icon: const Icon(Icons.add),
                                                        label: Text(AppLocalizations.of(context)!.add),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                ListChoice(
                                                  groupValue: edit ? accountIndex : _accountId,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      if (edit) {
                                                        accountIndex = value!;
                                                      }
                                                      _accountId = value!;
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
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.medium(
            title: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                AppLocalizations.of(context)!.card(-1),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Material(
              child: StreamBuilder(
                stream: Isar.getInstance()!.cards.watchLazy(),
                builder: (context, snapshot) {
                  return FutureBuilder(
                    future: fhelper.getCards(Isar.getInstance()!),
                    builder: (context, snapshot) {
                      final List<fhelper.Card> cards = snapshot.hasData ? snapshot.data! : [];
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        itemCount: cards.length,
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                                title: Text(
                                  cards[index].name,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                trailing: Icon(
                                  Icons.arrow_right,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                                onTap: () => showModalBottomSheet<void>(
                                  context: context,
                                  builder: (context) {
                                    return SafeArea(
                                      child: Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.stretch,
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              cards[index].name,
                                              style: Theme.of(context).textTheme.headlineMedium,
                                            ),
                                            const SizedBox(height: 15),
                                            FutureBuilder(
                                              future: checkForAttributeDependencies(Isar.getInstance()!, cards[index].id, null),
                                              builder: (context, snapshot) {
                                                return OutlinedButton.icon(
                                                  icon: const Icon(Icons.delete),
                                                  onPressed: () async {
                                                    final Isar isar = Isar.getInstance()!;
                                                    if (snapshot.data != null && snapshot.data! > 0) {
                                                      await showDialog<void>(
                                                        context: context,
                                                        builder: (context) {
                                                          return AlertDialog(
                                                            title: Text(AppLocalizations.of(context)!.proceedQuestion),
                                                            icon: const Icon(Icons.warning),
                                                            content: Text(AppLocalizations.of(context)!.dependencyPhrase(snapshot.data!)),
                                                            actions: [
                                                              TextButton(
                                                                onPressed: () => Navigator.pop(context),
                                                                child: Text(
                                                                  AppLocalizations.of(context)!.cancel,
                                                                ),
                                                              ),
                                                              FilledButton.tonal(
                                                                onPressed: () async {
                                                                  await isar.writeTxn(() async {
                                                                    await isar.cards.delete(cards[index].id);
                                                                  }).then((_) => Navigator.pop(context));
                                                                },
                                                                child: Text(AppLocalizations.of(context)!.proceed),
                                                              )
                                                            ],
                                                          );
                                                        },
                                                      );
                                                    } else {
                                                      await isar.writeTxn(() async {
                                                        await isar.cards.delete(cards[index].id);
                                                      }).then((_) => Navigator.pop(context));
                                                    }
                                                  },
                                                  label: Text(AppLocalizations.of(context)!.delete),
                                                );
                                              },
                                            ),
                                            FilledButton.icon(
                                              onPressed: () async {
                                                final Attribute? attribute = await getAttributeFromId(Isar.getInstance()!, cards[index].accountId);
                                                await _showFullscreenForm(edit: true, card: cards[index], cardAttribute: attribute);
                                              },
                                              icon: const Icon(Icons.edit),
                                              label: Text(AppLocalizations.of(context)!.edit),
                                            ),
                                            const Divider(
                                              height: 24,
                                              thickness: 2,
                                            ),
                                            FilledButton.tonalIcon(
                                              onPressed: () => Navigator.pop(context),
                                              icon: const Icon(Icons.arrow_back),
                                              label: Text(AppLocalizations.of(context)!.back),
                                            )
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              if (index == cards.length - 1)
                                Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: Theme.of(context).colorScheme.outlineVariant,
                                ),
                            ],
                          );
                        },
                        separatorBuilder: (_, __) => Divider(
                          height: 1,
                          thickness: 1,
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
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
                  child: Text(AppLocalizations.of(context)!.back),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _showFullscreenForm,
                  icon: const Icon(Icons.add),
                  label: Text(AppLocalizations.of(context)!.add),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
