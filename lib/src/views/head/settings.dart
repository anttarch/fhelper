import 'package:fhelper/src/views/managers/type_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> elements = [
      AppLocalizations.of(context)!.account(-1),
      AppLocalizations.of(context)!.card(-1),
      AppLocalizations.of(context)!.theme,
      AppLocalizations.of(context)!.type(-1),
      AppLocalizations.of(context)!.privacy,
      AppLocalizations.of(context)!.security,
    ];
    final List<VoidCallback> callbacks = [
      // Accounts
      () {},
      // Cards
      () {},
      // Theme
      () {},
      // Types
      () => Navigator.push(
            context,
            MaterialPageRoute<TypeManager>(
              builder: (context) => const TypeManager(),
            ),
          ),
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
