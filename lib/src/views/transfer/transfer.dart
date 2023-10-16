import 'package:dynamic_color/dynamic_color.dart';
import 'package:fhelper/src/logic/collections/attribute.dart';
import 'package:fhelper/src/logic/collections/exchange.dart';
import 'package:fhelper/src/logic/widgets/show_attribute_dialog.dart';
import 'package:fhelper/src/logic/widgets/show_selector_bottom_sheet.dart';
import 'package:fhelper/src/widgets/inputfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';

class TransferView extends StatefulWidget {
  const TransferView({super.key});

  @override
  State<TransferView> createState() => _TransferViewState();
}

class _TransferViewState extends State<TransferView> {
  (int parentId, int childId) _accountId = (-1, -1);
  (int parentId, int childId) _accountIdEnd = (-1, -1);
  double _accountFromValue = 0;
  final List<String?> displayText = [
    // Origin
    null,
    // Destination
    null,
  ];
  final List<TextEditingController> _controller = [
    TextEditingController(),

    // controller for dialog
    TextEditingController(),
  ];

  final _formKey = GlobalKey<FormState>();

  Widget _accountFrom() {
    final localization = AppLocalizations.of(context)!;
    final languageCode = Localizations.localeOf(context).languageCode;
    return FutureBuilder(
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
          child: FutureBuilder(
            future: getSumValueByAttribute(
              Isar.getInstance()!,
              _accountId != (-1, -1)
                  ? snapshot.data!.values
                      .toList()[_accountId.$1][_accountId.$2]
                      .id
                  : -1,
              AttributeType.account,
            ),
            builder: (context, sum) {
              return InputField(
                label: localization.from,
                readOnly: true,
                placeholder: displayText[0] ?? localization.select,
                suffix: displayText[0] != null
                    ? NumberFormat.simpleCurrency(locale: languageCode)
                        .format(sum.data)
                    : null,
                suffixStyle: TextStyle(
                  color: Color(
                    sum.hasData && sum.data! < 0 ? 0xffbd1c1c : 0xff199225,
                  ).harmonizeWith(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty || displayText[0] == null) {
                    return localization.emptyField;
                  }
                  return null;
                },
                onTap: () => showSelectorBottomSheet<String?>(
                  context: context,
                  groupValue: _accountId,
                  title: localization.selectAccount,
                  onSelect: (name, value) async {
                    setState(() {
                      _accountId = value! as (int, int);
                      if (_accountIdEnd == value) {
                        _accountIdEnd = (-1, -1);
                        displayText[1] = null;
                      }
                    });
                    await getSumValueByAttribute(
                      Isar.getInstance()!,
                      _accountId != (-1, -1)
                          ? snapshot.data!.values
                              .toList()[_accountId.$1][_accountId.$2]
                              .id
                          : -1,
                      AttributeType.account,
                    ).then((value) {
                      setState(() {
                        _accountFromValue = value;
                      });
                      Navigator.pop(context, name);
                    });
                  },
                  action: TextButton.icon(
                    onPressed: () => showAttributeDialog<void>(
                      context: context,
                      attributeRole: AttributeRole.child,
                      attributeType: AttributeType.account,
                      controller: _controller[1],
                    ).then(
                      (_) => _controller[1].clear(),
                    ),
                    icon: const Icon(Icons.add),
                    label: Text(localization.add),
                  ),
                ).then(
                  (name) {
                    if (_accountId != (-1, -1) && name != null) {
                      setState(() => displayText[0] = name);
                    }
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _accountTo() {
    final localization = AppLocalizations.of(context)!;
    return FutureBuilder(
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
            label: localization.to,
            locked: _accountId == (-1, -1),
            readOnly: true,
            placeholder: displayText[1] ?? localization.select,
            validator: (value) {
              if (value!.isEmpty || displayText[1] == null) {
                return localization.emptyField;
              }
              return null;
            },
            onTap: () => showSelectorBottomSheet<String?>(
              context: context,
              groupValue: _accountIdEnd,
              title: localization.selectAccount,
              onSelect: (name, value) {
                setState(() {
                  _accountIdEnd = value! as (int, int);
                });
                Navigator.pop(context, name);
              },
              action: TextButton.icon(
                onPressed: () => showAttributeDialog<void>(
                  context: context,
                  attributeRole: AttributeRole.child,
                  attributeType: AttributeType.account,
                  controller: _controller[1],
                ).then(
                  (_) => _controller[1].clear(),
                ),
                icon: const Icon(Icons.add),
                label: Text(localization.add),
              ),
            ).then(
              (name) {
                if (_accountIdEnd != (-1, -1) && name != null) {
                  setState(() => displayText[1] = name);
                }
              },
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    for (final controller in _controller) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final languageCode = Localizations.localeOf(context).languageCode;
    return ColoredBox(
      color: Theme.of(context).colorScheme.background,
      child: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height -
                  68 -
                  MediaQuery.of(context).padding.bottom -
                  MediaQuery.of(context).padding.top,
              child: CustomScrollView(
                slivers: [
                  SliverAppBar.medium(
                    title: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        localization.transfer,
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
                            _accountFrom(),
                            _accountTo(),
                            Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: InputField(
                                controller: _controller[0],
                                label: localization.amount,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  CurrencyInputFormatter(
                                    locale: languageCode,
                                  ),
                                ],
                                validator: (value) {
                                  final numberValue =
                                      value!.replaceAll(RegExp('[^0-9]'), '');
                                  if (value.isEmpty) {
                                    return localization.emptyField;
                                  } else if (numberValue == '000') {
                                    return localization.invalidValue;
                                  }

                                  if ((double.parse(numberValue) / 100) >
                                      _accountFromValue) {
                                    return localization.insufficientFunds;
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
                      child: Text(localization.cancel),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final value = _controller[0]
                              .text
                              .replaceAll(RegExp('[^0-9]'), '');
                          final isar = Isar.getInstance()!;
                          final from =
                              (await getAttributes(isar, AttributeType.account))
                                  .values
                                  .toList()[_accountId.$1][_accountId.$2];
                          final to =
                              (await getAttributes(isar, AttributeType.account))
                                  .values
                                  .toList()[_accountIdEnd.$1][_accountIdEnd.$2];
                          final exchange = Exchange(
                            eType: EType.transfer,
                            description: '#/str#/#/spt#/#/str#/',
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
                      icon: const Icon(Icons.swap_horiz),
                      label: Text(localization.transfer),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
