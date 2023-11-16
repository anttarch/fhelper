import 'package:animations/animations.dart';
import 'package:fhelper/src/logic/collections/attribute.dart';
import 'package:fhelper/src/logic/collections/card.dart' as fhelper;
import 'package:fhelper/src/logic/widgets/utils.dart' as wid_utils;
import 'package:flutter/material.dart';

class ListChoice extends StatefulWidget {
  const ListChoice({
    required this.groupValue,
    required this.onChanged,
    super.key,
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
        assert(
          !(intList == null && attributeMap == null && cardList == null),
          'Need data',
        );

  final Map<Attribute, List<Attribute>>? attributeMap;
  final bool attributeListBehavior;
  final List<fhelper.Card>? cardList;
  final (int, int)? hiddenIndex;
  final Object groupValue;
  final void Function(String? name, Object? value)? onChanged;
  // TODO(antarch): remove it
  final List<int>? intList;

  @override
  State<ListChoice> createState() => _ListChoiceState();
}

class _ListChoiceState extends State<ListChoice> {
  late Widget _selectedChild;
  late int _childIndex = 0;
  late Widget _attributeParent;

  @override
  void initState() {
    super.initState();
    if (widget.attributeMap != null) {
      final attributeList = widget.attributeMap!.keys.toList();

      _attributeParent = _AttributeParentListView(
        parentAttributes: attributeList,
        onParentTap: (parentIndex) {
          final childList = widget.attributeMap!.values.toList()[parentIndex];
          final childView = _AttributeChildListView(
            attributeListBehavior: false,
            childAttributes: childList,
            groupValue: widget.groupValue,
            parentName: attributeList[parentIndex].name,
            parentIndex: parentIndex,
            onChanged: widget.onChanged,
          );
          setState(() {
            _selectedChild = childView;
            _childIndex = 1;
          });
        },
      );

      if (widget.attributeListBehavior) {
        _selectedChild = _AttributeChildListView(
          childAttributes: attributeList,
          attributeListBehavior: true,
          groupValue: widget.groupValue,
          onChanged: widget.onChanged,
          parentIndex: -1,
          parentName: '',
        );
      } else {
        _selectedChild = _attributeParent;
      }
    } else {
      _selectedChild = _CardListView(
        cards: widget.cardList!,
        groupValue: widget.groupValue,
        onChanged: widget.onChanged,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _childIndex == 0,
      onPopInvoked: (didPop) {
        if (!didPop) {
          setState(() {
            _selectedChild = _attributeParent;
            _childIndex = 0;
          });
        }
      },
      child: PageTransitionSwitcher(
        transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
          return SharedAxisTransition(
            animation: primaryAnimation,
            secondaryAnimation: secondaryAnimation,
            transitionType: SharedAxisTransitionType.horizontal,
            fillColor: Colors.transparent,
            child: child,
          );
        },
        layoutBuilder: (entries) {
          return Stack(
            alignment: Alignment.topCenter,
            children: entries,
          );
        },
        child: _selectedChild,
      ),
    );
  }
}
// @override
// Widget build(BuildContext context) {
//   return SafeArea(
//     child: ListView.separated(
//       shrinkWrap: true,
//       padding: EdgeInsets.zero,
//       physics: const NeverScrollableScrollPhysics(),
//       itemCount: attributeMap != null && !attributeListBehavior
//           ? attributeMap!.length
//           : 1,
//       itemBuilder: (context, parentIndex) {
//         if (hiddenIndex != null && attributeMap != null) {
//           final parent = attributeMap!.keys.elementAt(hiddenIndex!.$1);
//           attributeMap!.update(parent, (value) {
//             if (value.isNotEmpty && value.length > hiddenIndex!.$2) {
//               value.removeAt(hiddenIndex!.$2);
//             }
//             return value;
//           });
//         }
//         return Padding(
//           padding: EdgeInsets.symmetric(
//             horizontal: 22,
//             vertical: attributeMap != null && !attributeListBehavior ? 15 : 5,
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               if (attributeMap != null && !attributeListBehavior)
//                 Text(
//                   attributeMap!.keys.toList()[parentIndex].name,
//                   style: Theme.of(context).textTheme.titleMedium,
//                 ),
//               Card(
//                 elevation: 0,
//                 margin: attributeMap != null &&
//                         attributeMap!.values.toList()[parentIndex].isEmpty
//                     ? null
//                     : const EdgeInsets.only(top: 10),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   side: BorderSide(
//                     color: Theme.of(context).colorScheme.outlineVariant,
//                   ),
//                 ),
//                 clipBehavior: Clip.antiAlias,
//                 child: ListView.separated(
//                   shrinkWrap: true,
//                   padding: EdgeInsets.zero,
//                   physics: const NeverScrollableScrollPhysics(),
//                   itemCount: attributeMap != null
//                       ? attributeListBehavior
//                           ? attributeMap!.keys.length
//                           : attributeMap!.values.toList()[parentIndex].length
//                       : cardList != null
//                           ? cardList!.length
//                           : intList!.length,
//                   itemBuilder: (context, childIndex) {
//                     return RadioListTile(
//                       value: attributeMap != null && !attributeListBehavior
//                           ? (parentIndex, childIndex)
//                           : childIndex,
//                       groupValue: groupValue,
//                       onChanged: (value) {
//                         if (attributeMap != null) {
//                           if (!attributeListBehavior) {
//                             final parentName = attributeMap!.keys
//                                 .elementAt(parentIndex)
//                                 .name;
//                             final childName = attributeMap!.values
//                                 .toList()[parentIndex][childIndex]
//                                 .name;
//                             final name = '$parentName - $childName';
//                             onChanged!(name, value);
//                           } else {
//                             onChanged!(
//                               attributeMap!.keys.toList()[childIndex].name,
//                               value,
//                             );
//                           }
//                         } else {
//                           onChanged!('', value);
//                         }
//                       },
//                       contentPadding: const EdgeInsets.symmetric(
//                         horizontal: 20,
//                       ),
//                       selected: attributeMap != null && !attributeListBehavior
//                           ? groupValue == (parentIndex, childIndex)
//                           : groupValue == childIndex,
//                       selectedTileColor:
//                           Theme.of(context).colorScheme.surfaceVariant,
//                       shape: wid_utils.getShapeBorder(
//                         childIndex,
//                         attributeMap != null
//                             ? attributeListBehavior
//                                 ? attributeMap!.keys.length - 1
//                                 : attributeMap!.values
//                                         .toList()[parentIndex]
//                                         .length -
//                                     1
//                             : cardList != null
//                                 ? cardList!.length - 1
//                                 : intList!.length - 1,
//                       ),
//                       title: Text(
//                         attributeMap != null
//                             ? attributeListBehavior
//                                 ? attributeMap!.keys.toList()[childIndex].name
//                                 : attributeMap!.values
//                                     .toList()[parentIndex][childIndex]
//                                     .name
//                             : cardList != null
//                                 ? cardList![childIndex].name
//                                 : intList![childIndex].toString(),
//                         style: Theme.of(context).textTheme.bodyLarge,
//                       ),
//                       controlAffinity: ListTileControlAffinity.trailing,
//                     );
//                   },
//                   separatorBuilder: (_, index) {
//                     if ((hiddenIndex != null || hiddenIndex != (-1, -1)) &&
//                         hiddenIndex == (parentIndex, index)) {
//                       return const SizedBox.shrink();
//                     }
//                     return Divider(
//                       height: 2,
//                       thickness: 1.5,
//                       color: Theme.of(context).colorScheme.outlineVariant,
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//       separatorBuilder: (_, __) => Divider(
//         height: 2,
//         thickness: 1.5,
//         color: Theme.of(context).colorScheme.outlineVariant,
//       ),
//     ),
//   );
// }
//}

class _AttributeParentListView extends StatelessWidget {
  const _AttributeParentListView({
    required this.parentAttributes,
    required this.onParentTap,
  });

  final List<Attribute> parentAttributes;
  final void Function(int index) onParentTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.separated(
        itemCount: parentAttributes.length,
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return ListTile(
            shape: wid_utils.getShapeBorder(index, parentAttributes.length - 1),
            title: Text(parentAttributes[index].name),
            trailing: Icon(
              Icons.arrow_right,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onTap: () => onParentTap(index),
          );
        },
        separatorBuilder: (_, __) => const Divider(
          height: 0,
        ),
      ),
    );
  }
}

class _AttributeChildListView extends StatelessWidget {
  const _AttributeChildListView({
    required this.attributeListBehavior,
    required this.childAttributes,
    required this.groupValue,
    required this.parentName,
    required this.parentIndex,
    required this.onChanged,
  });

  final bool attributeListBehavior;
  final List<Attribute> childAttributes;
  final Object groupValue;
  final String parentName;
  final int parentIndex;
  final void Function(String? name, Object? value)? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!attributeListBehavior)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const BackButton(),
                Text(
                  parentName,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),
        Card(
          elevation: 0,
          color: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(12)),
          ),
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: ListView.separated(
            itemCount: childAttributes.length,
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return RadioListTile(
                shape:
                    wid_utils.getShapeBorder(index, childAttributes.length - 1),
                title: Text(childAttributes[index].name),
                value: attributeListBehavior ? index : (parentIndex, index),
                groupValue: groupValue,
                onChanged: (childIndex) {
                  if (attributeListBehavior) {
                    onChanged!(childAttributes[index].name, childIndex);
                  } else {
                    final childName = childAttributes[index].name;
                    final name = '$parentName - $childName';
                    onChanged!(name, childIndex);
                  }
                },
                controlAffinity: ListTileControlAffinity.trailing,
              );
            },
            separatorBuilder: (_, __) => const Divider(
              height: 0,
            ),
          ),
        ),
      ],
    );
  }
}

class _CardListView extends StatelessWidget {
  const _CardListView({
    required this.cards,
    required this.groupValue,
    required this.onChanged,
  });

  final List<fhelper.Card> cards;
  final Object groupValue;
  final void Function(String? name, Object? value)? onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
      child: ListView.separated(
        itemCount: cards.length,
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return RadioListTile(
            shape: wid_utils.getShapeBorder(index, cards.length - 1),
            title: Text(cards[index].name),
            value: index,
            groupValue: groupValue,
            onChanged: (value) {
              onChanged!('', value);
            },
          );
        },
        separatorBuilder: (_, __) => const Divider(
          height: 0,
        ),
      ),
    );
  }
}
