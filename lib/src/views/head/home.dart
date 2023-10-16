import 'package:dynamic_color/dynamic_color.dart';
import 'package:fhelper/src/logic/collections/attribute.dart';
import 'package:fhelper/src/logic/collections/exchange.dart';
import 'package:fhelper/src/logic/utils.dart';
import 'package:fhelper/src/logic/widgets/utils.dart' as wid_utils;
import 'package:fhelper/src/views/add/add.dart';
import 'package:fhelper/src/views/details/exchange_details.dart';
import 'package:fhelper/src/views/transfer/transfer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Icon? _getLeadingIcon(Exchange exchange, Color iconColor) {
    if (exchange.installments != null) {
      return Icon(Icons.credit_card, color: iconColor);
    } else if (exchange.eType == EType.transfer) {
      return Icon(Icons.swap_horiz, color: iconColor);
    } else if (exchange.id == -1) {
      return Icon(Icons.receipt_long, color: iconColor);
    }
    return null;
  }

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

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final languageCode = Localizations.localeOf(context).languageCode;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: StreamBuilder(
        stream: Isar.getInstance()!.exchanges.watchLazy(),
        builder: (context, _) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FutureBuilder(
                future: getLatest(Isar.getInstance()!, context: context)
                    .then((value) async {
                  if (value != null && value.eType == EType.transfer) {
                    final transfer = value.copyWith(
                      description:
                          await wid_utils.parseTransferName(context, value),
                    );
                    return transfer;
                  }
                  return value;
                }),
                builder: (context, snapshot) {
                  final exchange = snapshot.data;
                  return Visibility(
                    visible: exchange != null ||
                        exchange != null && exchange.eType == EType.transfer,
                    child: Card(
                      elevation: 4,
                      margin: const EdgeInsets.only(top: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              localization.latestDescriptor,
                              textAlign: TextAlign.start,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge!
                                  .apply(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (exchange != null &&
                                            (exchange.installments != null ||
                                                exchange.id == -1 ||
                                                exchange.eType ==
                                                    EType.transfer))
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(right: 5),
                                            child: _getLeadingIcon(
                                              exchange,
                                              Theme.of(context)
                                                  .colorScheme
                                                  .inverseSurface,
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
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurfaceVariant,
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
                                          .apply(
                                            color: _getColor(context, exchange),
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
                              child: Text(localization.details),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              FutureBuilder(
                future: getSumValue(Isar.getInstance()!, context),
                builder: (context, snapshot) {
                  return Card(
                    elevation: 0,
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    margin: const EdgeInsets.only(top: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Semantics(
                            label: localization.totalValueHistoryCard(
                              localization.today,
                              snapshot.data ?? 0,
                            ),
                            container: true,
                            readOnly: true,
                            child: ExcludeSemantics(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    localization.today,
                                    textAlign: TextAlign.start,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge!
                                        .apply(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSecondaryContainer,
                                        ),
                                  ),
                                  if (snapshot.hasData)
                                    DecoratedBox(
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surface,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        child: Text(
                                          NumberFormat.simpleCurrency(
                                            locale: languageCode,
                                          ).format(snapshot.data),
                                          textAlign: TextAlign.start,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge!
                                              .apply(
                                                color: Color(
                                                  snapshot.data!.isNegative
                                                      ? 0xffbd1c1c
                                                      : 0xff199225,
                                                ).harmonizeWith(
                                                  Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                ),
                                              ),
                                        ),
                                      ),
                                    )
                                  else if (snapshot.connectionState ==
                                          ConnectionState.active ||
                                      snapshot.connectionState ==
                                          ConnectionState.waiting)
                                    const CircularProgressIndicator.adaptive()
                                  else
                                    const Text('OOPS'),
                                ],
                              ),
                            ),
                          ),
                          FilledButton.icon(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute<AddView>(
                                builder: (context) => const AddView(),
                              ),
                            ),
                            icon: const Icon(Icons.add),
                            label: Text(
                              localization.add,
                              semanticsLabel: localization.addTransactionFAB,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                  ),
                  margin: const EdgeInsets.only(top: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          localization.transfer,
                          textAlign: TextAlign.start,
                          style: Theme.of(context).textTheme.titleLarge!.apply(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                        ),
                        FutureBuilder(
                          future: Isar.getInstance()!
                              .attributes
                              .filter()
                              .typeEqualTo(AttributeType.account)
                              .roleEqualTo(AttributeRole.child)
                              .count(),
                          builder: (context, snapshot) {
                            final visible =
                                Isar.getInstance()!.exchanges.countSync() ==
                                        0 ||
                                    snapshot.hasData && snapshot.data! == 1;
                            final enabled =
                                Isar.getInstance()!.exchanges.countSync() > 0 &&
                                    snapshot.hasData &&
                                    snapshot.data! > 1;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Visibility(
                                  visible: visible,
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 5),
                                    child: Text(
                                      snapshot.hasData && snapshot.data! == 1
                                          ? localization
                                              .transferAccountRequirement
                                          : localization
                                              .transferExchangeRequirement,
                                      textAlign: TextAlign.start,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .apply(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                    ),
                                  ),
                                ),
                                Semantics(
                                  button: true,
                                  child: FilledButton.tonalIcon(
                                    onPressed: enabled
                                        ? () => Navigator.push(
                                              context,
                                              MaterialPageRoute<TransferView>(
                                                builder: (context) =>
                                                    const TransferView(),
                                              ),
                                            )
                                        : null,
                                    icon: const Icon(Icons.swap_horiz),
                                    label: Text(localization.transfer),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
