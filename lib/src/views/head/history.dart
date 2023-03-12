import 'package:dynamic_color/dynamic_color.dart';
import 'package:fhelper/src/logic/collections/exchange.dart';
import 'package:fhelper/src/widgets/historylist.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';

enum _Date { today, week, month }

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  Set<_Date> _date = {_Date.today};
  final PageController _pageCtrl = PageController();
  Isar isar = Isar.getInstance()!;

  final Map<_Date, int> _indexMap = {
    _Date.today: 0,
    _Date.week: 1,
    _Date.month: 2
  };
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
          child: Text(
            'Show only:',
            textAlign: TextAlign.start,
            style: Theme.of(context).textTheme.labelMedium!.apply(
                  color: Theme.of(context).colorScheme.onBackground,
                ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SegmentedButton(
            segments: const [
              ButtonSegment(
                value: _Date.today,
                label: Text('Today'),
              ),
              ButtonSegment(
                value: _Date.week,
                label: Text('Week'),
              ),
              ButtonSegment(
                value: _Date.month,
                label: Text('Month'),
              ),
            ],
            selected: _date,
            onSelectionChanged: (p0) {
              setState(() {
                _date = p0;
              });
              _pageCtrl.animateToPage(
                _indexMap.entries.firstWhere((e) => e.key == p0.single).value,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeIn,
              );
            },
          ),
        ),
        StreamBuilder(
          stream: isar.exchanges.watchLazy(),
          builder: (context, snapshot) {
            return Expanded(
              child: PageView(
                controller: _pageCtrl,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        FutureBuilder(
                          future: getSumValue(isar),
                          builder: (context, snapshot) {
                            return Padding(
                              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                              child: Card(
                                elevation: 0,
                                color: Theme.of(context).colorScheme.surface,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.outline,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Today',
                                        textAlign: TextAlign.start,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge!
                                            .apply(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface,
                                            ),
                                      ),
                                      Text(
                                        NumberFormat.simpleCurrency().format(
                                          snapshot.hasData ? snapshot.data : 0,
                                        ),
                                        textAlign: TextAlign.start,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge!
                                            .apply(
                                              color: Color(
                                                snapshot.hasData
                                                    ? snapshot.data!.isNegative
                                                        ? 0xffbd1c1c
                                                        : 0xff199225
                                                    : 0xff000000,
                                              ).harmonizeWith(
                                                Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                              ),
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        FutureBuilder(
                          future: getExchanges(isar, context),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 4),
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
                              if (snapshot.connectionState ==
                                      ConnectionState.active ||
                                  snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              }
                              return const Text('OOPS');
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        FutureBuilder(
                          future: getSumValue(isar, time: 1),
                          builder: (context, snapshot) {
                            return Padding(
                              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                              child: Card(
                                elevation: 0,
                                color: Theme.of(context).colorScheme.surface,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.outline,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'This Week',
                                        textAlign: TextAlign.start,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge!
                                            .apply(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface,
                                            ),
                                      ),
                                      Text(
                                        NumberFormat.simpleCurrency().format(
                                          snapshot.hasData ? snapshot.data : 0,
                                        ),
                                        textAlign: TextAlign.start,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge!
                                            .apply(
                                              color: Color(
                                                snapshot.hasData
                                                    ? snapshot.data!.isNegative
                                                        ? 0xffbd1c1c
                                                        : 0xff199225
                                                    : 0xff000000,
                                              ).harmonizeWith(
                                                Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                              ),
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        FutureBuilder(
                          future: getExchanges(isar, context, time: 1),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
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
                                    if (exchangeLists.length >
                                        days.keys.toList().indexOf(day)) {
                                      exchangeLists[
                                              days.keys.toList().indexOf(day)]
                                          .add(element);
                                    } else {
                                      exchangeLists.add([element]);
                                    }
                                    days.update(
                                      day,
                                      (value) => value += element.value,
                                    );
                                  }
                                }
                              }

                              return ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: exchangeLists.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 20),
                                    child: HistoryList(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 20,
                                      ),
                                      day: days.keys.toList()[index] ==
                                              DateTime.now().day
                                          ? 'Today'
                                          : days.keys.toList()[index] ==
                                                  DateTime.now().day - 1
                                              ? 'Yesterday'
                                              : 'Other day',
                                      dayTotal: days.values.toList()[index],
                                      items: exchangeLists[index],
                                    ),
                                  );
                                },
                              );
                            } else {
                              if (snapshot.connectionState ==
                                      ConnectionState.active ||
                                  snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              }
                              return const Text('OOPS');
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        FutureBuilder(
                          future: getSumValue(isar, time: 2),
                          builder: (context, snapshot) {
                            return Padding(
                              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                              child: Card(
                                elevation: 0,
                                color: Theme.of(context).colorScheme.surface,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.outline,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'This Month',
                                        textAlign: TextAlign.start,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge!
                                            .apply(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface,
                                            ),
                                      ),
                                      Text(
                                        NumberFormat.simpleCurrency().format(
                                          snapshot.hasData ? snapshot.data : 0,
                                        ),
                                        textAlign: TextAlign.start,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge!
                                            .apply(
                                              color: Color(
                                                snapshot.hasData
                                                    ? snapshot.data!.isNegative
                                                        ? 0xffbd1c1c
                                                        : 0xff199225
                                                    : 0xff000000,
                                              ).harmonizeWith(
                                                Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                              ),
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        FutureBuilder(
                          future: getExchanges(isar, context, time: 2),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
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
                                    if (exchangeLists.length >
                                        days.keys.toList().indexOf(day)) {
                                      exchangeLists[
                                              days.keys.toList().indexOf(day)]
                                          .add(element);
                                    } else {
                                      exchangeLists.add([element]);
                                    }
                                    days.update(
                                      day,
                                      (value) => value += element.value,
                                    );
                                  }
                                }
                              }

                              return ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: exchangeLists.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 20),
                                    child: HistoryList(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 20,
                                      ),
                                      day: days.keys.toList()[index] ==
                                              DateTime.now().day
                                          ? 'Today'
                                          : days.keys.toList()[index] ==
                                                  DateTime.now().day - 1
                                              ? 'Yesterday'
                                              : 'Other day',
                                      dayTotal: days.values.toList()[index],
                                      items: exchangeLists[index],
                                    ),
                                  );
                                },
                              );
                            } else {
                              if (snapshot.connectionState ==
                                      ConnectionState.active ||
                                  snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              }
                              return const Text('OOPS');
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
