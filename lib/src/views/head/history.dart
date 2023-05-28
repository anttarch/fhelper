import 'package:async/async.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:fhelper/src/logic/collections/card.dart' as fhelper;
import 'package:fhelper/src/logic/collections/card_bill.dart';
import 'package:fhelper/src/logic/collections/exchange.dart';
import 'package:fhelper/src/views/details/card_details.dart';
import 'package:fhelper/src/widgets/historylist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';

enum Time { today, week, month }

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  Time _time = Time.today;
  Isar isar = Isar.getInstance()!;
  final TextEditingController _controller = TextEditingController();

  final Map<Time, int> _indexMap = {Time.today: 0, Time.week: 1, Time.month: 2};

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          container: true,
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
                      value: Time.today,
                      label: Text(AppLocalizations.of(context)!.today),
                    ),
                    ButtonSegment(
                      value: Time.week,
                      label: Text(AppLocalizations.of(context)!.week),
                    ),
                    ButtonSegment(
                      value: Time.month,
                      label: Text(AppLocalizations.of(context)!.month),
                    ),
                  ],
                  selected: {_time},
                  onSelectionChanged: (p0) {
                    setState(() {
                      _time = p0.single;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        StreamBuilder(
          stream: StreamGroup.merge([isar.exchanges.watchLazy(), isar.cardBills.watchLazy()]),
          builder: (context, snapshot) {
            return Column(
              children: [
                FutureBuilder(
                  future: getSumValue(isar, context, time: _indexMap[_time]!).then((value) async {
                    if (mounted) {
                      final List<Exchange> billsAsExchange = await getCardBillsAsExchanges(isar, context, time: _indexMap[_time]!);
                      double finalValue = value;
                      if (billsAsExchange.isNotEmpty) {
                        for (final bill in billsAsExchange) {
                          finalValue += bill.value;
                        }
                      }
                      // This still is necessary to avoid calling context across async gaps
                      if (!mounted) {
                        return {
                          '': [finalValue]
                        };
                      }
                      return {
                        '': [finalValue],
                        ...await getPendingCardBills(isar, context, time: _indexMap[_time]!)
                      };
                    }
                    return {'': <double>[]};
                  }),
                  builder: (context, snapshot) {
                    final Map<String, List<double>> cardsValues = {};
                    if (snapshot.hasData) {
                      cardsValues
                        ..addAll(snapshot.data!)
                        ..remove('')
                        ..removeWhere((key, value) => value[0] == 0);
                    }
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                      child: AnimatedSize(
                        alignment: Alignment.topCenter,
                        duration: const Duration(milliseconds: 100),
                        curve: Curves.easeInOut,
                        child: Card(
                          color: Theme.of(context).colorScheme.tertiaryContainer,
                          margin: const EdgeInsets.only(bottom: 15),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Semantics(
                                  label: AppLocalizations.of(context)!.totalValueHistoryCard(
                                    AppLocalizations.of(context)!.dateSelector(_indexMap[_time]!),
                                    snapshot.hasData ? snapshot.data!.values.first.first : 0,
                                  ),
                                  readOnly: true,
                                  excludeSemantics: true,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        AppLocalizations.of(context)!.dateSelector(_indexMap[_time]!),
                                        textAlign: TextAlign.start,
                                        style: Theme.of(context).textTheme.titleLarge!.apply(
                                              color: Theme.of(context).colorScheme.onTertiaryContainer,
                                            ),
                                      ),
                                      DecoratedBox(
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).colorScheme.surface,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          child: Text(
                                            NumberFormat.simpleCurrency(
                                              locale: Localizations.localeOf(context).languageCode,
                                            ).format(
                                              snapshot.hasData ? snapshot.data!.values.first.first : 0,
                                            ),
                                            textAlign: TextAlign.start,
                                            style: Theme.of(context).textTheme.titleLarge!.apply(
                                                  color: Color(
                                                    snapshot.hasData
                                                        ? snapshot.data!.values.first.first.isNegative
                                                            ? 0xffbd1c1c
                                                            : 0xff199225
                                                        : 0xff000000,
                                                  ).harmonizeWith(
                                                    Theme.of(context).colorScheme.primary,
                                                  ),
                                                ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (cardsValues.isNotEmpty)
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(top: 10),
                                        child: Divider(
                                          height: 4,
                                          thickness: 2,
                                          color: Theme.of(context).colorScheme.tertiary,
                                        ),
                                      ),
                                      Card(
                                        child: ListView.separated(
                                          shrinkWrap: true,
                                          padding: EdgeInsets.zero,
                                          physics: const NeverScrollableScrollPhysics(),
                                          itemCount: cardsValues.entries.length,
                                          itemBuilder: (context, index) {
                                            return ListTile(
                                              contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              title: Text(cardsValues.keys.elementAt(index)),
                                              subtitle: Text(
                                                NumberFormat.simpleCurrency(
                                                  locale: Localizations.localeOf(context).languageCode,
                                                ).format(
                                                  snapshot.hasData ? cardsValues.values.elementAt(index).first : 0,
                                                ),
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                  color: const Color(0xffbd1c1c).harmonizeWith(
                                                    Theme.of(context).colorScheme.primary,
                                                  ),
                                                ),
                                              ),
                                              onTap: () async {
                                                final Isar isar = Isar.getInstance()!;
                                                final int cardId = cardsValues.values.elementAt(index).last.toInt();
                                                final fhelper.Card? card = await isar.cards.get(cardId);
                                                if (mounted) {
                                                  await Navigator.push(
                                                    context,
                                                    MaterialPageRoute<CardDetailsView>(
                                                      builder: (context) => CardDetailsView(
                                                        card: card!,
                                                      ),
                                                    ),
                                                  );
                                                }
                                              },
                                              trailing: IconButton.filled(
                                                onPressed: () => showDialog<void>(
                                                  context: context,
                                                  builder: (context) {
                                                    return AlertDialog(
                                                      title: Text(AppLocalizations.of(context)!.confirmPayQuestion),
                                                      content: Text(AppLocalizations.of(context)!.irreversibleAction),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () => Navigator.pop(context),
                                                          child: Text(AppLocalizations.of(context)!.cancel),
                                                        ),
                                                        TextButton(
                                                          onPressed: () async {
                                                            final Isar isar = Isar.getInstance()!;
                                                            final int cardId = cardsValues.values.elementAt(index).last.toInt();
                                                            final CardBill? bill = await isar.cardBills.get(cardId);
                                                            if (bill != null) {
                                                              final CardBill newBill = bill.copyWith(confirmed: true);
                                                              await isar.writeTxn(() async {
                                                                await isar.cardBills.put(newBill);
                                                              }).then((_) => Navigator.pop(context));
                                                            }
                                                          },
                                                          child: Text(AppLocalizations.of(context)!.confirm),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                ),
                                                icon: Icon(
                                                  Icons.check,
                                                  color: Theme.of(context).colorScheme.onPrimary,
                                                ),
                                              ),
                                            );
                                          },
                                          separatorBuilder: (_, __) => Divider(
                                            height: 2,
                                            thickness: 1.5,
                                            indent: 16,
                                            endIndent: 16,
                                            color: Theme.of(context).colorScheme.outlineVariant,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                FutureBuilder(
                  future: getExchanges(isar, context, time: _indexMap[_time]!).then((value) async {
                    if (mounted) {
                      final List<Exchange> billExchange = await getCardBillsAsExchanges(isar, context, time: _indexMap[_time]!);
                      if (billExchange.isNotEmpty) {
                        final List<Exchange> list = [...value, ...billExchange]..sort(
                            (a, b) => b.date.compareTo(a.date),
                          );
                        return list;
                      }
                      return value;
                    }
                    return <Exchange>[];
                  }),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      if (_indexMap[_time]! != 0) {
                        // This function separates the raw result of `getExchanges()` into days,
                        // while doing the calculation for the total value of each day
                        //
                        // First it collects every day available from `getExchanges()` result
                        // maping each day number to a dummy value, then it cycles through the
                        // map (`days`) and the snapshot list finding which exchange was made in
                        // each day and adding to the final list (`exchangeLists`) while summing
                        // the exchange's value on top of the dummy value of `days`
                        //
                        // This approach can only be done for defined periods of time that will "reset"
                        // like weeks and months
                        // Also its (logicaly) limited to a max of `DateTime.now()`, so probably won't work on
                        // dates on the future  (not tested)
                        // The overhead for processing multiple exchanges with multiple days is presumed
                        // to be high (not tested)
                        final Map<int, double> days = {};
                        final List<List<Exchange>> exchangeLists = [];
                        for (final exchange in snapshot.data!) {
                          if (!days.keys.contains(exchange.date.day)) {
                            days.addAll({exchange.date.day: 0});
                          }
                        }
                        for (final day in days.keys) {
                          for (final element in snapshot.data!) {
                            if (element.date.day == day) {
                              if (exchangeLists.length > days.keys.toList().indexOf(day)) {
                                exchangeLists[days.keys.toList().indexOf(day)].add(element);
                              } else {
                                exchangeLists.add([element]);
                              }
                              if (element.eType != EType.transfer && element.installments == null) {
                                days.update(
                                  day,
                                  (value) => value += element.value,
                                );
                              }
                            }
                          }
                        }
                        return Card(
                          elevation: 0,
                          margin: const EdgeInsets.symmetric(horizontal: 22),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: Theme.of(context).colorScheme.outlineVariant,
                            ),
                          ),
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          child: Padding(
                            padding: exchangeLists.isNotEmpty ? const EdgeInsets.only(top: 16) : EdgeInsets.zero,
                            child: ListView.separated(
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: exchangeLists.length,
                              itemBuilder: (context, index) {
                                return HistoryList(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                                  day: days.keys.toList()[index] == DateTime.now().day
                                      ? AppLocalizations.of(context)!.today
                                      : days.keys.toList()[index] == DateTime.now().day - 1
                                          ? AppLocalizations.of(context)!.yesterday
                                          : _indexMap[_time]! == 1
                                              ? DateFormat.EEEE(
                                                  Localizations.localeOf(
                                                    context,
                                                  ).languageCode,
                                                ).format(
                                                  DateTime(
                                                    DateTime.now().year,
                                                    DateTime.now().month,
                                                    days.keys.toList()[index],
                                                  ),
                                                )
                                              : AppLocalizations.of(context)!.historyListDayDate(
                                                  DateTime(
                                                    DateTime.now().year,
                                                    DateTime.now().month,
                                                    days.keys.toList()[index],
                                                  ),
                                                ),
                                  dayTotal: days.values.toList()[index],
                                  items: exchangeLists[index],
                                );
                              },
                              separatorBuilder: (_, __) => Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Divider(
                                  height: 2,
                                  thickness: 1.5,
                                  color: Theme.of(context).colorScheme.outlineVariant,
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                      return Card(
                        elevation: 0,
                        margin: const EdgeInsets.symmetric(horizontal: 22),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.outlineVariant,
                          ),
                        ),
                        child: HistoryList(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                          ),
                          day: '',
                          dayTotal: 0,
                          showTotal: false,
                          items: snapshot.data!,
                        ),
                      );
                    } else {
                      if (snapshot.connectionState == ConnectionState.active || snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator.adaptive();
                      }
                      return const Text('OOPS');
                    }
                  },
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
