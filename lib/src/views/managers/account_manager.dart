import 'package:fhelper/src/logic/collections/attribute.dart';
import 'package:fhelper/src/logic/collections/exchange.dart';
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
  Map<Attribute, List<Attribute>> attributes = {};
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

  Widget _accounts(int parentIndex) {
    final localization = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: () async {
                  if (_controller.text.isEmpty) {
                    _controller.text =
                        attributes.keys.elementAt(parentIndex).name;
                  }
                  await showAttributeDialog<void>(
                    context: context,
                    attribute: attributes.keys.elementAt(parentIndex),
                    controller: _controller,
                    editMode: true,
                  ).then((_) {
                    _controller.clear();
                  });
                },
                icon: const Icon(Icons.edit),
                label: Text(
                  attributes.keys.toList()[parentIndex].name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Row(
                children: [
                  IconButton.filledTonal(
                    onPressed: () => showAttributeDialog<void>(
                      context: context,
                      controller: _controller,
                      attributeRole: AttributeRole.child,
                      attributeType: AttributeType.account,
                      parentId: attributes.keys.elementAt(parentIndex).id,
                    ).then((_) {
                      _controller.clear();
                    }),
                    icon: const Icon(Icons.add),
                  ),
                  IconButton.filledTonal(
                    onPressed: () async {
                      await showDialog<void>(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            icon: const Icon(Icons.delete_forever),
                            title: Text(
                              localization.deletePermanentlyQuestion,
                            ),
                            content: Text(
                              localization.deleteContentDescription(1),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(localization.cancel),
                              ),
                              FilledButton.tonal(
                                onPressed: () async {
                                  final isar = Isar.getInstance()!;
                                  await isar.writeTxn(() async {
                                    final entry =
                                        attributes.entries.singleWhere(
                                      (element) =>
                                          element.key ==
                                          attributes.keys
                                              .elementAt(parentIndex),
                                    );
                                    final idList = <int>[entry.key.id];
                                    for (final element in entry.value) {
                                      idList.add(element.id);
                                    }
                                    await isar.attributes.deleteAll(idList);
                                  }).then((_) {
                                    Navigator.pop(context);
                                  });
                                },
                                child: Text(localization.delete),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    icon: const Icon(Icons.delete_forever),
                  ),
                ],
              ),
            ],
          ),
          Card(
            elevation: 0,
            margin: EdgeInsets.only(
              top: attributes.values.toList()[parentIndex].isEmpty ? 0 : 10,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: attributes.values.toList()[parentIndex].length,
              itemBuilder: (context, childIndex) {
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  shape: wid_utils.getShapeBorder(
                    childIndex,
                    attributes.values.toList()[parentIndex].length - 1,
                  ),
                  tileColor: selectedIndex == (parentIndex, childIndex)
                      ? Theme.of(context).colorScheme.surfaceVariant
                      : null,
                  title: Text(
                    attributes.values.toList()[parentIndex][childIndex].name,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  trailing: selectedIndex.$2 == -1
                      ? Icon(
                          Icons.arrow_right,
                          color: Theme.of(context).colorScheme.onSurface,
                        )
                      : _selectedIndicator(parentIndex, childIndex),
                  onTap: () {
                    if (selectedIndex.$2 > -1) {
                      if (selectedIndex != (parentIndex, childIndex)) {
                        setState(() {
                          selectedIndex = (parentIndex, childIndex);
                        });
                      }
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute<AttributeDetailsView>(
                          builder: (context) => AttributeDetailsView(
                            attribute: attributes.values.toList()[parentIndex]
                                [childIndex],
                          ),
                        ),
                      );
                    }
                  },
                  onLongPress: () {
                    setState(() {
                      selectedIndex = (parentIndex, childIndex);
                    });
                  },
                );
              },
              separatorBuilder: (_, __) => Divider(
                height: 2,
                thickness: 1.5,
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  SnackBar _undoSnackBar((int, int) backupIndex, Attribute? backup, Isar isar) {
    final localization = AppLocalizations.of(context)!;

    return SnackBar(
      content: Text(
        localization.deletedSnackBar(backup!.name),
      ),
      action: SnackBarAction(
        label: localization.undo,
        onPressed: () async {
          await isar.writeTxn(() async {
            await isar.attributes.put(backup);
          }).then((_) {
            if (backup.role == AttributeRole.child) {
              final list = attributes.values.toList()[backupIndex.$1];
              if (!list.contains(backup)) {
                if (list.length + 1 == backupIndex.$2) {
                  attributes.values.toList()[backupIndex.$1].add(backup);
                } else if (backupIndex.$2 < list.length + 1) {
                  attributes.values
                      .toList()[backupIndex.$1]
                      .insert(backupIndex.$2, backup);
                }
              }
            }
            setState(
              () => selectedIndex = backupIndex,
            );
          });
        },
      ),
      behavior: SnackBarBehavior.floating,
    );
  }

  Widget _dependencyDialog(int value, Isar isar) {
    final localization = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(localization.proceedQuestion),
      icon: const Icon(Icons.warning),
      content: Text(localization.dependencyPhrase(value)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(localization.cancel),
        ),
        FilledButton.tonal(
          onPressed: () async {
            final backupIndex = selectedIndex;
            final backup = await getAttributeFromId(
              isar,
              attributes.values.toList()[selectedIndex.$1][selectedIndex.$2].id,
              context: context,
            );
            await isar.writeTxn(() async {
              await isar.attributes.delete(
                attributes.values
                    .toList()[selectedIndex.$1][selectedIndex.$2]
                    .id,
              );
            }).then((_) {
              setState(() => selectedIndex = (-1, -1));
              Navigator.pop(context);
            });
            if (mounted) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(_undoSnackBar(backupIndex, backup, isar));
            }
          },
          child: Text(localization.proceed),
        ),
      ],
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
                      ),
                      builder: (context, snapshot) {
                        attributes = snapshot.hasData ? snapshot.data! : {};
                        // return ListView.separated(
                        //   shrinkWrap: true,
                        //   physics: const NeverScrollableScrollPhysics(),
                        //   padding: EdgeInsets.zero,
                        //   itemCount: attributes.length,
                        //   itemBuilder: (context, parentIndex) =>
                        //       _accounts(parentIndex),
                        //   separatorBuilder: (_, __) => Divider(
                        //     height: 2,
                        //     thickness: 1.5,
                        //     color: Theme.of(context).colorScheme.outlineVariant,
                        //   ),
                        // );
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
                            itemCount: attributes.length,
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              return ListTile(
                                shape: wid_utils.getShapeBorder(
                                  index,
                                  attributes.length - 1,
                                ),
                                title:
                                    Text(attributes.keys.toList()[index].name),
                                trailing: Icon(
                                  Icons.arrow_right,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute<AttributeDetailsView>(
                                    builder: (context) => AttributeDetailsView(
                                      attribute:
                                          attributes.keys.toList()[index],
                                    ),
                                  ),
                                ),
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
              // IconButton(
              //   onPressed: () => Navigator.push(
              //     context,
              //     MaterialPageRoute<AttributeDetailsView>(
              //       builder: (context) => AttributeDetailsView(
              //         attribute: attributes.values.toList()[selectedIndex.$1]
              //             [selectedIndex.$2],
              //       ),
              //     ),
              //   ),
              //   icon: Icon(
              //     Icons.info,
              //     semanticLabel: selectedIndex.$2 > -1
              //         ? localization.infoIconButton(
              //             attributes.values
              //                 .toList()[selectedIndex.$1][selectedIndex.$2]
              //                 .name,
              //           )
              //         : null,
              //   ),
              // ),
              // IconButton(
              //   onPressed: () async {
              //     await checkForAttributeDependencies(
              //       Isar.getInstance()!,
              //       attributes.values
              //           .toList()[selectedIndex.$1][selectedIndex.$2]
              //           .id,
              //       AttributeType.account,
              //     ).then(
              //       (value) async {
              //         final isar = Isar.getInstance()!;
              //         if (value > 0) {
              //           await showDialog<void>(
              //             context: context,
              //             builder: (context) => _dependencyDialog(value, isar),
              //           );
              //         } else {
              //           final backupIndex = selectedIndex;
              //           final backup = await getAttributeFromId(
              //             isar,
              //             attributes.values
              //                 .toList()[selectedIndex.$1][selectedIndex.$2]
              //                 .id,
              //             context: context,
              //           );
              //           await isar.writeTxn(() async {
              //             await isar.attributes.delete(
              //               attributes.values
              //                   .toList()[selectedIndex.$1][selectedIndex.$2]
              //                   .id,
              //             );
              //           }).then(
              //             (_) => setState(() => selectedIndex = (-1, -1)),
              //           );
              //           if (mounted) {
              //             ScaffoldMessenger.of(context).showSnackBar(
              //               _undoSnackBar(backupIndex, backup, isar),
              //             );
              //           }
              //         }
              //       },
              //     );
              //   },
              //   icon: Icon(
              //     Icons.delete,
              //     semanticLabel: selectedIndex.$2 > -1
              //         ? localization.deleteIconButton(
              //             attributes.values
              //                 .toList()[selectedIndex.$1][selectedIndex.$2]
              //                 .name,
              //           )
              //         : null,
              //   ),
              // ),
              // IconButton(
              //   onPressed: () async {
              //     if (_controller.text.isEmpty) {
              //       _controller.text = attributes.values
              //           .toList()[selectedIndex.$1][selectedIndex.$2]
              //           .name;
              //     }
              //     await showAttributeDialog<void>(
              //       context: context,
              //       attribute: attributes.values.toList()[selectedIndex.$1]
              //           [selectedIndex.$2],
              //       controller: _controller,
              //       editMode: true,
              //     ).then((_) {
              //       _controller.clear();
              //       setState(() => selectedIndex = (-1, -1));
              //     });
              //   },
              //   icon: Icon(
              //     Icons.edit,
              //     semanticLabel: selectedIndex.$2 > -1
              //         ? localization.editIconButton(
              //             attributes.values
              //                 .toList()[selectedIndex.$1][selectedIndex.$2]
              //                 .name,
              //           )
              //         : null,
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
