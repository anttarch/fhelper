import 'package:fhelper/src/logic/widgets/utils.dart' as wid_utils;
import 'package:fhelper/src/views/managers/account_manager.dart';
import 'package:fhelper/src/views/managers/card_manager.dart';
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
      () => Navigator.push(
            context,
            MaterialPageRoute<AccountManager>(
              builder: (context) => const AccountManager(),
            ),
          ),
      // Cards
      () => Navigator.push(
            context,
            MaterialPageRoute<CardManager>(
              builder: (context) => const CardManager(),
            ),
          ),
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
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 22),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: elements.length,
        itemBuilder: (context, index) {
          return Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                shape: wid_utils.getShapeBorder(index, elements.length - 1),
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
            ],
          );
        },
        separatorBuilder: (_, __) => Divider(
          height: 2,
          thickness: 1.5,
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
    );
  }
}
