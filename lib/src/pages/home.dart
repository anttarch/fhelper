import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: PreferredSize(
        preferredSize:
            Size(double.infinity, MediaQuery.of(context).size.height / 8),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                "Good Morning!",
                textAlign: TextAlign.start,
                style: Theme.of(context)
                    .textTheme
                    .displaySmall!
                    .apply(color: Theme.of(context).colorScheme.onBackground),
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Latest:",
                      textAlign: TextAlign.start,
                      style: Theme.of(context).textTheme.titleLarge!.apply(
                          color: Theme.of(context).colorScheme.onSurface),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Petrol Station",
                          textAlign: TextAlign.start,
                          style: Theme.of(context).textTheme.bodyLarge!.apply(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant),
                        ),
                        Text(
                          "-\$16.50",
                          textAlign: TextAlign.start,
                          style: Theme.of(context).textTheme.bodyLarge!.apply(
                                color: const Color(0xffbd1c1c),
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Card(
              color: Theme.of(context).colorScheme.surfaceVariant,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Latest:",
                      textAlign: TextAlign.start,
                      style: Theme.of(context).textTheme.titleLarge!.apply(
                          color: Theme.of(context).colorScheme.onSurface),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Petrol Station",
                          textAlign: TextAlign.start,
                          style: Theme.of(context).textTheme.bodyLarge!.apply(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant),
                        ),
                        Text(
                          "-\$16.50",
                          textAlign: TextAlign.start,
                          style: Theme.of(context).textTheme.bodyLarge!.apply(
                                color: const Color(0xffbd1c1c),
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
