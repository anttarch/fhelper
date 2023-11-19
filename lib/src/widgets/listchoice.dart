import 'package:animations/animations.dart';
import 'package:fhelper/src/logic/collections/attribute.dart';
import 'package:fhelper/src/logic/collections/card.dart' as fhelper;
import 'package:fhelper/src/logic/widgets/utils.dart' as wid_utils;
import 'package:flutter/material.dart';

class ListChoice extends StatefulWidget {
  const ListChoice({
    required this.groupValue,
    required this.onChanged,
    this.actionLabel = '',
    this.onActionTap,
    this.title,
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
  final VoidCallback? onActionTap;
  final String actionLabel;
  final String? title;

  @override
  State<ListChoice> createState() => _ListChoiceState();
}

class _ListChoiceState extends State<ListChoice> {
  late Widget _selectedChild;
  late int _childIndex = 0;
  late Widget _attributeParent;
  late Attribute _parentAttribute;

  @override
  void initState() {
    super.initState();
    if (widget.attributeMap != null) {
      final attributeMap = widget.attributeMap!;
      if (widget.hiddenIndex != null) {
        final parent = attributeMap.keys.elementAt(widget.hiddenIndex!.$1);
        attributeMap.update(parent, (value) {
          if (value.isNotEmpty && value.length > widget.hiddenIndex!.$2) {
            value.removeAt(widget.hiddenIndex!.$2);
          }
          return value;
        });
      }

      final parentList = attributeMap.keys.toList();

      _attributeParent = _AttributeParentListView(
        parentAttributes: parentList,
        onParentTap: (parentIndex) {
          final childList = attributeMap.values.toList()[parentIndex];
          final childView = _AttributeChildListView(
            attributeListBehavior: false,
            childAttributes: childList,
            groupValue: widget.groupValue,
            parentName: parentList[parentIndex].name,
            parentIndex: parentIndex,
            onChanged: widget.onChanged,
          );
          setState(() {
            _selectedChild = childView;
            _childIndex = 1;
            _parentAttribute = parentList[parentIndex];
          });
        },
      );

      if (widget.attributeListBehavior) {
        _selectedChild = _AttributeChildListView(
          childAttributes: parentList,
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

  String _getTitle() {
    if (_childIndex == 0 || widget.attributeListBehavior) {
      return widget.title ?? '';
    }
    return _parentAttribute.name;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_childIndex == 1) const BackButton(),
                  Text(
                    _getTitle(),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
              FilledButton.tonalIcon(
                onPressed: widget.onActionTap,
                icon: const Icon(Icons.add),
                label: Text(widget.actionLabel),
              ),
            ],
          ),
        ),
        PopScope(
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
        ),
      ],
    );
  }
}

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
        separatorBuilder: (_, __) => const Divider(height: 0),
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
        Card(
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
            separatorBuilder: (_, __) => const Divider(height: 0),
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
            onChanged: (value) => onChanged!('', value),
          );
        },
        separatorBuilder: (_, __) => const Divider(height: 0),
      ),
    );
  }
}
