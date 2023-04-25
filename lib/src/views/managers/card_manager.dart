import 'package:fhelper/src/logic/collections/attribute.dart';
import 'package:fhelper/src/logic/collections/card.dart' as fhelper;
import 'package:fhelper/src/logic/collections/exchange.dart';
import 'package:fhelper/src/logic/widgets/show_card_dialog.dart';
import 'package:fhelper/src/logic/widgets/utils.dart' as wid_utils;
import 'package:fhelper/src/views/details/card_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:isar/isar.dart';

class CardManager extends StatefulWidget {
  const CardManager({super.key});

  @override
  State<CardManager> createState() => _CardManagerState();
}

class _CardManagerState extends State<CardManager> {
  int selectedIndex = -1;
  List<fhelper.Card> cards = [];

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
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (selectedIndex > -1) {
          setState(() => selectedIndex = -1);
          return Future<bool>.value(false);
        }
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
                  selectedIndex > -1 ? AppLocalizations.of(context)!.select : AppLocalizations.of(context)!.card(-1),
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
                  stream: Isar.getInstance()!.cards.watchLazy(),
                  builder: (context, snapshot) {
                    return FutureBuilder(
                      future: fhelper.getCards(Isar.getInstance()!),
                      builder: (context, snapshot) {
                        cards = snapshot.hasData ? snapshot.data! : [];
                        return Card(
                          elevation: 0,
                          margin: const EdgeInsets.fromLTRB(22, 15, 22, 0),
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
                            itemCount: cards.length,
                            itemBuilder: (context, index) {
                              return Column(
                                children: [
                                  ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                                    shape: wid_utils.getShapeBorder(index, cards.length - 1),
                                    tileColor: selectedIndex == index ? Theme.of(context).colorScheme.surfaceVariant : null,
                                    title: Text(
                                      cards[index].name,
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
                                          MaterialPageRoute<CardDetailsView>(
                                            builder: (context) => CardDetailsView(
                                              card: cards[index],
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
          onPressed: () => showCardForm(context: context).then((_) => setState(() => selectedIndex = -1)),
          label: Text(
            AppLocalizations.of(context)!.card(1),
            semanticsLabel: AppLocalizations.of(context)!.addCardFAB,
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
                    MaterialPageRoute<CardDetailsView>(
                      builder: (context) => CardDetailsView(
                        card: cards[selectedIndex],
                      ),
                    ),
                  ),
                  icon: Icon(
                    Icons.info,
                    semanticLabel: selectedIndex > -1 ? AppLocalizations.of(context)!.infoIconButton(cards[selectedIndex].name) : null,
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    await checkForAttributeDependencies(Isar.getInstance()!, cards[selectedIndex].id, null).then(
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
                                      final backup = await isar.cards.get(cards[selectedIndex].id);
                                      await isar.writeTxn(() async {
                                        await isar.cards.delete(cards[selectedIndex].id);
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
                                                  await isar.cards.put(backup);
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
                          final backup = await isar.cards.get(cards[selectedIndex].id);
                          await isar.writeTxn(() async {
                            await isar.cards.delete(cards[selectedIndex].id);
                          }).then((_) => setState(() => selectedIndex = -1));
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(AppLocalizations.of(context)!.deletedSnackBar(backup!.name)),
                                action: SnackBarAction(
                                  label: AppLocalizations.of(context)!.undo,
                                  onPressed: () async {
                                    await isar.writeTxn(() async {
                                      await isar.cards.put(backup);
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
                    semanticLabel: selectedIndex > -1 ? AppLocalizations.of(context)!.deleteIconButton(cards[selectedIndex].name) : null,
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    final Attribute? attribute = await getAttributeFromId(Isar.getInstance()!, cards[selectedIndex].accountId);
                    if (mounted) {
                      await showCardForm(context: context, editMode: true, card: cards[selectedIndex], cardAttribute: attribute)
                          .then((_) => setState(() => selectedIndex = -1));
                    }
                  },
                  icon: Icon(
                    Icons.edit,
                    semanticLabel: selectedIndex > -1 ? AppLocalizations.of(context)!.editIconButton(cards[selectedIndex].name) : null,
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
