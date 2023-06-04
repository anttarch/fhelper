import 'package:fhelper/src/logic/collections/attribute.dart';
import 'package:fhelper/src/logic/collections/card.dart' as fhelper;
import 'package:fhelper/src/logic/widgets/utils.dart' as wid_utils;
import 'package:flutter/material.dart';

class ListChoice extends StatelessWidget {
  const ListChoice({
    super.key,
    required this.groupValue,
    required this.onChanged,
    this.attributeMap,
    this.attributeListBehavior = false,
    this.cardList,
    this.intList,
    this.hiddenIndex,
  })  : assert(
          (intList != null && attributeMap == null && cardList == null) ||
              (intList == null && attributeMap != null && cardList == null) ||
              (intList == null && attributeMap == null && cardList != null),
          'Use only one list at a time',
        ),
        assert(!(intList == null && attributeMap == null && cardList == null), 'Need data');

  final Map<Attribute, List<Attribute>>? attributeMap;
  final bool attributeListBehavior;
  final List<fhelper.Card>? cardList;
  final int? hiddenIndex;
  final Object groupValue;
  final void Function(String? name, Object? value)? onChanged;
  final List<int>? intList;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height / 2 - 68),
        child: ListView.separated(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: attributeMap != null && !attributeListBehavior ? attributeMap!.length : 1,
          itemBuilder: (context, parentIndex) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 22, vertical: attributeMap != null && !attributeListBehavior ? 15 : 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (attributeMap != null && !attributeListBehavior)
                    Text(
                      attributeMap!.keys.toList()[parentIndex].name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  Card(
                    elevation: 0,
                    margin: attributeMap != null && attributeMap!.values.toList()[parentIndex].isEmpty ? null : const EdgeInsets.only(top: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: attributeMap != null
                          ? attributeListBehavior
                              ? attributeMap!.keys.length
                              : attributeMap!.values.toList()[parentIndex].length
                          : cardList != null
                              ? cardList!.length
                              : intList!.length,
                      itemBuilder: (context, childIndex) {
                        if ((hiddenIndex != null || hiddenIndex != -1) && hiddenIndex == childIndex) {
                          return const SizedBox.shrink();
                        }
                        return RadioListTile(
                          value: attributeMap != null && !attributeListBehavior ? (parentIndex, childIndex) : childIndex,
                          groupValue: groupValue,
                          onChanged: (value) {
                            if (attributeMap != null) {
                              if (!attributeListBehavior) {
                                final name =
                                    '${attributeMap!.keys.elementAt(parentIndex).name} - ${attributeMap!.values.toList()[parentIndex][childIndex].name}';
                                onChanged!(name, value);
                              } else {
                                onChanged!(attributeMap!.keys.toList()[childIndex].name, value);
                              }
                            } else {
                              onChanged!('', value);
                            }
                          },
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                          ),
                          selected: attributeMap != null && !attributeListBehavior ? groupValue == (parentIndex, childIndex) : groupValue == childIndex,
                          selectedTileColor: Theme.of(context).colorScheme.surfaceVariant,
                          shape: wid_utils.getShapeBorder(
                            childIndex,
                            attributeMap != null
                                ? attributeListBehavior
                                    ? attributeMap!.keys.length - 1
                                    : attributeMap!.values.toList()[parentIndex].length - 1
                                : cardList != null
                                    ? cardList!.length - 1
                                    : intList!.length - 1,
                          ),
                          title: Text(
                            attributeMap != null
                                ? attributeListBehavior
                                    ? attributeMap!.keys.toList()[childIndex].name
                                    : attributeMap!.values.toList()[parentIndex][childIndex].name
                                : cardList != null
                                    ? cardList![childIndex].name
                                    : intList![childIndex].toString(),
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          controlAffinity: ListTileControlAffinity.trailing,
                        );
                      },
                      separatorBuilder: (_, index) {
                        if ((hiddenIndex != null || hiddenIndex != -1) && hiddenIndex == index) {
                          return const SizedBox.shrink();
                        }
                        return Divider(
                          height: 2,
                          thickness: 1.5,
                          color: Theme.of(context).colorScheme.outlineVariant,
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
          separatorBuilder: (_, __) => Divider(
            height: 2,
            thickness: 1.5,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
      ),
    );
  }
}
