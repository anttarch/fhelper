import 'package:fhelper/src/logic/collections/attribute.dart';
import 'package:flutter/material.dart';

class AttributeChoice extends StatelessWidget {
  const AttributeChoice({
    super.key,
    required this.groupValue,
    required this.onChanged,
    required this.items,
  });
  final List<Attribute> items;
  final int groupValue;
  final void Function(int? value)? onChanged;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: items.length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return Column(
          children: [
            RadioListTile<int>(
              value: index,
              groupValue: groupValue,
              onChanged: onChanged,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              title: Text(
                items[index].name,
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
