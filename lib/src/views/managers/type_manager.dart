import 'package:fhelper/src/logic/collections/attribute.dart';
import 'package:fhelper/src/logic/collections/exchange.dart';
import 'package:fhelper/src/logic/widgets/show_attribute_dialog.dart';
import 'package:fhelper/src/logic/widgets/utils.dart' as wid_utils;
import 'package:fhelper/src/views/details/attribute_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:isar/isar.dart';

class TypeManager extends StatefulWidget {
  const TypeManager({super.key});

  @override
  State<TypeManager> createState() => _TypeManagerState();
}

class _TypeManagerState extends State<TypeManager> {
  final TextEditingController _controller = TextEditingController();
  Set<AttributeType> _attributeType = {AttributeType.incomeType};
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (selectedIndex.$2 > -1) {
          setState(() => selectedIndex = (-1, -1));
          return Future<bool>.value(false);
        }
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        return Future<bool>.value(true);
      },
      child: Scaffold(
        body: GestureDetector(
          onHorizontalDragUpdate: (details) {
            if (details.delta.dx < 0 && _attributeType != {AttributeType.expenseType}) {
              setState(() {
                _attributeType = {AttributeType.expenseType};
              });
            } else if (details.delta.dx > 0 && _attributeType != {AttributeType.incomeType}) {
              setState(() {
                _attributeType = {AttributeType.incomeType};
              });
            }
          },
          child: CustomScrollView(
            slivers: [
              SliverAppBar.medium(
                title: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    selectedIndex.$2 > -1 ? AppLocalizations.of(context)!.select : AppLocalizations.of(context)!.type(-1),
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
                          semanticLabel: selectedIndex.$2 > -1 ? AppLocalizations.of(context)!.deselectIconButton : null,
                        ),
                      ),
                    )
                ],
              ),
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  color: Theme.of(context).colorScheme.background,
                  child: SegmentedButton(
                    segments: [
                      ButtonSegment(
                        value: AttributeType.incomeType,
                        label: Text(AppLocalizations.of(context)!.income),
                      ),
                      ButtonSegment(
                        value: AttributeType.expenseType,
                        label: Text(AppLocalizations.of(context)!.expense),
                      ),
                    ],
                    selected: _attributeType,
                    onSelectionChanged: (p0) {
                      setState(() {
                        _attributeType = p0;
                        selectedIndex = (-1, -1);
                      });
                    },
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Material(
                  child: StreamBuilder(
                    stream: Isar.getInstance()!.attributes.watchLazy(),
                    builder: (context, snapshot) {
                      return FutureBuilder(
                        future: getAttributes(
                          Isar.getInstance()!,
                          _attributeType.single,
                          context: context,
                        ),
                        builder: (context, snapshot) {
                          attributes = snapshot.hasData ? snapshot.data! : {};
                          return ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            itemCount: attributes.length,
                            itemBuilder: (context, parentIndex) {
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
                                              _controller.text = attributes.keys.elementAt(parentIndex).name;
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
                                                attributeType: _attributeType.single,
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
                                                      title: Text(AppLocalizations.of(context)!.deletePermanentlyQuestion),
                                                      content: Text(AppLocalizations.of(context)!.deleteContentDescription(1)),
                                                      actions: [
                                                        TextButton(onPressed: () => Navigator.pop(context), child: Text(AppLocalizations.of(context)!.cancel)),
                                                        FilledButton.tonal(
                                                          onPressed: () async {
                                                            final isar = Isar.getInstance()!;
                                                            await isar.writeTxn(() async {
                                                              final entry = attributes.entries
                                                                  .singleWhere((element) => element.key == attributes.keys.elementAt(parentIndex));
                                                              final List<int> idList = [entry.key.id];
                                                              for (final element in entry.value) {
                                                                idList.add(element.id);
                                                              }
                                                              await isar.attributes.deleteAll(idList);
                                                            }).then((_) {
                                                              Navigator.pop(context);
                                                            });
                                                          },
                                                          child: Text(AppLocalizations.of(context)!.delete),
                                                        )
                                                      ],
                                                    );
                                                  },
                                                );
                                              },
                                              icon: const Icon(Icons.delete_forever),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                    Card(
                                      elevation: 0,
                                      margin: EdgeInsets.only(top: attributes.values.toList()[parentIndex].isEmpty ? 0 : 10),
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
                                            shape: wid_utils.getShapeBorder(childIndex, attributes.values.toList()[parentIndex].length - 1),
                                            tileColor: selectedIndex == (parentIndex, childIndex) ? Theme.of(context).colorScheme.surfaceVariant : null,
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
                                                      attribute: attributes.values.toList()[parentIndex][childIndex],
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
                            },
                            separatorBuilder: (_, __) => Divider(
                              height: 2,
                              thickness: 1.5,
                              color: Theme.of(context).colorScheme.outlineVariant,
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
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => showAttributeDialog<void>(
            context: context,
            attributeRole: AttributeRole.child,
            attributeType: _attributeType.single,
            controller: _controller,
          ).then((_) {
            _controller.clear();
            setState(() => selectedIndex = (-1, -1));
          }),
          label: Text(
            AppLocalizations.of(context)!.type(1),
            semanticsLabel: AppLocalizations.of(context)!.addTypeFAB,
          ),
          icon: const Icon(Icons.add),
          elevation: selectedIndex.$2 > -1 ? 0 : null,
        ),
        floatingActionButtonLocation: selectedIndex.$2 > -1 ? FloatingActionButtonLocation.endContained : null,
        bottomNavigationBar: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: selectedIndex.$2 > -1 ? 80 + MediaQuery.paddingOf(context).bottom : 0,
          child: BottomAppBar(
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute<AttributeDetailsView>(
                      builder: (context) => AttributeDetailsView(
                        attribute: attributes.values.toList()[selectedIndex.$1][selectedIndex.$2],
                      ),
                    ),
                  ),
                  icon: Icon(
                    Icons.info,
                    semanticLabel: selectedIndex.$2 > -1
                        ? AppLocalizations.of(context)!.infoIconButton(attributes.values.toList()[selectedIndex.$1][selectedIndex.$2].name)
                        : null,
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    await checkForAttributeDependencies(
                      Isar.getInstance()!,
                      attributes.values.toList()[selectedIndex.$1][selectedIndex.$2].id,
                      _attributeType.single,
                    ).then(
                      (value) async {
                        final Isar isar = Isar.getInstance()!;
                        if (value > 0) {
                          await showDialog<void>(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text(AppLocalizations.of(context)!.proceedQuestion),
                                icon: const Icon(Icons.warning),
                                content: Text(AppLocalizations.of(context)!.dependencyPhrase(value)),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text(
                                      AppLocalizations.of(context)!.cancel,
                                    ),
                                  ),
                                  FilledButton.tonal(
                                    onPressed: () async {
                                      final backupIndex = selectedIndex;
                                      final backup =
                                          await getAttributeFromId(isar, attributes.values.toList()[selectedIndex.$1][selectedIndex.$2].id, context: context);
                                      await isar.writeTxn(() async {
                                        await isar.attributes.delete(attributes.values.toList()[selectedIndex.$1][selectedIndex.$2].id);
                                      }).then((_) {
                                        setState(() => selectedIndex = (-1, -1));
                                        Navigator.pop(context);
                                      });
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(AppLocalizations.of(context)!.deletedSnackBar(backup!.name)),
                                            action: SnackBarAction(
                                              label: AppLocalizations.of(context)!.undo,
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
                                                        attributes.values.toList()[backupIndex.$1].insert(backupIndex.$2, backup);
                                                      }
                                                    }
                                                  }
                                                  setState(() => selectedIndex = backupIndex);
                                                });
                                              },
                                            ),
                                            behavior: SnackBarBehavior.floating,
                                          ),
                                        );
                                      }
                                    },
                                    child: Text(AppLocalizations.of(context)!.proceed),
                                  )
                                ],
                              );
                            },
                          );
                        } else {
                          final backupIndex = selectedIndex;
                          final backup = await getAttributeFromId(isar, attributes.values.toList()[selectedIndex.$1][selectedIndex.$2].id, context: context);
                          await isar.writeTxn(() async {
                            await isar.attributes.delete(attributes.values.toList()[selectedIndex.$1][selectedIndex.$2].id);
                          }).then((_) => setState(() => selectedIndex = (-1, -1)));
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(AppLocalizations.of(context)!.deletedSnackBar(backup!.name)),
                                action: SnackBarAction(
                                  label: AppLocalizations.of(context)!.undo,
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
                                            attributes.values.toList()[backupIndex.$1].insert(backupIndex.$2, backup);
                                          }
                                        }
                                      }
                                      setState(() => selectedIndex = backupIndex);
                                    });
                                  },
                                ),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        }
                      },
                    );
                  },
                  icon: Icon(
                    Icons.delete,
                    semanticLabel: selectedIndex.$2 > -1
                        ? AppLocalizations.of(context)!.deleteIconButton(attributes.values.toList()[selectedIndex.$1][selectedIndex.$2].name)
                        : null,
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    if (_controller.text.isEmpty) {
                      _controller.text = attributes.values.toList()[selectedIndex.$1][selectedIndex.$2].name;
                    }
                    await showAttributeDialog<void>(
                      context: context,
                      attribute: attributes.values.toList()[selectedIndex.$1][selectedIndex.$2],
                      controller: _controller,
                      editMode: true,
                    ).then((_) {
                      _controller.clear();
                      setState(() => selectedIndex = (-1, -1));
                    });
                  },
                  icon: Icon(
                    Icons.edit,
                    semanticLabel: selectedIndex.$2 > -1
                        ? AppLocalizations.of(context)!.editIconButton(attributes.values.toList()[selectedIndex.$1][selectedIndex.$2].name)
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
