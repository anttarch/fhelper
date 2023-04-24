import 'package:dynamic_color/dynamic_color.dart';
import 'package:fhelper/src/logic/collections/attribute.dart';
import 'package:fhelper/src/logic/collections/exchange.dart';
import 'package:fhelper/src/views/details/exchange_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';

enum Period { today, allTime }

class AttributeDetailsView extends StatefulWidget {
  const AttributeDetailsView({super.key, required this.attribute});
  final Attribute attribute;

  @override
  State<AttributeDetailsView> createState() => _AttributeDetailsViewState();
}

class _AttributeDetailsViewState extends State<AttributeDetailsView> {
  late final Exchange? exchange;
  Period _time = Period.today;

  IconData _getTrendingIcon(double value) {
    if (value.isNegative) {
      return Icons.trending_down;
    } else if (value == 0) {
      return Icons.trending_flat;
    }
    return Icons.trending_up;
  }

  String _getTimeString() {
    switch (_time) {
      case Period.allTime:
        return AppLocalizations.of(context)!.totalDescription;
      default:
        return AppLocalizations.of(context)!.todayDescription;
    }
  }

  void _getLatest() {
    switch (widget.attribute.type) {
      case AttributeType.account:
        {
          exchange = Isar.getInstance()!
              .exchanges
              .where()
              .filter()
              .accountIdEqualTo(widget.attribute.id)
              .not()
              .eTypeEqualTo(EType.installment)
              .sortByDateDesc()
              .findFirstSync();
        }
        break;
      case AttributeType.expenseType:
      case AttributeType.incomeType:
        {
          exchange = Isar.getInstance()!
              .exchanges
              .where()
              .filter()
              .typeIdEqualTo(widget.attribute.id)
              .not()
              .eTypeEqualTo(EType.installment)
              .sortByDateDesc()
              .findFirstSync();
        }
        break;
      default:
        exchange = null;
    }
  }

  @override
  void initState() {
    _getLatest();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.medium(
            title: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                widget.attribute.name,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Visibility(
                    visible: exchange != null || (exchange != null && exchange!.eType == EType.transfer),
                    child: Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.latest,
                              textAlign: TextAlign.start,
                              style: Theme.of(context).textTheme.titleLarge!.apply(
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    exchange != null ? exchange!.description : 'Placeholder',
                                    textAlign: TextAlign.start,
                                    style: Theme.of(context).textTheme.bodyLarge!.apply(
                                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                                        ),
                                  ),
                                  Text(
                                    NumberFormat.simpleCurrency(
                                      locale: Localizations.localeOf(context).languageCode,
                                    ).format(
                                      exchange != null ? exchange!.value : 0,
                                    ),
                                    textAlign: TextAlign.start,
                                    style: Theme.of(context).textTheme.bodyLarge!.apply(
                                          color: Color(
                                            exchange != null
                                                ? exchange!.value.isNegative
                                                    ? 0xffbd1c1c
                                                    : 0xff199225
                                                : 0xff000000,
                                          ).harmonizeWith(
                                            Theme.of(context).colorScheme.primary,
                                          ),
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            OutlinedButton(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute<ExchangeDetailsView>(
                                  builder: (context) => ExchangeDetailsView(
                                    item: exchange!,
                                  ),
                                ),
                              ),
                              child: Text(AppLocalizations.of(context)!.details),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: widget.attribute.type == AttributeType.account,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: (MediaQuery.sizeOf(context).longestSide / 8) + 32,
                      ),
                      child: Card(
                        elevation: 0,
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        margin: const EdgeInsets.only(top: 10),
                        child: FutureBuilder(
                          future: getSumValueByAttribute(Isar.getInstance()!, widget.attribute.id, widget.attribute.type),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.done) {
                              final double value = snapshot.hasData ? snapshot.data! : 0;
                              return Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Icon(
                                      _getTrendingIcon(value),
                                      size: MediaQuery.sizeOf(context).longestSide / 8,
                                      color: Color(
                                        value.isNegative ? 0xffbd1c1c : 0xff199225,
                                      ).harmonizeWith(
                                        Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              _getTimeString(),
                                              style: Theme.of(context).textTheme.titleLarge!.apply(color: Theme.of(context).colorScheme.onSecondaryContainer),
                                            ),
                                            const SizedBox(width: 15),
                                            DecoratedBox(
                                              decoration: BoxDecoration(
                                                color: Theme.of(context).colorScheme.surface,
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                child: Text(
                                                  NumberFormat.simpleCurrency(locale: Localizations.localeOf(context).languageCode).format(value),
                                                  style: Theme.of(context).textTheme.titleLarge!.apply(
                                                        color: Color(
                                                          value.isNegative ? 0xffbd1c1c : 0xff199225,
                                                        ).harmonizeWith(
                                                          Theme.of(context).colorScheme.primary,
                                                        ),
                                                      ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const Spacer(),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 10),
                                          child: Column(
                                            children: [
                                              Text(
                                                AppLocalizations.of(context)!.showOnly,
                                                textAlign: TextAlign.start,
                                                style: Theme.of(context).textTheme.labelMedium!.apply(
                                                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                                                    ),
                                              ),
                                              SizedBox(
                                                width: MediaQuery.sizeOf(context).width - (MediaQuery.sizeOf(context).longestSide / 8) - 92,
                                                child: SegmentedButton(
                                                  segments: [
                                                    ButtonSegment(
                                                      value: Period.today,
                                                      label: Text(AppLocalizations.of(context)!.today),
                                                    ),
                                                    ButtonSegment(
                                                      value: Period.allTime,
                                                      label: Text(AppLocalizations.of(context)!.all),
                                                    ),
                                                  ],
                                                  selected: {_time},
                                                  showSelectedIcon: false,
                                                  onSelectionChanged: (p0) {
                                                    setState(() {
                                                      _time = p0.single;
                                                    });
                                                  },
                                                  style: ButtonStyle(
                                                    backgroundColor: MaterialStateProperty.resolveWith<Color>(
                                                      (Set<MaterialState> states) {
                                                        if (states.contains(MaterialState.selected)) {
                                                          return Theme.of(context).colorScheme.tertiaryContainer;
                                                        }
                                                        return Theme.of(context).colorScheme.surface;
                                                      },
                                                    ),
                                                    overlayColor: MaterialStateProperty.resolveWith<Color>(
                                                      (Set<MaterialState> states) {
                                                        if (states.contains(MaterialState.selected)) {
                                                          return Theme.of(context).colorScheme.onTertiaryContainer;
                                                        }
                                                        return Theme.of(context).colorScheme.onSurface;
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }
                            if (snapshot.connectionState == ConnectionState.active || snapshot.connectionState == ConnectionState.waiting) {
                              return SizedBox(
                                height: (MediaQuery.sizeOf(context).height / 8) + 32,
                                width: MediaQuery.sizeOf(context).width,
                                child: const Center(
                                  child: CircularProgressIndicator.adaptive(),
                                ),
                              );
                            }
                            return const Text('OOPS');
                          },
                        ),
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Visibility(
                        visible: exchange != null,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10, bottom: 15),
                          child: Divider(
                            height: 4,
                            thickness: 2,
                            color: Theme.of(context).colorScheme.outlineVariant,
                          ),
                        ),
                      ),
                      Text(
                        AppLocalizations.of(context)!.statistics,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: (MediaQuery.sizeOf(context).width / 2) - 25),
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: FutureBuilder(
                                    future: getAttributeUsage(Isar.getInstance()!, widget.attribute.id, widget.attribute.type, 0),
                                    builder: (context, snapshot) {
                                      final int percentage = snapshot.hasData ? snapshot.data! : 0;
                                      return Text(
                                        AppLocalizations.of(context)!
                                            .todayAttributeStatistics(percentage, (widget.attribute.type == AttributeType.account).toString()),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: (MediaQuery.sizeOf(context).width / 2) - 25),
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: FutureBuilder(
                                    future: getAttributeUsage(Isar.getInstance()!, widget.attribute.id, widget.attribute.type, 1),
                                    builder: (context, snapshot) {
                                      final int percentage = snapshot.hasData ? snapshot.data! : 0;
                                      return Text(
                                        AppLocalizations.of(context)!
                                            .allAttributeStatistics(percentage, (widget.attribute.type == AttributeType.account).toString()),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SafeArea(
                        top: false,
                        child: Card(
                          elevation: 0,
                          margin: const EdgeInsets.only(top: 10),
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              color: Theme.of(context).colorScheme.outlineVariant,
                            ),
                            borderRadius: const BorderRadius.all(Radius.circular(12)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                if (widget.attribute.type == AttributeType.account)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        AppLocalizations.of(context)!.relatedCardsDescription,
                                        style: Theme.of(context).textTheme.titleMedium,
                                      ),
                                      FutureBuilder(
                                        future: checkForAttributeDependencies(Isar.getInstance()!, widget.attribute.id, widget.attribute.type, dependency: 1),
                                        builder: (context, snapshot) {
                                          final String count = snapshot.hasData ? snapshot.data!.toString() : '';
                                          return Text(
                                            count,
                                            style: Theme.of(context).textTheme.titleMedium,
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      AppLocalizations.of(context)!.relatedTransactionsDescription,
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                    FutureBuilder(
                                      future: checkForAttributeDependencies(Isar.getInstance()!, widget.attribute.id, widget.attribute.type, dependency: 0),
                                      builder: (context, snapshot) {
                                        final String count = snapshot.hasData ? snapshot.data!.toString() : '';
                                        return Text(
                                          count,
                                          style: Theme.of(context).textTheme.titleMedium,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
