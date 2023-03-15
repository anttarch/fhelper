import 'package:fhelper/src/logic/collections/attribute.dart';
import 'package:fhelper/src/logic/collections/card.dart' as fhelper;
import 'package:fhelper/src/widgets/attributechoice.dart';
import 'package:fhelper/src/widgets/inputfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height - 88 - MediaQuery.of(context).padding.bottom - MediaQuery.of(context).padding.top,
              child: CustomScrollView(
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
                                          constraints: BoxConstraints(
                                            maxHeight: MediaQuery.of(context).size.height / 3.2,
                                          ),
                                          builder: (context) {
                                            return Padding(
                                              padding: const EdgeInsets.all(20),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    cards[index].name,
                                                    style: Theme.of(context).textTheme.headlineMedium,
                                                  ),
                                                  const SizedBox(height: 15),
                                                  OutlinedButton.icon(
                                                    icon: const Icon(Icons.delete),
                                                    onPressed: () async {
                                                      final Isar isar = Isar.getInstance()!;
                                                      await isar.writeTxn(() async {
                                                        await isar.cards.delete(cards[index].id);
                                                      }).then((_) => Navigator.pop(context));
                                                    },
                                                    label: Text(AppLocalizations.of(context)!.delete),
                                                  ),
                                                  FilledButton.icon(
                                                    onPressed: () => showDialog<void>(
                                                      context: context,
                                                      builder: (context) {
                                                        final formKey = GlobalKey<FormState>();
                                                        _controller[1].text = cards[index].name;
                                                        return AlertDialog(
                                                          title: Text(AppLocalizations.of(context)!.edit),
                                                          icon: const Icon(Icons.edit),
                                                          content: Form(
                                                            key: formKey,
                                                            child: InputField(
                                                              controller: _controller[1],
                                                              label: AppLocalizations.of(context)!.name,
                                                              inputFormatters: [
                                                                LengthLimitingTextInputFormatter(15),
                                                              ],
                                                              validator: (value) {
                                                                if (value!.isEmpty) {
                                                                  return 'Cannot be empty';
                                                                } else if (value.length < 3) {
                                                                  return 'At least 3 characters';
                                                                }
                                                                return null;
                                                              },
                                                            ),
                                                          ),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () => Navigator.pop(context),
                                                              child: Text(AppLocalizations.of(context)!.cancel),
                                                            ),
                                                            FilledButton.tonalIcon(
                                                              icon: const Icon(Icons.done),
                                                              onPressed: () async {
                                                                if (formKey.currentState!.validate()) {
                                                                  final Isar isar = Isar.getInstance()!;
                                                                  final fhelper.Card card = cards[index].copyWith(name: _controller[1].text);
                                                                  await isar.writeTxn(() async {
                                                                    await isar.cards.put(card);
                                                                  }).then((_) {
                                                                    Navigator.pop(context);
                                                                    Navigator.pop(context);
                                                                    _controller[1].clear();
                                                                  });
                                                                }
                                                              },
                                                              label: Text(AppLocalizations.of(context)!.save),
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    ),
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
            ),
            Padding(
              padding: const EdgeInsets.all(20),
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
                      onPressed: () => showDialog<void>(
                        context: context,
                        builder: (context) {
                          final formKey = GlobalKey<FormState>();
                          return StatefulBuilder(
                            builder: (context, setState) {
                              return Dialog.fullscreen(
                                child: Column(
                                  children: [
                                    AppBar(
                                      title: Text('Add card'),
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
                                          },
                                          child: Text(AppLocalizations.of(context)!.add),
                                        ),
                                      ],
                                    ),
                                    Padding(
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
                                                    return 'Cannot be empty';
                                                  } else if (value.length < 3) {
                                                    return 'At least 3 characters';
                                                  }
                                                  return null;
                                                },
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(top: 15),
                                              child: InputField(
                                                label: 'Statement Closing day',
                                                readOnly: true,
                                                placeholder: displayText[0],
                                                validator: (value) {
                                                  if (value!.isEmpty) {
                                                    return 'Cannot be empty';
                                                  } else if (value.length < 3) {
                                                    return 'At least 3 characters';
                                                  }
                                                  return null;
                                                },
                                                onTap: () => showModalBottomSheet<void>(
                                                  context: context,
                                                  constraints: BoxConstraints(
                                                    maxHeight: MediaQuery.of(context).size.height / 2.5,
                                                  ),
                                                  enableDrag: false,
                                                  builder: (context) {
                                                    return StatefulBuilder(
                                                      builder: (context, setState) {
                                                        return Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Padding(
                                                              padding: const EdgeInsets.all(20),
                                                              child: Text(
                                                                'Select Day',
                                                                style: Theme.of(context).textTheme.titleLarge,
                                                              ),
                                                            ),
                                                            AttributeChoice(
                                                              groupValue: _stcDate,
                                                              onChanged: (value) {
                                                                setState(() {
                                                                  _stcDate = value!;
                                                                });
                                                                Navigator.pop(context);
                                                              },
                                                              items: const [],
                                                              lazyEnoughToMakeAnotherWidgetIntList: List.generate(31, (index) => index + 1),
                                                            )
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  },
                                                ).then(
                                                  (_) => _stcDate != -1
                                                      ? setState(
                                                          () => displayText[0] = 'Day ${_stcDate + 1} of each month',
                                                        )
                                                      : null,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(top: 15),
                                              child: InputField(
                                                label: 'Payment Due day',
                                                readOnly: true,
                                                placeholder: displayText[1],
                                                validator: (value) {
                                                  if (value!.isEmpty) {
                                                    return 'Cannot be empty';
                                                  } else if (value.length < 3) {
                                                    return 'At least 3 characters';
                                                  }
                                                  return null;
                                                },
                                                onTap: () => showModalBottomSheet<void>(
                                                  context: context,
                                                  constraints: BoxConstraints(
                                                    maxHeight: MediaQuery.of(context).size.height / 2.5,
                                                  ),
                                                  enableDrag: false,
                                                  builder: (context) {
                                                    return StatefulBuilder(
                                                      builder: (context, setState) {
                                                        return Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Padding(
                                                              padding: const EdgeInsets.all(20),
                                                              child: Text(
                                                                'Select Day',
                                                                style: Theme.of(context).textTheme.titleLarge,
                                                              ),
                                                            ),
                                                            AttributeChoice(
                                                              groupValue: _pdDate,
                                                              onChanged: (value) {
                                                                setState(() {
                                                                  _pdDate = value!;
                                                                });
                                                                Navigator.pop(context);
                                                              },
                                                              items: const [],
                                                              lazyEnoughToMakeAnotherWidgetIntList: List.generate(31, (index) => index + 1),
                                                            )
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  },
                                                ).then(
                                                  (_) => _pdDate != -1
                                                      ? setState(
                                                          () => displayText[1] = 'Day ${_pdDate + 1} of each month',
                                                        )
                                                      : null,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(top: 15),
                                              child: InputField(
                                                controller: _controller[1],
                                                label: 'Limit',
                                                keyboardType: TextInputType.number,
                                                inputFormatters: [
                                                  CurrencyInputFormatter(
                                                    locale: Localizations.localeOf(context).languageCode,
                                                  )
                                                ],
                                                validator: (value) {
                                                  if (value!.isEmpty) {
                                                    return 'Cannot be empty';
                                                  } else if (value.replaceAll(RegExp('[^0-9]'), '') == '000') {
                                                    return 'Invalid value';
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
                                                  padding: const EdgeInsets.only(top: 15),
                                                  child: InputField(
                                                    label: AppLocalizations.of(context)!.account(1),
                                                    readOnly: true,
                                                    placeholder: displayText[2],
                                                    validator: (value) {
                                                      if (value!.isEmpty) {
                                                        return 'Cannot be empty';
                                                      }
                                                      return null;
                                                    },
                                                    onTap: () => showModalBottomSheet<void>(
                                                      context: context,
                                                      constraints: BoxConstraints(
                                                        maxHeight: MediaQuery.of(context).size.height / 2.5,
                                                      ),
                                                      enableDrag: false,
                                                      builder: (context) {
                                                        return StatefulBuilder(
                                                          builder: (context, setState) {
                                                            return Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                Padding(
                                                                  padding: const EdgeInsets.all(20),
                                                                  child: Text(
                                                                    AppLocalizations.of(context)!.selectAccount,
                                                                    style: Theme.of(context).textTheme.titleLarge,
                                                                  ),
                                                                ),
                                                                AttributeChoice(
                                                                  groupValue: _accountId,
                                                                  onChanged: (value) {
                                                                    setState(() {
                                                                      _accountId = value!;
                                                                    });
                                                                    Navigator.pop(context);
                                                                  },
                                                                  items: snapshot.hasData ? snapshot.data! : [],
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
                                  ],
                                ),
                                // actions: [
                                //   TextButton(
                                //     onPressed: () => Navigator.pop(context),
                                //     child: Text(
                                //       AppLocalizations.of(context)!.cancel,
                                //     ),
                                //   ),
                                //   FilledButton.tonalIcon(
                                //     icon: const Icon(Icons.add),
                                //     onPressed: () async {
                                //       if (formKey.currentState!.validate()) {
                                //         final Isar isar = Isar.getInstance()!;
                                //         final Attribute attribute = Attribute(
                                //           name: _controller[0].text,
                                //           type: AttributeType.account,
                                //         );
                                //         // await isar.writeTxn(() async {
                                //         //   await isar.attributes.put(attribute);
                                //         // }).then((_) => Navigator.pop(context));
                                //         // _controller[0].clear();
                                //       }
                                //     },
                                //     label: Text(AppLocalizations.of(context)!.add),
                                //   ),
                                // ],
                              );
                            },
                          );
                        },
                      ),
                      icon: const Icon(Icons.add),
                      label: Text(AppLocalizations.of(context)!.add),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
