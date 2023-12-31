import 'package:dynamic_color/dynamic_color.dart';
import 'package:fhelper/src/logic/collections/attribute.dart';
import 'package:fhelper/src/logic/collections/card.dart' as fhelper;
import 'package:fhelper/src/logic/collections/card_bill.dart';
import 'package:fhelper/src/logic/collections/exchange.dart';
import 'package:fhelper/src/widgets/inputfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';

class ExchangeDetailsView extends StatefulWidget {
  const ExchangeDetailsView({required this.item, super.key});
  final Exchange item;

  @override
  State<ExchangeDetailsView> createState() => _ExchangeDetailsViewState();
}

class _ExchangeDetailsViewState extends State<ExchangeDetailsView> {
  bool isCardBill = false;
  String exchangeDate(DateTime date) {
    final dateWithoutTime = DateTime(date.year, date.month, date.day);
    if (date.isAtSameMomentAs(dateWithoutTime)) {
      return DateFormat.yMd(
        Localizations.localeOf(context).languageCode,
      ).format(date);
    }
    return DateFormat.yMd(
      Localizations.localeOf(context).languageCode,
    ).add_jm().format(date);
  }

  Attribute _displayString(
    Attribute child,
    Attribute? parent,
  ) {
    final localization = AppLocalizations.of(context)!;

    if (parent != null) {
      return child.copyWith(
        name: '${parent.name} - ${child.name}',
      );
    }
    return child.copyWith(
      name: '${localization.deleted} - ${child.name}',
    );
  }

  Widget _cardBillList() {
    final localization = AppLocalizations.of(context)!;
    final languageCode = Localizations.localeOf(context).languageCode;
    return FutureBuilder(
      future: getCardBillFromId(
        Isar.getInstance()!,
        widget.item.typeId,
      ).then((value) async {
        final installments = <Exchange>[];
        for (final id in value!.installmentIdList) {
          final installment = await Isar.getInstance()!.exchanges.get(id);
          if (installment != null) {
            installments.add(installment);
          }
        }
        return {value: installments};
      }),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final cardBill = snapshot.data!.keys.first;
          final installments = snapshot.data!.values.first;
          return Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Material(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: 10,
                    ),
                    child: Divider(
                      height: 4,
                      thickness: 2,
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                  Text(
                    localization.installments,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Card(
                    elevation: 0,
                    margin: const EdgeInsets.only(top: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: cardBill.installmentIdList.length,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final installmentNumber =
                            installments[index].description.split('#/spt#/')[0];
                        final description =
                            installments[index].description.split('#/spt#/')[1];
                        return Column(
                          children: [
                            ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              leading: const Icon(
                                Icons.credit_card,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              title: Text(
                                description,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              subtitle: Text(
                                NumberFormat.simpleCurrency(
                                  locale: languageCode,
                                ).format(
                                  installments[index].value,
                                ),
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .inverseSurface,
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    installmentNumber,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .apply(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .tertiary,
                                        ),
                                  ),
                                  Icon(
                                    Icons.arrow_right,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                  ),
                                ],
                              ),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute<ExchangeDetailsView>(
                                  builder: (context) => ExchangeDetailsView(
                                    item: installments[index],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                      separatorBuilder: (_, __) => Divider(
                        height: 2,
                        thickness: 1.5,
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return const CircularProgressIndicator.adaptive();
      },
    );
  }

  @override
  void initState() {
    if (widget.item.id == -1) {
      isCardBill = true;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final languageCode = Localizations.localeOf(context).languageCode;
    return ColoredBox(
      color: Theme.of(context).colorScheme.background,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
                        isCardBill
                            ? widget.item.description
                            : localization.details,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          Visibility(
                            visible: !isCardBill,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: InputField(
                                label: localization.description,
                                placeholder:
                                    widget.item.eType == EType.installment
                                        ? widget.item.description
                                            .split('#/spt#/')[1]
                                        : widget.item.description,
                                suffix: widget.item.eType == EType.installment
                                    ? widget.item.description
                                        .split('#/spt#/')[0]
                                    : null,
                                suffixStyle:
                                    widget.item.eType == EType.installment
                                        ? Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .apply(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .tertiary,
                                            )
                                        : null,
                                readOnly: true,
                              ),
                            ),
                          ),
                          Padding(
                            padding: isCardBill
                                ? EdgeInsets.zero
                                : const EdgeInsets.only(top: 20),
                            child: InputField(
                              label: widget.item.value.isNegative
                                  ? localization.price
                                  : localization.amount,
                              placeholder: NumberFormat.simpleCurrency(
                                locale: languageCode,
                              ).format(widget.item.value),
                              readOnly: true,
                              textColor: Color(
                                widget.item.eType == EType.expense ||
                                        widget.item.eType == EType.installment
                                    ? 0xffbd1c1c
                                    : 0xff199225,
                              ).harmonizeWith(
                                Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: InputField(
                              label: localization.date,
                              placeholder: exchangeDate(widget.item.date),
                              readOnly: true,
                            ),
                          ),
                          Visibility(
                            visible: widget.item.eType != EType.transfer &&
                                isCardBill == false,
                            child: FutureBuilder(
                              future: getAttributeFromId(
                                Isar.getInstance()!,
                                widget.item.typeId,
                                context: context,
                              ).then((value) async {
                                if (value != null) {
                                  final parent = await getAttributeFromId(
                                    Isar.getInstance()!,
                                    value.parentId!,
                                    context: context,
                                  );
                                  if (mounted) {
                                    return _displayString(value, parent);
                                  }
                                }
                                return value;
                              }),
                              builder: (context, snapshot) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 20),
                                  child: InputField(
                                    label: localization.type(1),
                                    placeholder: snapshot.hasData
                                        ? snapshot.data!.name
                                        : localization.deleted,
                                    readOnly: true,
                                  ),
                                );
                              },
                            ),
                          ),
                          FutureBuilder(
                            future: fhelper.getCardFromId(
                              Isar.getInstance()!,
                              widget.item.cardId,
                            ),
                            builder: (context, snapshot) {
                              return Visibility(
                                visible: widget.item.value.isNegative &&
                                    snapshot.hasData,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 20),
                                  child: InputField(
                                    label: localization.card(1),
                                    placeholder: snapshot.hasData
                                        ? snapshot.data!.name
                                        : '',
                                    readOnly: true,
                                  ),
                                ),
                              );
                            },
                          ),
                          if (widget.item.installments != null)
                            Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 20),
                                  child: InputField(
                                    label: localization.installments,
                                    placeholder:
                                        widget.item.installments.toString(),
                                    readOnly: true,
                                  ),
                                ),
                                if (widget.item.installmentValue != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 20),
                                    child: InputField(
                                      label: localization.perInstallmentValue,
                                      placeholder: NumberFormat.simpleCurrency(
                                        locale: languageCode,
                                      ).format(widget.item.installmentValue),
                                      readOnly: true,
                                    ),
                                  ),
                              ],
                            ),
                          if (widget.item.accountId != -1)
                            FutureBuilder(
                              future: getAttributeFromId(
                                Isar.getInstance()!,
                                widget.item.accountId,
                                context: context,
                              ).then((value) async {
                                if (value != null) {
                                  final parent = await getAttributeFromId(
                                    Isar.getInstance()!,
                                    value.parentId!,
                                    context: context,
                                  );
                                  if (mounted) {
                                    return _displayString(value, parent);
                                  }
                                }
                                return value;
                              }),
                              builder: (context, snapshot) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 20),
                                  child: InputField(
                                    label: widget.item.eType != EType.transfer
                                        ? localization.account(1)
                                        : localization.from,
                                    placeholder: snapshot.hasData
                                        ? snapshot.data!.name
                                        : localization.deleted,
                                    readOnly: true,
                                  ),
                                );
                              },
                            ),
                          if (widget.item.eType == EType.transfer)
                            FutureBuilder(
                              future: getAttributeFromId(
                                Isar.getInstance()!,
                                widget.item.accountIdEnd!,
                                context: context,
                              ).then((value) async {
                                if (value != null) {
                                  final parent = await getAttributeFromId(
                                    Isar.getInstance()!,
                                    value.parentId!,
                                    context: context,
                                  );
                                  if (mounted) {
                                    return _displayString(value, parent);
                                  }
                                }
                                return value;
                              }),
                              builder: (context, snapshot) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 20),
                                  child: InputField(
                                    label: localization.to,
                                    placeholder: snapshot.hasData
                                        ? snapshot.data!.name
                                        : localization.deleted,
                                    readOnly: true,
                                  ),
                                );
                              },
                            ),
                          if (widget.item.id == -1) _cardBillList(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: FilledButton.tonalIcon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: Text(localization.back),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
