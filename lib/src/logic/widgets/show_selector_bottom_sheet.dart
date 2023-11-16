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
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) {
      return DraggableScrollableSheet(
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        snap: true,
        builder: (context, scrollController) {
          return CustomScrollView(
            controller: scrollController,
            slivers: [
              // TODO(antarch): integrate search
              SliverPersistentHeader(
                pinned: true,
                delegate: _PersistentSearchBar(
                  height: 76,
                  searchBar: const Padding(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 20),
                    child: SearchBar(
                      // TODO(antarch): l10n and commonize
                      hintText: 'Search accounts',
                      leading: Icon(Icons.search),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: ListChoice(
                  groupValue: groupValue,
                  onChanged: onSelect,
                  attributeMap: attributeMap,
                  attributeListBehavior: attributeListBehavior,
                  intList: intList,
                  cardList: cardList,
                  hiddenIndex: hiddenIndex,
                ),
              ),
            ],
          );
        },
      );
    },
  );
}

class _PersistentSearchBar extends SliverPersistentHeaderDelegate {
  _PersistentSearchBar({
    required this.searchBar,
    required this.height,
  });

  final Widget searchBar;
  final double height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return searchBar;
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
