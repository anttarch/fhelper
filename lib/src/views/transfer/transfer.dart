import 'package:dynamic_color/dynamic_color.dart';
import 'package:fhelper/src/logic/collections/attribute.dart';
import 'package:fhelper/src/logic/collections/exchange.dart';
import 'package:fhelper/src/widgets/inputfield.dart';
import 'package:fhelper/src/widgets/listchoice.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';

class TransferView extends StatefulWidget {
  const TransferView({super.key});

  @override
  State<TransferView> createState() => _TransferViewState();
}

class _TransferViewState extends State<TransferView> {
  int _accountId = -1;
  int _accountIdEnd = -1;
  double _accountFromValue = 0;
  final List<String?> displayText = [
    // Origin
    null,
    // Destination
    null,
  ];
  final TextEditingController _controller = TextEditingController();

  void _addDialog(AttributeType attributeType) {
    final TextEditingController controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (context) {
        final formKey = GlobalKey<FormState>();
        return WillPopScope(
          onWillPop: () {
            controller.clear();
            return Future<bool>.value(true);
          },
          child: AlertDialog(
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
                      type: attributeType,
                    );
                    await isar.writeTxn(() async {
                      await isar.attributes.put(attribute);
                    }).then((_) {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    });
                    controller.clear();
                  }
                },
                label: Text(AppLocalizations.of(context)!.add),
              ),
            ],
          ),
        );
      },
    );
  }

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.background,
      child: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height - 68 - MediaQuery.of(context).padding.bottom - MediaQuery.of(context).padding.top,
              child: CustomScrollView(
                slivers: [
                  SliverAppBar.medium(
                    title: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        AppLocalizations.of(context)!.transfer,
                        style: Theme.of(context).textTheme.headlineMedium,
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
                            FutureBuilder(
                              future: getAttributes(
                                Isar.getInstance()!,
                                AttributeType.account,
                              ),
                              builder: (context, snapshot) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 20),
                                  child: FutureBuilder(
                                    future: getSumValueByAttribute(
                                      Isar.getInstance()!,
                                      _accountId != -1 ? snapshot.data![_accountId].id : -1,
                                      AttributeType.account,
                                    ),
                                    builder: (context, sum) {
                                      return InputField(
                                        label: AppLocalizations.of(context)!.from,
                                        readOnly: true,
                                        placeholder: displayText[0],
                                        suffix: NumberFormat.simpleCurrency(locale: Localizations.localeOf(context).languageCode).format(sum.data ?? 0),
                                        suffixStyle: TextStyle(
                                          color: Color(
                                            sum.hasData && sum.data! < 0 ? 0xffbd1c1c : 0xff199225,
                                          ).harmonizeWith(
                                            Theme.of(context).colorScheme.primary,
                                          ),
                                        ),
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
                                                            onPressed: () => _addDialog(AttributeType.account),
                                                            icon: const Icon(Icons.add),
                                                            label: Text(AppLocalizations.of(context)!.add),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    ListChoice(
                                                      groupValue: _accountId,
                                                      onChanged: (value) async {
                                                        setState(() {
                                                          _accountId = value!;
                                                          if (_accountIdEnd == value) {
                                                            _accountIdEnd = -1;
                                                            displayText[1] = null;
                                                          }
                                                        });
                                                        await getSumValueByAttribute(
                                                          Isar.getInstance()!,
                                                          _accountId != -1 ? snapshot.data![_accountId].id : -1,
                                                          AttributeType.account,
                                                        ).then((value) {
                                                          setState(() {
                                                            _accountFromValue = value;
                                                          });
                                                          Navigator.pop(context);
                                                        });
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
                                                  () => displayText[0] = snapshot.hasData ? snapshot.data![_accountId].name : null,
                                                )
                                              : null,
                                        ),
                                      );
                                    },
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
                                    label: AppLocalizations.of(context)!.to,
                                    locked: _accountId == -1,
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
                                                        onPressed: () => _addDialog(AttributeType.account),
                                                        icon: const Icon(Icons.add),
                                                        label: Text(AppLocalizations.of(context)!.add),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                ListChoice(
                                                  groupValue: _accountIdEnd,
                                                  hiddenIndex: _accountId,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      _accountIdEnd = value!;
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
                                      (_) => _accountIdEnd != -1
                                          ? setState(
                                              () => displayText[1] = snapshot.hasData ? snapshot.data![_accountIdEnd].name : null,
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
                                controller: _controller,
                                label: AppLocalizations.of(context)!.amount,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  CurrencyInputFormatter(
                                    locale: Localizations.localeOf(context).languageCode,
                                  )
                                ],
                                validator: (value) {
                                  final String numberValue = value!.replaceAll(RegExp('[^0-9]'), '');
                                  if (value.isEmpty) {
                                    return AppLocalizations.of(context)!.emptyField;
                                  } else if (numberValue == '000') {
                                    return AppLocalizations.of(context)!.invalidValue;
                                  }

                                  if ((double.parse(numberValue) / 100) > _accountFromValue) {
                                    return AppLocalizations.of(context)!.insufficientFunds;
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
            ),
            Padding(
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
                          final String value = _controller.text.replaceAll(RegExp('[^0-9]'), '');
                          final Isar isar = Isar.getInstance()!;
                          final Attribute from = (await getAttributes(isar, AttributeType.account))[_accountId];
                          final Attribute to = (await getAttributes(isar, AttributeType.account))[_accountIdEnd];
                          final Exchange exchange = Exchange(
                            eType: EType.transfer,
                            description: '${from.name}#/spt#/${to.name}',
                            value: double.parse(value) / 100,
                            date: DateTime.now(),
                            typeId: -1,
                            accountId: from.id,
                            accountIdEnd: to.id,
                          );
                          await isar.writeTxn(() async {
                            await isar.exchanges.put(exchange);
                          }).then((_) => Navigator.pop(context));
                        }
                      },
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
