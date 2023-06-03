import 'package:dynamic_color/dynamic_color.dart';
import 'package:fhelper/src/logic/collections/card.dart' as fhelper;
import 'package:fhelper/src/logic/collections/card_bill.dart';
import 'package:fhelper/src/logic/collections/exchange.dart';
import 'package:fhelper/src/logic/functions/card_bill.dart';
import 'package:fhelper/src/logic/widgets/utils.dart' as wid_utils;
import 'package:fhelper/src/views/details/exchange_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';

class CardHistory extends StatefulWidget {
  const CardHistory({super.key, required this.card, this.cardBill});
  final fhelper.Card card;
  final CardBill? cardBill;

  @override
  State<CardHistory> createState() => _CardHistoryState();
}

class _CardHistoryState extends State<CardHistory> {
  BillPeriod _bill = BillPeriod.latest;
  int openIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.medium(
            title: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                AppLocalizations.of(context)!.cardHistory(widget.card.name),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child: Text(
                    AppLocalizations.of(context)!.showOnly,
                    textAlign: TextAlign.start,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SegmentedButton(
                    segments: [
                      ButtonSegment(
                        value: BillPeriod.past,
                        label: Text(AppLocalizations.of(context)!.past),
                      ),
                      ButtonSegment(
                        value: BillPeriod.latest,
                        label: Text(AppLocalizations.of(context)!.latest),
                        enabled: widget.cardBill != null,
                      ),
                      ButtonSegment(
                        value: BillPeriod.next,
                        label: Text(AppLocalizations.of(context)!.next),
                      ),
                    ],
                    selected: {_bill},
                    onSelectionChanged: (p0) {
                      setState(() {
                        _bill = p0.single;
                        openIndex = -1;
                      });
                    },
                  ),
                ),
                if (_bill != BillPeriod.latest)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    child: FutureBuilder(
                      future: getCardBillsFromCard(Isar.getInstance()!, widget.card.id, _bill).then((value) async {
                        final Map<CardBill, double> map = {};
                        if (value.isNotEmpty) {
                          for (final bill in value) {
                            double cardBillValue = 0;
                            for (final installmentId in bill.installmentIdList) {
                              final installment = await Isar.getInstance()!.exchanges.get(installmentId);
                              if (installment != null) {
                                cardBillValue += installment.value;
                              }
                            }
                            map.addAll({bill: cardBillValue});
                          }
                        }
                        return map;
                      }),
                      builder: (context, snapshot) {
                        final values = snapshot.data ?? {};
                        return ListView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: values.length,
                          itemBuilder: (context, index) {
                            final String name = DateFormat.yMMMM(
                              Localizations.localeOf(context).languageCode,
                            ).format(values.keys.elementAt(index).date);
                            final String value = NumberFormat.simpleCurrency(
                              locale: Localizations.localeOf(context).languageCode,
                            ).format(values.values.elementAt(index));
                            return Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  color: Theme.of(context).colorScheme.outlineVariant,
                                ),
                                borderRadius: const BorderRadius.all(Radius.circular(12)),
                              ),
                              child: AnimatedSize(
                                duration: const Duration(milliseconds: 150),
                                alignment: Alignment.topCenter,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      tileColor: Theme.of(context).colorScheme.primaryContainer,
                                      title: Text(name),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          DecoratedBox(
                                            decoration: BoxDecoration(
                                              color: Theme.of(context).colorScheme.surface,
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              child: Text(
                                                value,
                                                textAlign: TextAlign.start,
                                                style: Theme.of(context).textTheme.titleMedium!.apply(
                                                      color: const Color(0xffbd1c1c).harmonizeWith(
                                                        Theme.of(context).colorScheme.primary,
                                                      ),
                                                    ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 5),
                                          Icon(openIndex == index ? Icons.arrow_drop_down : Icons.arrow_drop_up)
                                        ],
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: openIndex == index ? const BorderRadius.vertical(top: Radius.circular(12)) : BorderRadius.circular(12),
                                      ),
                                      onTap: () {
                                        setState(() {
                                          if (openIndex == index) {
                                            openIndex = -1;
                                          } else {
                                            openIndex = index;
                                          }
                                        });
                                      },
                                    ),
                                    if (openIndex == index)
                                      DecoratedBox(
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).colorScheme.primaryContainer,
                                          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                                        ),
                                        child: FutureBuilder(
                                          future: getCardBillInstallments(Isar.getInstance()!, values.keys.elementAt(index).id),
                                          builder: (context, snapshot) {
                                            final List<Exchange> installments = snapshot.hasData ? snapshot.data! : [];
                                            return Card(
                                              elevation: 0,
                                              margin: const EdgeInsets.fromLTRB(10, 5, 10, 10),
                                              shape: RoundedRectangleBorder(
                                                side: BorderSide(
                                                  color: Theme.of(context).colorScheme.outlineVariant,
                                                ),
                                                borderRadius: const BorderRadius.all(Radius.circular(12)),
                                              ),
                                              child: ListView.separated(
                                                shrinkWrap: true,
                                                padding: EdgeInsets.zero,
                                                physics: const NeverScrollableScrollPhysics(),
                                                itemCount: installments.length,
                                                itemBuilder: (context, index) {
                                                  final String installmentNumber = installments[index].description.split('#/spt#/')[0];
                                                  final String description = installments[index].description.split('#/spt#/')[1];
                                                  return ListTile(
                                                    shape: wid_utils.getShapeBorder(index, installments.length - 1),
                                                    title: Text(description),
                                                    subtitle: Text(
                                                      NumberFormat.simpleCurrency(
                                                        locale: Localizations.localeOf(context).languageCode,
                                                      ).format(installments[index].value),
                                                      style: TextStyle(
                                                        color: const Color(0xffbd1c1c).harmonizeWith(
                                                          Theme.of(context).colorScheme.primary,
                                                        ),
                                                      ),
                                                    ),
                                                    trailing: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Text(
                                                          installmentNumber,
                                                          style: Theme.of(context).textTheme.bodyMedium!.apply(color: Theme.of(context).colorScheme.tertiary),
                                                        ),
                                                        Icon(
                                                          Icons.arrow_right,
                                                          color: Theme.of(context).colorScheme.onSurface,
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
                                                  );
                                                },
                                                separatorBuilder: (_, __) => Divider(
                                                  height: 2,
                                                  thickness: 1.5,
                                                  color: Theme.of(context).colorScheme.outlineVariant,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                if (widget.cardBill != null && _bill == BillPeriod.latest)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    child: FutureBuilder(
                      future: getCardBillInstallments(Isar.getInstance()!, widget.cardBill!.id),
                      builder: (context, snapshot) {
                        final List<Exchange> installments = snapshot.hasData ? snapshot.data! : [];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.latestBill,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Card(
                              elevation: 0,
                              margin: const EdgeInsets.only(top: 10),
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  color: Theme.of(context).colorScheme.outlineVariant,
                                ),
                                borderRadius: const BorderRadius.all(Radius.circular(12)),
                              ),
                              child: ListView.separated(
                                shrinkWrap: true,
                                padding: EdgeInsets.zero,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: installments.length,
                                itemBuilder: (context, index) {
                                  final String installmentNumber = installments[index].description.split('#/spt#/')[0];
                                  final String description = installments[index].description.split('#/spt#/')[1];
                                  return ListTile(
                                    shape: wid_utils.getShapeBorder(index, installments.length - 1),
                                    title: Text(description),
                                    subtitle: Text(
                                      NumberFormat.simpleCurrency(
                                        locale: Localizations.localeOf(context).languageCode,
                                      ).format(installments[index].value),
                                      style: TextStyle(
                                        color: const Color(0xffbd1c1c).harmonizeWith(
                                          Theme.of(context).colorScheme.primary,
                                        ),
                                      ),
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          installmentNumber,
                                          style: Theme.of(context).textTheme.bodyMedium!.apply(color: Theme.of(context).colorScheme.tertiary),
                                        ),
                                        Icon(
                                          Icons.arrow_right,
                                          color: Theme.of(context).colorScheme.onSurface,
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
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
