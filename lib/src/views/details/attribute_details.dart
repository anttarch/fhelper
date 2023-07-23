import 'package:dynamic_color/dynamic_color.dart';
import 'package:fhelper/src/logic/collections/attribute.dart';
import 'package:fhelper/src/logic/collections/exchange.dart';
import 'package:fhelper/src/logic/utils.dart';
import 'package:fhelper/src/logic/widgets/utils.dart' as wid_utils;
import 'package:fhelper/src/views/details/exchange_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';

enum Period { today, allTime }

class AttributeDetailsView extends StatefulWidget {
  const AttributeDetailsView({required this.attribute, super.key});
  final Attribute attribute;

  @override
  State<AttributeDetailsView> createState() => _AttributeDetailsViewState();
}

class _AttributeDetailsViewState extends State<AttributeDetailsView> {
  Period _time = Period.today;

  Color _getColor(BuildContext context, Exchange? exchange) {
    if (exchange != null) {
      var valueColor =
          Color(exchange.value.isNegative ? 0xffbd1c1c : 0xff199225)
              .harmonizeWith(Theme.of(context).colorScheme.primary);
      if (exchange.installments != null) {
        valueColor = Theme.of(context).colorScheme.inverseSurface;
      } else if (exchange.eType == EType.transfer) {
        valueColor = Theme.of(context).colorScheme.tertiary;
      }
      return valueColor;
    }
    return Theme.of(context).colorScheme.inverseSurface;
  }

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

  IconData _getTrendingIcon(double value) {
    if (value.isNegative) {
      return Icons.trending_down;
    } else if (value == 0) {
      return Icons.trending_flat;
    }
    return Icons.trending_up;
  }

  String _getTimeString() => switch (_time) {
        Period.allTime => AppLocalizations.of(context)!.totalDescription,
        _ => AppLocalizations.of(context)!.todayDescription
      };

  Widget _latestExchange() {
    final localization = AppLocalizations.of(context)!;
    final languageCode = Localizations.localeOf(context).languageCode;
    return FutureBuilder(
      future: getLatest(
        Isar.getInstance()!,
        attributeId: widget.attribute.id,
        attributeType: widget.attribute.type,
      ).then((value) async {
        if (value != null && value.eType == EType.transfer) {
          final transfer = value.copyWith(
            description: await wid_utils.parseTransferName(context, value),
          );
          return transfer;
        }
        return value;
      }),
      builder: (context, snapshot) {
        final exchange = snapshot.data;
        return Visibility(
          visible: exchange != null ||
              (exchange != null && exchange.eType == EType.transfer),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Card(
                elevation: 4,
                margin: const EdgeInsets.only(top: 10),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        localization.latestDescriptor,
                        textAlign: TextAlign.start,
                        style: Theme.of(context).textTheme.titleLarge!.apply(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (exchange != null &&
                                      (exchange.installments != null ||
                                          exchange.id == -1 ||
                                          exchange.eType == EType.transfer))
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        right: 5,
                                      ),
                                      child: _getLeadingIcon(
                                        exchange,
                                      ),
                                    ),
                                  Flexible(
                                    child: Text(
                                      exchange != null
                                          ? exchange.description
                                          : 'Placeholder',
                                      textAlign: TextAlign.start,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .apply(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onSurfaceVariant,
                                          ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 15),
                              child: Text(
                                NumberFormat.simpleCurrency(
                                  locale: languageCode,
                                ).format(
                                  exchange != null ? exchange.value : 0,
                                ),
                                textAlign: TextAlign.start,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .apply(color: _getColor(context, exchange)),
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
                        child: Text(
                          localization.details,
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: exchange != null &&
                    widget.attribute.type != AttributeType.account,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 15),
                  child: Divider(
                    height: 4,
                    thickness: 2,
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _trendingWidget(num value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Icon(
          _getTrendingIcon(value.toDouble()),
          size: MediaQuery.sizeOf(context).longestSide / 11,
          color: Color(
            value.isNegative ? 0xffbd1c1c : 0xff199225,
          ).harmonizeWith(
            Theme.of(context).colorScheme.primary,
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _getTimeString(),
              style: Theme.of(context).textTheme.titleLarge!.apply(
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
            ),
            const SizedBox(width: 15),
            DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                child: Text(
                  NumberFormat.simpleCurrency(
                    locale: Localizations.localeOf(
                      context,
                    ).languageCode,
                  ).format(value),
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
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.medium(
            title: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                widget.attribute.name,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _latestExchange(),
                  Visibility(
                    visible: widget.attribute.type == AttributeType.account,
                    child: Card(
                      elevation: 0,
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      margin: const EdgeInsets.only(top: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FutureBuilder(
                              future: getSumValueByAttribute(
                                Isar.getInstance()!,
                                widget.attribute.id,
                                widget.attribute.type,
                                time: _time.index,
                              ),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.done) {
                                  final value =
                                      snapshot.hasData ? snapshot.data! : 0;
                                  return _trendingWidget(value);
                                }
                                if (snapshot.connectionState ==
                                        ConnectionState.active ||
                                    snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                  return SizedBox(
                                    height:
                                        MediaQuery.sizeOf(context).longestSide /
                                            11,
                                    width: MediaQuery.sizeOf(context).width,
                                    child: const Center(
                                      child:
                                          CircularProgressIndicator.adaptive(),
                                    ),
                                  );
                                }
                                return const Text('OOPS');
                              },
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Text(
                                    localization.showOnly,
                                    textAlign: TextAlign.start,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium!
                                        .apply(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSecondaryContainer,
                                        ),
                                  ),
                                ),
                                SegmentedButton(
                                  segments: [
                                    ButtonSegment(
                                      value: Period.today,
                                      label: Text(
                                        localization.today,
                                      ),
                                    ),
                                    ButtonSegment(
                                      value: Period.allTime,
                                      label: Text(
                                        localization.all,
                                      ),
                                    ),
                                  ],
                                  selected: {_time},
                                  onSelectionChanged: (p0) {
                                    setState(() {
                                      _time = p0.single;
                                    });
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty
                                        .resolveWith<Color>(
                                      (Set<MaterialState> states) {
                                        if (states
                                            .contains(MaterialState.selected)) {
                                          return Theme.of(context)
                                              .colorScheme
                                              .tertiaryContainer;
                                        }
                                        return Theme.of(context)
                                            .colorScheme
                                            .surface;
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Visibility(
                        visible: widget.attribute.type == AttributeType.account,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10, bottom: 15),
                          child: Divider(
                            height: 4,
                            thickness: 2,
                            color: Theme.of(context).colorScheme.outlineVariant,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          localization.statistics,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth:
                                    (MediaQuery.sizeOf(context).width / 2) - 25,
                              ),
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: FutureBuilder(
                                    future: getAttributeUsage(
                                      Isar.getInstance()!,
                                      widget.attribute.id,
                                      widget.attribute.type,
                                      0,
                                    ),
                                    builder: (context, snapshot) {
                                      final percentage =
                                          snapshot.hasData ? snapshot.data! : 0;
                                      return Text(
                                        localization.todayAttributeStatistics(
                                          percentage,
                                          (widget.attribute.type ==
                                                  AttributeType.account)
                                              .toString(),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth:
                                    (MediaQuery.sizeOf(context).width / 2) - 25,
                              ),
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: FutureBuilder(
                                    future: getAttributeUsage(
                                      Isar.getInstance()!,
                                      widget.attribute.id,
                                      widget.attribute.type,
                                      1,
                                    ),
                                    builder: (context, snapshot) {
                                      final percentage =
                                          snapshot.hasData ? snapshot.data! : 0;
                                      return Text(
                                        localization.allAttributeStatistics(
                                          percentage,
                                          (widget.attribute.type ==
                                                  AttributeType.account)
                                              .toString(),
                                        ),
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
                              color:
                                  Theme.of(context).colorScheme.outlineVariant,
                            ),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(12)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                if (widget.attribute.type ==
                                    AttributeType.account)
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        localization.relatedCardsDescription,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                      ),
                                      FutureBuilder(
                                        future: checkForAttributeDependencies(
                                          Isar.getInstance()!,
                                          widget.attribute.id,
                                          widget.attribute.type,
                                          dependency: 1,
                                        ),
                                        builder: (context, snapshot) {
                                          final count = snapshot.hasData
                                              ? snapshot.data!.toString()
                                              : '';
                                          return Text(
                                            count,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium,
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      localization
                                          .relatedTransactionsDescription,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                    FutureBuilder(
                                      future: checkForAttributeDependencies(
                                        Isar.getInstance()!,
                                        widget.attribute.id,
                                        widget.attribute.type,
                                        dependency: 0,
                                      ),
                                      builder: (context, snapshot) {
                                        final count = snapshot.hasData
                                            ? snapshot.data!.toString()
                                            : '';
                                        return Text(
                                          count,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
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
