import 'package:dynamic_color/dynamic_color.dart';
import 'package:fhelper/src/logic/collections/exchange.dart';
import 'package:fhelper/src/widgets/inputfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DetailsView extends StatefulWidget {
  const DetailsView({super.key, required this.item});
  final Exchange item;

  @override
  State<DetailsView> createState() => _DetailsViewState();
}

class _DetailsViewState extends State<DetailsView> {
  String exchangeDate(DateTime date) {
    final dateWithoutTime = DateTime(date.year, date.month, date.day);
    if (date.isAtSameMomentAs(dateWithoutTime)) {
      return DateFormat.yMd().format(date);
    }
    return DateFormat.yMd().add_jm().format(date);
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.background,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height -
                  88 -
                  MediaQuery.of(context).padding.bottom -
                  MediaQuery.of(context).padding.top,
              child: CustomScrollView(
                slivers: [
                  SliverAppBar.medium(
                    title: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        'Details',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: InputField(
                              label: 'Description',
                              placeholder: widget.item.description,
                              readOnly: true,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: InputField(
                              label: widget.item.value.isNegative
                                  ? 'Price'
                                  : 'Amount',
                              placeholder: NumberFormat.simpleCurrency()
                                  .format(widget.item.value),
                              readOnly: true,
                              textColor: Color(
                                widget.item.eType == EType.expense
                                    ? 0xffbd1c1c
                                    : 0xff199225,
                              ).harmonizeWith(
                                Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: InputField(
                              label: 'Date',
                              placeholder: exchangeDate(widget.item.date),
                              readOnly: true,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: InputField(
                              label: 'Type',
                              placeholder: widget.item.type,
                              readOnly: true,
                            ),
                          ),
                          Visibility(
                            visible: widget.item.value.isNegative,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: InputField(
                                label: 'Card',
                                placeholder: widget.item.cardId.toString(),
                                readOnly: true,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: InputField(
                              label: 'Account',
                              placeholder: widget.item.account,
                              readOnly: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: FilledButton.tonalIcon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
