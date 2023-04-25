import 'package:dynamic_color/dynamic_color.dart';
import 'package:fhelper/src/logic/collections/attribute.dart';
import 'package:fhelper/src/logic/collections/exchange.dart';
import 'package:fhelper/src/logic/utils.dart';
import 'package:fhelper/src/views/add/add.dart';
import 'package:fhelper/src/views/details/exchange_details.dart';
import 'package:fhelper/src/views/transfer/transfer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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

  Color _getColor(BuildContext context, Exchange? exchange) {
    if (exchange != null) {
      Color valueColor = Color(exchange.value.isNegative ? 0xffbd1c1c : 0xff199225).harmonizeWith(Theme.of(context).colorScheme.primary);
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: StreamBuilder(
        stream: Isar.getInstance()!.exchanges.watchLazy(),
        builder: (context, _) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FutureBuilder(
                future: getLatest(Isar.getInstance()!),
                builder: (context, snapshot) {
                  final exchange = snapshot.data;
                  return Visibility(
                    visible: exchange != null || exchange != null && exchange.eType == EType.transfer,
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
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (exchange != null && (exchange.installments != null || exchange.id == -1 || exchange.eType == EType.transfer))
                                        Padding(
                                          padding: const EdgeInsets.only(right: 5),
                                          child: _getLeadingIcon(exchange),
                                        ),
                                      Text(
                                        exchange != null
                                            ? exchange.eType == EType.transfer
                                                ? AppLocalizations.of(context)!
                                                    .transferDescription(exchange.description.split('#/spt#/')[0], exchange.description.split('#/spt#/')[1])
                                                : exchange.description
                                            : 'Placeholder',
                                        textAlign: TextAlign.start,
                                        style: Theme.of(context).textTheme.bodyLarge!.apply(
                                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                                            ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    NumberFormat.simpleCurrency(
                                      locale: Localizations.localeOf(context).languageCode,
                                    ).format(
                                      exchange != null ? exchange.value : 0,
                                    ),
                                    textAlign: TextAlign.start,
                                    style: Theme.of(context).textTheme.bodyLarge!.apply(
                                          color: _getColor(context, exchange),
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
                  );
                },
              ),
              FutureBuilder(
                future: getSumValue(Isar.getInstance()!, context),
                builder: (context, snapshot) {
                  return Card(
                    elevation: 0,
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.today,
                                textAlign: TextAlign.start,
                                style: Theme.of(context).textTheme.titleLarge!.apply(
                                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                                    ),
                              ),
                              if (snapshot.hasData)
                                DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.surface,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    child: Text(
                                      NumberFormat.simpleCurrency(
                                        locale: Localizations.localeOf(context).languageCode,
                                      ).format(snapshot.data),
                                      textAlign: TextAlign.start,
                                      style: Theme.of(context).textTheme.titleLarge!.apply(
                                            color: Color(
                                              snapshot.data!.isNegative ? 0xffbd1c1c : 0xff199225,
                                            ).harmonizeWith(
                                              Theme.of(context).colorScheme.primary,
                                            ),
                                          ),
                                    ),
                                  ),
                                )
                              else if (snapshot.connectionState == ConnectionState.active || snapshot.connectionState == ConnectionState.waiting)
                                const CircularProgressIndicator.adaptive()
                              else
                                const Text('OOPS')
                            ],
                          ),
                          FilledButton.icon(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute<AddView>(
                                builder: (context) => const AddView(),
                              ),
                            ),
                            icon: const Icon(Icons.add),
                            label: Text(AppLocalizations.of(context)!.add),
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
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.transfer,
                          textAlign: TextAlign.start,
                          style: Theme.of(context).textTheme.titleLarge!.apply(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                        ),
                        FutureBuilder(
                          future: getAttributes(Isar.getInstance()!, AttributeType.account),
                          builder: (context, snapshot) {
                            return Visibility(
                              visible: Isar.getInstance()!.exchanges.countSync() == 0 || snapshot.hasData && snapshot.data!.length == 1,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 5),
                                child: Text(
                                  snapshot.hasData && snapshot.data!.length == 1
                                      ? AppLocalizations.of(context)!.transferAccountRequirement
                                      : AppLocalizations.of(context)!.transferExchangeRequirement,
                                  textAlign: TextAlign.start,
                                  style: Theme.of(context).textTheme.bodyLarge!.apply(color: Theme.of(context).colorScheme.onSurfaceVariant),
                                ),
                              ),
                            );
                          },
                        ),
                        FutureBuilder(
                          future: getAttributes(Isar.getInstance()!, AttributeType.account),
                          builder: (context, snapshot) {
                            return FilledButton.tonalIcon(
                              onPressed: Isar.getInstance()!.exchanges.countSync() > 0 && snapshot.hasData && snapshot.data!.length > 1
                                  ? () => Navigator.push(
                                        context,
                                        MaterialPageRoute<TransferView>(
                                          builder: (context) => const TransferView(),
                                        ),
                                      )
                                  : null,
                              icon: const Icon(Icons.swap_horiz),
                              label: Text(AppLocalizations.of(context)!.transfer),
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
