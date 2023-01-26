import 'package:dynamic_color/dynamic_color.dart';
import 'package:fhelper/src/logic/collections/exchange.dart';
import 'package:fhelper/src/widgets/historylist.dart';
import 'package:flutter/material.dart';
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
                                        snapshot.data?.toStringAsFixed(2) ??
                                            0.toStringAsFixed(2),
                                        textAlign: TextAlign.start,
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
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: HistoryList(
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 20),
                            day: 'Today',
                            dayTotal: 55.04,
                            showTotal: false,
                            items: isar.exchanges.where().findAllSync(),
                          ),
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
                                        snapshot.data?.toStringAsFixed(2) ??
                                            0.toStringAsFixed(2),
                                        textAlign: TextAlign.start,
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
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: HistoryList(
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 20),
                            day: 'Today',
                            dayTotal: isar.exchanges
                                .where()
                                .valueProperty()
                                .sumSync(),
                            items: isar.exchanges.where().findAllSync(),
                          ),
                        ),
                        // const Padding(
                        //   padding: EdgeInsets.only(top: 20),
                        //   child: HistoryList(
                        //     contentPadding: EdgeInsets.symmetric(horizontal: 20),
                        //     day: 'Yesterday',
                        //     dayTotal: -36.50,
                        //     items: {
                        //       'Energy Bill': -78.5,
                        //       'Week Bonus': 32,
                        //       'Friends bet': 10,
                        //     },
                        //   ),
                        // ),
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
                                        snapshot.data?.toStringAsFixed(2) ??
                                            0.toStringAsFixed(2),
                                        textAlign: TextAlign.start,
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
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: HistoryList(
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 20),
                            day: 'Today',
                            dayTotal: 55.04,
                            items: isar.exchanges.where().findAllSync(),
                          ),
                        ),
                        // const Padding(
                        //   padding: EdgeInsets.only(top: 20),
                        //   child: HistoryList(
                        //     contentPadding: EdgeInsets.symmetric(horizontal: 20),
                        //     day: 'Yesterday',
                        //     dayTotal: -36.50,
                        //     items: {
                        //       'Energy Bill': -78.5,
                        //       'Week Bonus': 32,
                        //       'Friends bet': 10,
                        //     },
                        //   ),
                        // ),
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
