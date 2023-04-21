import 'package:fhelper/src/logic/collections/attribute.dart';
import 'package:fhelper/src/logic/collections/card.dart' as fhelper;
import 'package:fhelper/src/logic/widgets/utils.dart' as wid_utils;
import 'package:flutter/material.dart';

class ListChoice extends StatelessWidget {
  const ListChoice({
    super.key,
    required this.groupValue,
    required this.onChanged,
    this.attributeList,
    this.cardList,
    this.intList,
    this.hiddenIndex,
  })  : assert(
          (intList != null && attributeList == null && cardList == null) ||
              (intList == null && attributeList != null && cardList == null) ||
              (intList == null && attributeList == null && cardList != null),
          'Use only one list at a time',
        ),
        assert(!(intList == null && attributeList == null && cardList == null), 'Need a list');

  final List<Attribute>? attributeList;
  final List<fhelper.Card>? cardList;
  final int? hiddenIndex;
  final int groupValue;
  final void Function(int? value)? onChanged;
  final List<int>? intList;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height / 2 - 68),
        child: Card(
          elevation: 0,
          margin: const EdgeInsets.fromLTRB(22, 15, 22, 0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: ListView.separated(
            itemCount: attributeList != null
                ? attributeList!.length
                : cardList != null
                    ? cardList!.length
                    : intList!.length,
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) {
              if ((hiddenIndex != null || hiddenIndex != -1) && hiddenIndex == index) {
                return const SizedBox.shrink();
              }
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
                    shape: wid_utils.getShapeBorder(
                      index,
                      attributeList != null
                          ? attributeList!.length - 1
                          : cardList != null
                              ? cardList!.length - 1
                              : intList!.length - 1,
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
                ],
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
      ),
    );
  }
}
