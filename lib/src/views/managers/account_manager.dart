import 'package:fhelper/src/logic/collections/attribute.dart';
import 'package:fhelper/src/logic/widgets/show_attribute_dialog.dart';
import 'package:fhelper/src/logic/widgets/utils.dart' as wid_utils;
import 'package:fhelper/src/views/details/attribute_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:isar/isar.dart';

class AccountManager extends StatefulWidget {
  const AccountManager({super.key});

  @override
  State<AccountManager> createState() => _AccountManagerState();
}

class _AccountManagerState extends State<AccountManager> {
  final TextEditingController _controller = TextEditingController();
  List<Attribute> parents = [];
  (int parentIndex, int childIndex) selectedIndex = (-1, -1);

  Widget _selectedIndicator(int parentIndex, int childIndex) {
    return Radio(
      value: (parentIndex, childIndex),
      groupValue: selectedIndex,
      onChanged: (value) => setState(() {
        selectedIndex = (parentIndex, childIndex);
      }),
    );
  }

  SnackBar _undoSnackBar(
      int backupIndex, Attribute? backupAttribute, Isar isar) {
    final localization = AppLocalizations.of(context)!;

    return SnackBar(
      content: Text(
        localization.deletedSnackBar(backupAttribute!.name),
      ),
      action: SnackBarAction(
        label: localization.undo,
        onPressed: () async {
          await isar.writeTxn(() async {
            await isar.attributes.put(backupAttribute);
          }).then((_) {
            if (backupIndex == parents.length + 1) {
              parents.add(backupAttribute);
            } else if (backupIndex < parents.length + 1) {
              parents.insert(backupIndex, backupAttribute);
            }
          });
        },
      ),
      behavior: SnackBarBehavior.floating,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    return PopScope(
      canPop: selectedIndex.$2 == -1,
      onPopInvoked: (_) {
        if (selectedIndex.$2 > -1) {
          setState(() => selectedIndex = (-1, -1));
        }
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      },
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar.medium(
              title: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  selectedIndex.$2 > -1
                      ? localization.select
                      : localization.account(-1),
                ),
              ),
              actions: [
                if (selectedIndex.$2 > -1)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: IconButton(
                      onPressed: () => setState(() => selectedIndex = (-1, -1)),
                      icon: Icon(
                        Icons.deselect,
                        semanticLabel: selectedIndex.$2 > -1
                            ? localization.deselectIconButton
                            : null,
                      ),
                    ),
                  ),
              ],
            ),
            SliverToBoxAdapter(
              child: Material(
                child: StreamBuilder(
                  stream: Isar.getInstance()!.attributes.watchLazy(),
                  builder: (context, snapshot) {
                    return FutureBuilder(
                      future: getAttributes(
                        Isar.getInstance()!,
                        AttributeType.account,
                        context: context,
                      ).then((value) => value.keys.toList()),
                      builder: (context, snapshot) {
                        parents = snapshot.hasData ? snapshot.data! : [];
                        return Card(
                          elevation: 0,
                          color: Theme.of(context).colorScheme.surface,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              color:
                                  Theme.of(context).colorScheme.outlineVariant,
                            ),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(12)),
                          ),
                          margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                          child: ListView.separated(
                            itemCount: parents.length,
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              return ListTile(
                                shape: wid_utils.getShapeBorder(
                                  index,
                                  parents.length - 1,
                                ),
                                title: Text(parents[index].name),
                                trailing: Icon(
                                  Icons.arrow_right,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                                onTap: () async {
                                  final backupAttribute = await Navigator.push(
                                    context,
                                    MaterialPageRoute<Attribute>(
                                      builder: (context) =>
                                          AttributeDetailsView(
                                        attribute: parents[index],
                                      ),
                                    ),
                                  );
                                  if (backupAttribute != null &&
                                      context.mounted) {
                                    final backupIndex =
                                        parents.indexOf(backupAttribute);
                                    final isar = Isar.getInstance()!;
                                    parents.removeAt(backupIndex);
                                    await ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                          _undoSnackBar(
                                            backupIndex,
                                            backupAttribute,
                                            isar,
                                          ),
                                        )
                                        .closed
                                        .then((reason) async {
                                      switch (reason) {
                                        case SnackBarClosedReason.action:
                                          break;
                                        case SnackBarClosedReason.dismiss:
                                        case SnackBarClosedReason.hide:
                                        case SnackBarClosedReason.remove:
                                        case SnackBarClosedReason.swipe:
                                        case SnackBarClosedReason.timeout:
                                          await isar.writeTxn(() async {
                                            final childrenId =
                                                await isar.attributes
                                                    .filter()
                                                    .parentIdEqualTo(
                                                      backupAttribute.id,
                                                    )
                                                    .idProperty()
                                                    .findAll();
                                            await isar.attributes
                                                .deleteAll(childrenId);
                                          });
                                      }
                                    });
                                  }
                                },
                              );
                            },
                            separatorBuilder: (_, __) =>
                                const Divider(height: 0),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => showAttributeDialog<void>(
            context: context,
            attributeRole: AttributeRole.parent,
            attributeType: AttributeType.account,
            controller: _controller,
          ).then((_) {
            _controller.clear();
            setState(() => selectedIndex = (-1, -1));
          }),
          elevation: 0,
          child: const Icon(Icons.add),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
        bottomNavigationBar: BottomAppBar(
          child: Row(
            children: [
              IconButton(
                // TODO(antarch): implement search
                onPressed: () {},
                icon: const Icon(Icons.search),
              ),
              IconButton(
                // TODO(antarch): implement sort
                onPressed: () {},
                icon: const Icon(Icons.sort),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
