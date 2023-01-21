import 'package:flutter/material.dart';

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
                                color: const Color(0xffbd1c1c),
                              ),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () {},
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
                        r'-$55.04',
                        textAlign: TextAlign.start,
                        style: Theme.of(context).textTheme.titleLarge!.apply(
                              color: const Color(0xff199225),
                            ),
                      ),
                    ],
                  ),
                  // TODO: Filled Buttons don't exist yet
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ).copyWith(elevation: ButtonStyleButton.allOrNull(0)),
                    onPressed: () {},
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
