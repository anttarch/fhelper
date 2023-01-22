import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';

class HistoryList extends StatelessWidget {
  const HistoryList({
    super.key,
    required this.day,
    required this.dayTotal,
    required this.items,
    this.contentPadding = EdgeInsets.zero,
  });
  final String day;
  final double dayTotal;
  final Map<String, double> items;
  final EdgeInsets contentPadding;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: contentPadding,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(day, style: Theme.of(context).textTheme.titleLarge),
              Text(
                dayTotal.toString(),
                style: Theme.of(context).textTheme.titleLarge!.apply(
                      color: const Color(0xff199225)
                          .harmonizeWith(Theme.of(context).colorScheme.primary),
                    ),
              ),
            ],
          ),
        ),
        ListView.separated(
          padding: const EdgeInsets.only(top: 6),
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
                    items.values.elementAt(index).toStringAsFixed(2),
                    style: TextStyle(color: valueColor),
                  ),
                  trailing: Icon(
                    Icons.arrow_right,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  onTap: () {},
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
