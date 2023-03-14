import 'package:dynamic_color/dynamic_color.dart';
import 'package:fhelper/src/logic/collections/exchange.dart';
import 'package:fhelper/src/views/add/add.dart';
import 'package:fhelper/src/views/details/details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: StreamBuilder(
        stream: Isar.getInstance()!.exchanges.watchLazy(),
        builder: (context, snapshot) {
          final exchange = Isar.getInstance()!.exchanges.where().sortByDateDesc().findFirstSync();
          return Column(
            children: [
              Visibility(
                visible: exchange != null,
                child: Card(
                  color: Theme.of(context).colorScheme.surface,
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
                                exchange != null ? exchange.description : 'Placeholder',
                                textAlign: TextAlign.start,
                                style: Theme.of(context).textTheme.bodyLarge!.apply(
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                              Text(
                                NumberFormat.simpleCurrency(
                                  locale: Localizations.localeOf(context).languageCode,
                                ).format(
                                  exchange != null ? exchange.value : 0,
                                ),
                                textAlign: TextAlign.start,
                                style: Theme.of(context).textTheme.bodyLarge!.apply(
                                      color: Color(
                                        exchange != null
                                            ? exchange.value.isNegative
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
                            MaterialPageRoute<DetailsView>(
                              builder: (context) => DetailsView(
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
              FutureBuilder(
                future: getSumValue(Isar.getInstance()!, context),
                builder: (context, snapshot) {
                  return Card(
                    color: Theme.of(context).colorScheme.surfaceVariant,
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
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                              ),
                              if (snapshot.hasData)
                                Text(
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
                                )
                              else if (snapshot.connectionState == ConnectionState.active || snapshot.connectionState == ConnectionState.waiting)
                                const CircularProgressIndicator()
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
              )
            ],
          );
        },
      ),
    );
  }
}
