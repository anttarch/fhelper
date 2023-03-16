import 'package:fhelper/src/logic/collections/attribute.dart';
import 'package:fhelper/src/logic/collections/card.dart' as fhelper;
import 'package:flutter/material.dart';

class ListChoice extends StatelessWidget {
  const ListChoice({
    super.key,
    required this.groupValue,
    required this.onChanged,
    this.attributeList,
    this.cardList,
    this.intList,
  })  : assert(
          (intList != null && attributeList == null && cardList == null) ||
              (intList == null && attributeList != null && cardList == null) ||
              (intList == null && attributeList == null && cardList != null),
          'Use only one list at a time',
        ),
        assert(!(intList == null && attributeList == null && cardList == null), 'Need a list');

  final List<Attribute>? attributeList;
  final List<fhelper.Card>? cardList;
  final int groupValue;
  final void Function(int? value)? onChanged;
  final List<int>? intList;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height / 2.5 - 68),
      child: ListView.separated(
        itemCount: attributeList != null
            ? attributeList!.length
            : cardList != null
                ? cardList!.length
                : intList!.length,
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
                  attributeList != null
                      ? attributeList![index].name
                      : cardList != null
                          ? cardList![index].name
                          : intList![index].toString(),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                controlAffinity: ListTileControlAffinity.trailing,
              ),
              if (index ==
                  (attributeList != null
                          ? attributeList!.length
                          : cardList != null
                              ? cardList!.length
                              : intList!.length) -
                      1)
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
