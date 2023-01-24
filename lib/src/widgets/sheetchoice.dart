import 'package:flutter/material.dart';

class SheetChoice<T> extends StatelessWidget {
  const SheetChoice({
    super.key,
    required this.groupValue,
    required this.onChanged,
    required this.items,
  });
  final Map<String, T> items;
  final T groupValue;
  final void Function(T? value)? onChanged;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: items.length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return Column(
          children: [
            RadioListTile<T>(
              value: items.values.elementAt(index),
              groupValue: groupValue,
              onChanged: onChanged,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              title: Text(
                items.keys.elementAt(index),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              controlAffinity: ListTileControlAffinity.trailing,
            ),
            if (index == items.length - 1)
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
