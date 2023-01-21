import 'package:flutter/material.dart';

enum _Date { today, week, month }

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  Set<_Date> _date = {_Date.today};

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              'Show only:',
              textAlign: TextAlign.start,
              style: Theme.of(context).textTheme.labelMedium!.apply(
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
            ),
          ),
          SegmentedButton(
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
            onSelectionChanged: (p0) => setState(() {
              _date = p0;
            }),
          ),
        ],
      ),
    );
  }
}
