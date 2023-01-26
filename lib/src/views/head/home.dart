import 'package:dynamic_color/dynamic_color.dart';
import 'package:fhelper/src/logic/collections/exchange.dart';
import 'package:fhelper/src/views/add/add.dart';
import 'package:fhelper/src/views/details/details.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Card(
            color: Theme.of(context).colorScheme.surface,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Latest:',
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
                          'Petrol Station',
                          textAlign: TextAlign.start,
                          style: Theme.of(context).textTheme.bodyLarge!.apply(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                        ),
                        Text(
                          r'-$16.50',
                          textAlign: TextAlign.start,
                          style: Theme.of(context).textTheme.bodyLarge!.apply(
                                color: const Color(0xffbd1c1c).harmonizeWith(
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
                          item: Isar.getInstance()!
                              .exchanges
                              .where()
                              .sortByDateDesc()
                              .findFirstSync()!,
                        ),
                      ),
                    ),
                    child: const Text('Details'),
                  )
                ],
              ),
            ),
          ),
          Card(
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
                        'Today',
                        textAlign: TextAlign.start,
                        style: Theme.of(context).textTheme.titleLarge!.apply(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                      Text(
                        r'+$55.04',
                        textAlign: TextAlign.start,
                        style: Theme.of(context).textTheme.titleLarge!.apply(
                              color: const Color(0xff199225).harmonizeWith(
                                Theme.of(context).colorScheme.primary,
                              ),
                            ),
                      ),
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
                    label: const Text('Add'),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
