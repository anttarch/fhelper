import 'package:dynamic_color/dynamic_color.dart';
import 'package:fhelper/src/logic/collections/attribute.dart';
import 'package:fhelper/src/logic/collections/exchange.dart';
import 'package:fhelper/src/widgets/attributechoice.dart';
import 'package:fhelper/src/widgets/inputfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';

class AddView extends StatefulWidget {
  const AddView({super.key});

  @override
  State<AddView> createState() => _AddViewState();
}

enum _IType { present, wage }

class _AddViewState extends State<AddView> {
  Set<EType> _eType = {EType.income};
  _IType _itype = _IType.present;
  int _typeId = -1;
  int _accountId = -1;
  final PageController _pageCtrl = PageController();
  final Map<EType, int> _indexMap = {
    EType.income: 0,
    EType.expense: 1,
  };
  final List<String?> displayText = [
    // Date
    DateTime.now().toString(),
    // Type,
    null,
    // Account,
    null,
    // Card
    null,
  ];
  final List<TextEditingController> textController = [
    TextEditingController(),
    TextEditingController(),
  ];

  // `_getPageHeight()` is a hard coded function
  // Some kind of hack to allow resizing of the view
  // IT NEED TO BE UPDATED on every change of the widget tree
  // `availableHeight` represents the screen size available for the pageview
  // `treeHeight` represents the total height of widgets that need to be rendered

  double _getPageHeight() {
    // screen height - (appar + segmented btn + bottom row) height
    // - padding top and bottom
    final double availableHeight = MediaQuery.of(context).size.height - 260 - MediaQuery.of(context).padding.bottom - MediaQuery.of(context).padding.top;
    final double treeHeight = _eType.single == EType.income ? 484 : 580;
    if (availableHeight > treeHeight) {
      return availableHeight;
    } else {
      return treeHeight;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.background,
      child: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height - 88 - MediaQuery.of(context).padding.bottom - MediaQuery.of(context).padding.top,
              child: CustomScrollView(
                slivers: [
                  SliverAppBar.medium(
                    title: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        AppLocalizations.of(context)!.add,
                        style: Theme.of(context).textTheme.headlineMedium,
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
                          setState(() {
                            _eType = p0;
                            _typeId = -1;
                            _accountId = -1;
                            displayText[0] = DateTime.now().toString();
                          });
                          displayText.fillRange(1, 4, null);
                          for (final element in textController) {
                            element.clear();
                          }
                          _pageCtrl.animateToPage(
                            _indexMap.entries.firstWhere((e) => e.key == p0.single).value,
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeInOut,
                          );
                        },
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: _getPageHeight(),
                      width: MediaQuery.of(context).size.width,
                      child: PageView(
                        controller: _pageCtrl,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 24),
                                  child: InputField(
                                    controller: textController[0],
                                    label: AppLocalizations.of(context)!.description,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 20),
                                  child: InputField(
                                    controller: textController[1],
                                    label: AppLocalizations.of(context)!.amount,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      CurrencyInputFormatter(
                                        locale: Localizations.localeOf(context).languageCode,
                                      )
                                    ],
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
                                        firstDate: DateTime(DateTime.now().month),
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
                                    AttributeType.incomeType,
                                  ),
                                  builder: (context, snapshot) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 20),
                                      child: InputField(
                                        label: AppLocalizations.of(context)!.type(1),
                                        readOnly: true,
                                        placeholder: displayText[1],
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
                                                        AppLocalizations.of(context)!.selectType,
                                                        style: Theme.of(context).textTheme.titleLarge,
                                                      ),
                                                    ),
                                                    AttributeChoice(
                                                      groupValue: _typeId,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          _typeId = value!;
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
                                FutureBuilder(
                                  future: getAttributes(
                                    Isar.getInstance()!,
                                    AttributeType.account,
                                  ),
                                  builder: (context, snapshot) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 20),
                                      child: InputField(
                                        label: AppLocalizations.of(context)!.account(1),
                                        readOnly: true,
                                        placeholder: displayText[2],
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
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 24),
                                  child: InputField(
                                    controller: textController[0],
                                    label: AppLocalizations.of(context)!.description,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 20),
                                  child: InputField(
                                    controller: textController[1],
                                    label: AppLocalizations.of(context)!.price,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      CurrencyInputFormatter(
                                        locale: Localizations.localeOf(context).languageCode,
                                      )
                                    ],
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
                                          ).add_jm().format(
                                              DateTime.parse(displayText[0]!),
                                            )
                                        : DateFormat.yMd(
                                            Localizations.localeOf(context).languageCode,
                                          ).format(
                                            DateTime.parse(displayText[0]!),
                                          ),
                                    onTap: () async {
                                      final DateTime? picked = await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.parse(displayText[0]!),
                                        firstDate: DateTime(DateTime.now().month),
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
                                    AttributeType.expenseType,
                                  ),
                                  builder: (context, snapshot) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 20),
                                      child: InputField(
                                        label: AppLocalizations.of(context)!.type(1),
                                        readOnly: true,
                                        placeholder: displayText[1],
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
                                                        AppLocalizations.of(context)!.selectType,
                                                        style: Theme.of(context).textTheme.titleLarge,
                                                      ),
                                                    ),
                                                    AttributeChoice(
                                                      groupValue: _typeId,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          _typeId = value!;
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
                                Padding(
                                  padding: const EdgeInsets.only(top: 20),
                                  child: InputField(
                                    label: AppLocalizations.of(context)!.card(1),
                                    readOnly: true,
                                    placeholder: displayText[3],
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
                                                    'Select Card',
                                                    style: Theme.of(context).textTheme.titleLarge,
                                                  ),
                                                ),
                                                // AttributeChoice<_IType>(
                                                //   groupValue: _itype,
                                                //   onChanged: (value) {
                                                //     setState(() {
                                                //       _itype = value!;
                                                //     });
                                                //     Navigator.pop(context);
                                                //   },
                                                //   items: const {'Card 1': _IType.present, 'Card 2': _IType.wage},
                                                // )
                                              ],
                                            );
                                          },
                                        );
                                      },
                                    ).then(
                                      (_) => setState(
                                        () => displayText[3] = _itype.toString(),
                                      ),
                                    ),
                                  ),
                                ),
                                FutureBuilder(
                                  future: getAttributes(
                                    Isar.getInstance()!,
                                    AttributeType.account,
                                  ),
                                  builder: (context, snapshot) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 20),
                                      child: InputField(
                                        label: AppLocalizations.of(context)!.account(1),
                                        readOnly: true,
                                        placeholder: displayText[2],
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
                        ],
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
                      child: Text(AppLocalizations.of(context)!.cancel),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () async {
                        final String value = textController[1].text.replaceAll(RegExp('[^0-9]'), '');
                        final Isar isar = Isar.getInstance()!;
                        final Exchange exchange = Exchange(
                          eType: _eType.single,
                          description: textController[0].text,
                          value: _eType.single == EType.income ? double.parse(value) / 100 : -double.parse(value) / 100,
                          date: DateTime.parse(displayText[0]!),
                          typeId: (await getAttributes(isar, _eType.single == EType.income ? AttributeType.incomeType : AttributeType.expenseType))[_typeId].id,
                          accountId: (await getAttributes(isar, AttributeType.account))[_accountId].id,
                        );
                        await isar.writeTxn(() async {
                          await isar.exchanges.put(exchange);
                        }).then((_) => Navigator.pop(context));
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
          ],
        ),
      ),
    );
  }
}
