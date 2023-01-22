import 'package:fhelper/src/widgets/historylist.dart';
import 'package:flutter/material.dart';

enum _Date { today, week, month }

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  Set<_Date> _date = {_Date.today};
  final PageController _pageCtrl = PageController();

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
                curve: Curves.easeInOut,
              );
            },
          ),
        ),
        Expanded(
          child: PageView(
            controller: _pageCtrl,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              const SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: HistoryList(
                    contentPadding: EdgeInsets.symmetric(horizontal: 20),
                    day: 'Today',
                    dayTotal: 55.04,
                    items: {
                      'Petrol Station': -16.5,
                      'Football bet': 45.64,
                      'Stock Exchange': 25.9,
                    },
                  ),
                ),
              ),
              SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                      child: Card(
                        elevation: 0,
                        color: Theme.of(context).colorScheme.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                r'-$55.04',
                                textAlign: TextAlign.start,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge!
                                    .apply(
                                      color: const Color(0xff199225),
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: HistoryList(
                        contentPadding: EdgeInsets.symmetric(horizontal: 20),
                        day: 'Today',
                        dayTotal: 55.04,
                        items: {
                          'Petrol Station': -16.5,
                          'Football bet': 45.64,
                          'Stock Exchange': 25.9,
                        },
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: HistoryList(
                        contentPadding: EdgeInsets.symmetric(horizontal: 20),
                        day: 'Yesterday',
                        dayTotal: -36.50,
                        items: {
                          'Energy Bill': -78.5,
                          'Week Bonus': 32,
                          'Friends bet': 10,
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: double.infinity,
                width: double.infinity,
                color: Colors.blue,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
