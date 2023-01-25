import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> elements = [
      'Accounts',
      'Cards',
      'Theme',
      'Types',
      'Privacy',
      'Security',
    ];
    final List<VoidCallback> callbacks = [
      // Accounts
      () {},
      // Cards
      () {},
      // Theme
      () {},
      // Types
      () {},
      // Privacy
      () {},
      // Security
      () {},
    ];
    return ListView.separated(
      itemCount: elements.length,
      itemBuilder: (context, index) {
        return Column(
          children: [
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              title: Text(
                elements[index],
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              trailing: Icon(
                Icons.arrow_right,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              onTap: callbacks[index],
            ),
            if (index == elements.length - 1)
              Divider(
                height: 1,
                thickness: 1,
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
          ],
        );
      },
      separatorBuilder: (_, __) => Divider(
        height: 1,
        thickness: 1,
        color: Theme.of(context).colorScheme.outlineVariant,
      ),
    );
  }
}
