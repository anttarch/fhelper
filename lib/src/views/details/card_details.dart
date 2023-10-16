import 'package:dynamic_color/dynamic_color.dart';
import 'package:fhelper/src/logic/collections/card.dart' as fhelper;
import 'package:fhelper/src/logic/collections/card_bill.dart';
import 'package:fhelper/src/logic/collections/exchange.dart';
import 'package:fhelper/src/logic/functions/card_bill.dart';
import 'package:fhelper/src/views/details/card_history.dart';
import 'package:fhelper/src/views/details/exchange_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';

class CardDetailsView extends StatefulWidget {
  const CardDetailsView({required this.card, super.key});
  final fhelper.Card card;

  @override
  State<CardDetailsView> createState() => _CardDetailsViewState();
}

class _CardDetailsViewState extends State<CardDetailsView> {
  late final CardBill? cardbill;
  bool notFirstBill = true;

  Widget _cardBillInfo() {
    final localization = AppLocalizations.of(context)!;
    final languageCode = Localizations.localeOf(context).languageCode;
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.tertiaryContainer,
      margin: const EdgeInsets.only(top: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                FutureBuilder(
                  future: getAvailableLimit(
                    Isar.getInstance()!,
                    widget.card,
                  ),
                  builder: (context, snapshot) {
                    final value = snapshot.hasData ? snapshot.data! : 0.0;
                    final percentage =
                        (widget.card.limit - value) / widget.card.limit;
                    return Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Text(
                            '${(percentage * 100).round()}%',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall!
                                .apply(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onTertiaryContainer,
                                ),
                          ),
                          SizedBox(
                            height:
                                MediaQuery.sizeOf(context).longestSide / 11 +
                                    Theme.of(context)
                                        .textTheme
                                        .headlineSmall!
                                        .fontSize!,
                            width: MediaQuery.sizeOf(context).longestSide / 11 +
                                Theme.of(context)
                                    .textTheme
                                    .headlineSmall!
                                    .fontSize!,
                            child: CircularProgressIndicator(
                              value: (widget.card.limit - value) /
                                  widget.card.limit,
                              backgroundColor:
                                  Theme.of(context).colorScheme.surface,
                              strokeWidth: 15,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                FutureBuilder(
                  future: Future<double>(() async {
                    var cardBillValue = 0.0;
                    if (cardbill != null) {
                      for (final installmentId in cardbill!.installmentIdList) {
                        final installment = await Isar.getInstance()!
                            .exchanges
                            .get(installmentId);
                        if (installment != null) {
                          cardBillValue += installment.value;
                        }
                      }
                    }
                    return cardBillValue;
                  }),
                  builder: (context, snapshot) {
                    final value = snapshot.hasData ? snapshot.data! : 0;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            localization.billDescriptor,
                            style:
                                Theme.of(context).textTheme.titleLarge!.apply(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onTertiaryContainer,
                                    ),
                            overflow: TextOverflow.fade,
                          ),
                        ),
                        const SizedBox(width: 15),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            child: Text(
                              NumberFormat.simpleCurrency(
                                locale: languageCode,
                              ).format(value),
                              style:
                                  Theme.of(context).textTheme.titleLarge!.apply(
                                        color: Color(
                                          value.isNegative
                                              ? 0xffbd1c1c
                                              : 0xff199225,
                                        ).harmonizeWith(
                                          Theme.of(context).colorScheme.primary,
                                        ),
                                      ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Divider(
                    height: 16,
                    thickness: 2,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                FutureBuilder(
                  future: getAvailableLimit(
                    Isar.getInstance()!,
                    widget.card,
                  ),
                  builder: (context, snapshot) {
                    final value = snapshot.hasData ? snapshot.data! : 0;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              localization.usedDescriptor,
                              style:
                                  Theme.of(context).textTheme.titleLarge!.apply(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onTertiaryContainer,
                                      ),
                            ),
                            const SizedBox(width: 15),
                            DecoratedBox(
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                child: Text(
                                  NumberFormat.simpleCurrency(
                                    locale: languageCode,
                                  ).format(
                                    widget.card.limit - value,
                                  ),
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge!
                                      .apply(
                                        color: const Color(
                                          0xffbd1c1c,
                                        ).harmonizeWith(
                                          Theme.of(context).colorScheme.primary,
                                        ),
                                      ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                localization.availableDescriptor,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge!
                                    .apply(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onTertiaryContainer,
                                    ),
                              ),
                              const SizedBox(width: 15),
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surface,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  child: Text(
                                    NumberFormat.simpleCurrency(
                                      locale: languageCode,
                                    ).format(value),
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge!
                                        .apply(
                                          color: const Color(0xff199225)
                                              .harmonizeWith(
                                            Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          ),
                                        ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardBillHistory() {
    final localization = AppLocalizations.of(context)!;
    final languageCode = Localizations.localeOf(context).languageCode;
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(top: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: FutureBuilder(
        future: getCardBillsFromCard(
          Isar.getInstance()!,
          widget.card.id,
          BillPeriod.next,
          findOne: true,
        ).then((value) async {
          var cardBillValue = 0.0;
          if (value.isNotEmpty) {
            final nextBill = value.first;
            for (final installmentId in nextBill.installmentIdList) {
              final installment =
                  await Isar.getInstance()!.exchanges.get(installmentId);
              if (installment != null) {
                cardBillValue += installment.value;
              }
            }
          }
          return cardBillValue;
        }),
        builder: (context, snapshot) {
          final nextBillValue = snapshot.data ?? 0;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (nextBillValue != 0)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              localization.nextBillDescriptor,
                              style:
                                  Theme.of(context).textTheme.titleLarge!.apply(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSecondaryContainer,
                                      ),
                            ),
                            const SizedBox(width: 15),
                            DecoratedBox(
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                child: Text(
                                  NumberFormat.simpleCurrency(
                                    locale: languageCode,
                                  ).format(nextBillValue),
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge!
                                      .apply(
                                        color: const Color(0xffbd1c1c)
                                            .harmonizeWith(
                                          Theme.of(context).colorScheme.primary,
                                        ),
                                      ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(
                      height: 0,
                    ),
                  ],
                ),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: nextBillValue != 0
                      ? const BorderRadius.vertical(
                          bottom: Radius.circular(12),
                        )
                      : BorderRadius.circular(12),
                ),
                title: Text(
                  localization.seeHistory,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                trailing: Icon(
                  Icons.arrow_right,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute<CardHistory>(
                    builder: (context) => CardHistory(
                      card: widget.card,
                      cardBill: cardbill,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _cardBillExchanges() {
    final localization = AppLocalizations.of(context)!;
    final languageCode = Localizations.localeOf(context).languageCode;
    return FutureBuilder(
      future: getCardBillInstallments(
        Isar.getInstance()!,
        cardbill!.id,
      ),
      builder: (context, snapshot) {
        final installments = snapshot.hasData ? snapshot.data! : <Exchange>[];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 15),
              child: Divider(
                height: 4,
                thickness: 2,
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            Text(
              localization.latestBill,
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
                  final installmentNumber =
                      installments[index].description.split('#/spt#/')[0];
                  final description =
                      installments[index].description.split('#/spt#/')[1];
                  return ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    title: Text(description),
                    subtitle: Text(
                      NumberFormat.simpleCurrency(
                        locale: languageCode,
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
                          style: Theme.of(context).textTheme.bodyMedium!.apply(
                                color: Theme.of(context).colorScheme.tertiary,
                              ),
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
    );
  }

  @override
  void initState() {
    super.initState();
    cardbill = Isar.getInstance()!
        .cardBills
        .where()
        .filter()
        .cardIdEqualTo(widget.card.id)
        .dateBetween(
          DateTime(DateTime.now().year, DateTime.now().month),
          DateTime(DateTime.now().year, DateTime.now().month + 1),
        )
        .sortByDateDesc()
        .findFirstSync();
    final billCount = Isar.getInstance()!
        .cardBills
        .where()
        .filter()
        .cardIdEqualTo(widget.card.id)
        .countSync();
    notFirstBill = billCount > 1;
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
                widget.card.name,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _cardBillInfo(),
                  if (notFirstBill) _cardBillHistory(),
                  if (cardbill != null) _cardBillExchanges(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
