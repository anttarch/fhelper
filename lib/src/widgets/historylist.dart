import 'package:dynamic_color/dynamic_color.dart';
import 'package:fhelper/src/logic/collections/exchange.dart';
import 'package:fhelper/src/logic/widgets/utils.dart' as wid_utils;
import 'package:fhelper/src/views/details/exchange_details.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoryList extends StatelessWidget {
  const HistoryList({
    required this.day,
    required this.dayTotal,
    required this.items,
    super.key,
    this.contentPadding = EdgeInsets.zero,
    this.showTotal = true,
  });
  final EdgeInsets contentPadding;
  final String day;
  final double dayTotal;
  final List<Exchange> items;
  final bool showTotal;

  Icon? _getLeadingIcon(Exchange exchange) {
    if (exchange.installments != null) {
      return const Icon(Icons.credit_card);
    } else if (exchange.eType == EType.transfer) {
      return const Icon(Icons.swap_horiz);
    } else if (exchange.id == -1) {
      return const Icon(Icons.receipt_long);
    }
    return null;
  }

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
                  NumberFormat.simpleCurrency(
                    locale: Localizations.localeOf(context).languageCode,
                  ).format(dayTotal),
                  style: Theme.of(context).textTheme.titleLarge!.apply(
                        color: Color(
                          dayTotal.isNegative ? 0xffbd1c1c : 0xff199225,
                        ).harmonizeWith(
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
            var valueColor =
                Color(items[index].value.isNegative ? 0xffbd1c1c : 0xff199225)
                    .harmonizeWith(Theme.of(context).colorScheme.primary);
            if (items[index].installments != null) {
              valueColor = Theme.of(context).colorScheme.inverseSurface;
            } else if (items[index].eType == EType.transfer) {
              valueColor = Theme.of(context).colorScheme.tertiary;
            }
            return Column(
              children: [
                ListTile(
                  contentPadding: contentPadding,
                  leading: _getLeadingIcon(items[index]),
                  shape: showTotal
                      ? null
                      : wid_utils.getShapeBorder(index, items.length - 1),
                  title: Text(
                    items[index].description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  subtitle: Text(
                    NumberFormat.simpleCurrency(
                      locale: Localizations.localeOf(context).languageCode,
                    ).format(items[index].value),
                    style: TextStyle(color: valueColor),
                  ),
                  trailing: Icon(
                    Icons.arrow_right,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute<ExchangeDetailsView>(
                      builder: (context) => ExchangeDetailsView(
                        item: items[index],
                      ),
                    ),
                  ),
                ),
              ],
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
      ],
    );
  }
}
