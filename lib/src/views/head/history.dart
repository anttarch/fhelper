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
              Container(
                height: double.infinity,
                width: double.infinity,
                color: Colors.black,
              ),
              Container(
                height: double.infinity,
                width: double.infinity,
                color: Colors.red,
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
