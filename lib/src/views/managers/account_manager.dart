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
  int selectedIndex = -1;
  List<Attribute> attributes = [];

  Widget _selectedIndicator(int index) {
    return Radio(
      value: index,
      groupValue: selectedIndex,
      onChanged: (value) => setState(() {
        selectedIndex = value!;
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
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        return Future<bool>.value(true);
      },
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar.medium(
              title: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  selectedIndex > -1 ? AppLocalizations.of(context)!.select : AppLocalizations.of(context)!.account(-1),
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              actions: [
                if (selectedIndex > -1)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: IconButton(
                      onPressed: () => setState(() => selectedIndex = -1),
                      icon: Icon(
                        Icons.deselect,
                        semanticLabel: selectedIndex > -1 ? AppLocalizations.of(context)!.deselectIconButton : null,
                      ),
                    ),
                  )
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
                      ),
                      builder: (context, snapshot) {
                        attributes = snapshot.hasData ? snapshot.data! : [];
                        return Card(
                          elevation: 0,
                          margin: const EdgeInsets.symmetric(horizontal: 22),
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
                            itemCount: attributes.length,
                            itemBuilder: (context, index) {
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                                    shape: wid_utils.getShapeBorder(index, attributes.length - 1),
                                    tileColor: selectedIndex == index ? Theme.of(context).colorScheme.surfaceVariant : null,
                                    title: Text(
                                      attributes[index].name,
                                      style: Theme.of(context).textTheme.bodyLarge,
                                    ),
                                    trailing: selectedIndex == -1
                                        ? Icon(
                                            Icons.arrow_right,
                                            color: Theme.of(context).colorScheme.onSurface,
                                          )
                                        : _selectedIndicator(index),
                                    onTap: () {
                                      if (selectedIndex > -1) {
                                        if (selectedIndex != index) {
                                          setState(() {
                                            selectedIndex = index;
                                          });
                                        }
                                      } else {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute<AttributeDetailsView>(
                                            builder: (context) => AttributeDetailsView(
                                              attribute: attributes[index],
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    onLongPress: () {
                                      setState(() {
                                        selectedIndex = index;
                                      });
                                    },
                                  ),
                                ],
                              );
                            },
                            separatorBuilder: (_, __) => Divider(
                              height: 2,
                              thickness: 1.5,
                              color: Theme.of(context).colorScheme.outlineVariant,
                            ),
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
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => showAttributeDialog<void>(
            context: context,
            attributeType: AttributeType.account,
            controller: _controller,
          ).then((_) {
            _controller.clear();
            setState(() => selectedIndex = -1);
          }),
          label: Text(
            AppLocalizations.of(context)!.account(1),
            semanticsLabel: AppLocalizations.of(context)!.addAccountFAB,
          ),
          icon: const Icon(Icons.add),
          elevation: selectedIndex > -1 ? 0 : null,
        ),
        floatingActionButtonLocation: selectedIndex > -1 ? FloatingActionButtonLocation.endContained : null,
        bottomNavigationBar: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: selectedIndex > -1 ? 80 + MediaQuery.paddingOf(context).bottom : 0,
          child: BottomAppBar(
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute<AttributeDetailsView>(
                      builder: (context) => AttributeDetailsView(
                        attribute: attributes[selectedIndex],
                      ),
                    ),
                  ),
                  icon: Icon(
                    Icons.info,
                    semanticLabel: selectedIndex > -1 ? AppLocalizations.of(context)!.infoIconButton(attributes[selectedIndex].name) : null,
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    await checkForAttributeDependencies(Isar.getInstance()!, attributes[selectedIndex].id, AttributeType.account).then(
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
                                      final backup = await isar.attributes.get(attributes[selectedIndex].id);
                                      await isar.writeTxn(() async {
                                        await isar.attributes.delete(attributes[selectedIndex].id);
                                      }).then((_) {
                                        setState(() => selectedIndex = -1);
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
                                                }).then((_) => setState(() => selectedIndex = backupIndex));
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
                          final backup = await isar.attributes.get(attributes[selectedIndex].id);
                          await isar.writeTxn(() async {
                            await isar.attributes.delete(attributes[selectedIndex].id);
                          }).then((_) => setState(() => selectedIndex = -1));
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(AppLocalizations.of(context)!.deletedSnackBar(backup!.name)),
                                action: SnackBarAction(
                                  label: AppLocalizations.of(context)!.undo,
                                  onPressed: () async {
                                    await isar.writeTxn(() async {
                                      await isar.attributes.put(backup);
                                    }).then((_) => setState(() => selectedIndex = backupIndex));
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
                    semanticLabel: selectedIndex > -1 ? AppLocalizations.of(context)!.deleteIconButton(attributes[selectedIndex].name) : null,
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    if (_controller.text.isEmpty) {
                      _controller.text = attributes[selectedIndex].name;
                    }
                    await showAttributeDialog<void>(
                      context: context,
                      attribute: attributes[selectedIndex],
                      attributeType: AttributeType.account,
                      controller: _controller,
                      editMode: true,
                    ).then((_) {
                      _controller.clear();
                      setState(() => selectedIndex = -1);
                    });
                  },
                  icon: Icon(
                    Icons.edit,
                    semanticLabel: selectedIndex > -1 ? AppLocalizations.of(context)!.editIconButton(attributes[selectedIndex].name) : null,
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
