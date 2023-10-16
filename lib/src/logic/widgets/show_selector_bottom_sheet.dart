import 'package:fhelper/src/logic/collections/attribute.dart';
import 'package:fhelper/src/logic/collections/card.dart' as fhelper;
import 'package:fhelper/src/widgets/listchoice.dart';
import 'package:flutter/material.dart';

Future<T?> showSelectorBottomSheet<T>({
  required BuildContext context,
  required Object groupValue,
  required String title,
  required void Function(String?, Object?)? onSelect,
  (int, int)? hiddenIndex,
  Widget? action,
  Map<Attribute, List<Attribute>>? attributeMap,
  bool attributeListBehavior = false,
  List<int>? intList,
  List<fhelper.Card>? cardList,
}) {
  return showModalBottomSheet<T>(
    context: context,
    enableDrag: false,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    action ?? const SizedBox.shrink(),
                  ],
                ),
              ),
              ListChoice(
                groupValue: groupValue,
                onChanged: onSelect,
                attributeMap: attributeMap,
                attributeListBehavior: attributeListBehavior,
                intList: intList,
                cardList: cardList,
                hiddenIndex: hiddenIndex,
              ),
            ],
          );
        },
      );
    },
  );
}
