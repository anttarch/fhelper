import 'package:dynamic_color/dynamic_color.dart';
import 'package:fhelper/src/views/details/details.dart';
import 'package:flutter/material.dart';

class HistoryList extends StatelessWidget {
  const HistoryList({
    super.key,
    this.contentPadding = EdgeInsets.zero,
    required this.day,
    required this.dayTotal,
    required this.items,
    this.showTotal = true,
  });
  final EdgeInsets contentPadding;
  final String day;
  final double dayTotal;
  final Map<String, double> items;
  final bool showTotal;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showTotal)
          Padding(
            padding: contentPadding,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(day, style: Theme.of(context).textTheme.titleLarge),
                Text(
                  dayTotal.isNegative
                      ? dayTotal.toStringAsFixed(2).replaceAll('-', r'-$')
                      : r'+$' + dayTotal.toStringAsFixed(2),
                  style: Theme.of(context).textTheme.titleLarge!.apply(
                        color: const Color(0xff199225).harmonizeWith(
                          Theme.of(context).colorScheme.primary,
                        ),
                      ),
                ),
              ],
            ),
          ),
        ListView.separated(
          padding: showTotal ? const EdgeInsets.only(top: 6) : EdgeInsets.zero,
          shrinkWrap: true,
          itemCount: items.length,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            Color valueColor = const Color(0xff199225)
                .harmonizeWith(Theme.of(context).colorScheme.primary);
            if (items.values.elementAt(index).isNegative) {
              valueColor = const Color(0xffbd1c1c)
                  .harmonizeWith(Theme.of(context).colorScheme.primary);
            }
            return Column(
              children: [
                ListTile(
                  contentPadding: contentPadding,
                  title: Text(
                    items.keys.elementAt(index),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  subtitle: Text(
                    items.values.elementAt(index).isNegative
                        ? items.values
                            .elementAt(index)
                            .toStringAsFixed(2)
                            .replaceAll('-', r'-$')
                        : r'+$' +
                            items.values.elementAt(index).toStringAsFixed(2),
                    style: TextStyle(color: valueColor),
                  ),
                  trailing: Icon(
                    Icons.arrow_right,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute<DetailsView>(
                      builder: (context) => DetailsView(
                        item: Map.fromEntries({items.entries.elementAt(index)}),
                      ),
                    ),
                  ),
                ),
                if (index == items.length - 1)
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
              ],
            );
          },
          separatorBuilder: (_, __) => Divider(
            height: 1,
            thickness: 1,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
      ],
    );
  }
}
