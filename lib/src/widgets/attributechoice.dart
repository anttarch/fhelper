import 'package:fhelper/src/logic/collections/attribute.dart';
import 'package:flutter/material.dart';

class AttributeChoice extends StatelessWidget {
  AttributeChoice({
    super.key,
    required this.groupValue,
    required this.onChanged,
    required this.items,
    this.lazyEnoughToMakeAnotherWidgetIntList,
  }) : assert(
          (lazyEnoughToMakeAnotherWidgetIntList != null && items.isEmpty) || (lazyEnoughToMakeAnotherWidgetIntList == null && items.isNotEmpty),
          "I'm lazy, but that's too much",
        );
  final List<Attribute> items;
  final int groupValue;
  final void Function(int? value)? onChanged;
  final List<int>? lazyEnoughToMakeAnotherWidgetIntList;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height / 2.5 - 68),
      child: ListView.separated(
        itemCount: items.isNotEmpty ? items.length : lazyEnoughToMakeAnotherWidgetIntList!.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<int>(
                value: index,
                groupValue: groupValue,
                onChanged: onChanged,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                title: Text(
                  items.isNotEmpty ? items[index].name : lazyEnoughToMakeAnotherWidgetIntList![index].toString(),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                controlAffinity: ListTileControlAffinity.trailing,
              ),
              if (index == (items.isNotEmpty ? items.length : lazyEnoughToMakeAnotherWidgetIntList!.length) - 1)
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
      ),
    );
  }
}
