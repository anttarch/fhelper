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

  SnackBar _undoSnackBar(int backupIndex, fhelper.Card? backup, Isar isar) {
    final localization = AppLocalizations.of(context)!;
    return SnackBar(
      content: Text(
        localization.deletedSnackBar(backup!.name),
      ),
      action: SnackBarAction(
        label: localization.undo,
        onPressed: () async {
          await isar.writeTxn(() async {
            await isar.cards.put(backup);
          }).then((_) {
            if (!cards.contains(backup)) {
              if (cards.length + 1 == backupIndex) {
                cards.add(backup);
              } else if (backupIndex < cards.length + 1) {
                cards.insert(backupIndex, backup);
              }
            }
            setState(() => selectedIndex = backupIndex);
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
            final backup = await isar.cards.get(cards[selectedIndex].id);
            await isar.writeTxn(() async {
              await isar.cards.delete(cards[selectedIndex].id);
            }).then((_) {
              setState(() => selectedIndex = -1);
              Navigator.pop(context);
            });
            if (mounted) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(_undoSnackBar(backupIndex, backup, isar));
            }
          },
          child: Text(localization.proceed),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
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
                  selectedIndex > -1
                      ? localization.select
                      : localization.card(-1),
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
                        semanticLabel: selectedIndex > -1
                            ? localization.deselectIconButton
                            : null,
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
                          margin: const EdgeInsets.fromLTRB(22, 12, 22, 0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color:
                                  Theme.of(context).colorScheme.outlineVariant,
                            ),
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            itemCount: cards.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                shape: wid_utils.getShapeBorder(
                                  index,
                                  cards.length - 1,
                                ),
                                tileColor: selectedIndex == index
                                    ? Theme.of(context)
                                        .colorScheme
                                        .surfaceVariant
                                    : null,
                                title: Text(
                                  cards[index].name,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                trailing: selectedIndex == -1
                                    ? Icon(
                                        Icons.arrow_right,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
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
                              );
                            },
                            separatorBuilder: (_, __) => Divider(
                              height: 2,
                              thickness: 1.5,
                              color:
                                  Theme.of(context).colorScheme.outlineVariant,
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
          onPressed: () => showCardForm(context: context)
              .then((_) => setState(() => selectedIndex = -1)),
          label: Text(
            localization.card(1),
            semanticsLabel: localization.addCardFAB,
          ),
          icon: const Icon(Icons.add),
          elevation: selectedIndex > -1 ? 0 : null,
        ),
        floatingActionButtonLocation: selectedIndex > -1
            ? FloatingActionButtonLocation.endContained
            : null,
        bottomNavigationBar: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: selectedIndex > -1
              ? 80 + MediaQuery.paddingOf(context).bottom
              : 0,
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
                    semanticLabel: selectedIndex > -1
                        ? localization.infoIconButton(cards[selectedIndex].name)
                        : null,
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    await checkForAttributeDependencies(
                      Isar.getInstance()!,
                      cards[selectedIndex].id,
                      null,
                    ).then(
                      (value) async {
                        final isar = Isar.getInstance()!;
                        if (value > 0) {
                          await showDialog<void>(
                            context: context,
                            builder: (context) =>
                                _dependencyDialog(value, isar),
                          );
                        } else {
                          final backupIndex = selectedIndex;
                          final backup =
                              await isar.cards.get(cards[selectedIndex].id);
                          await isar.writeTxn(() async {
                            await isar.cards.delete(cards[selectedIndex].id);
                          }).then((_) => setState(() => selectedIndex = -1));
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              _undoSnackBar(backupIndex, backup, isar),
                            );
                          }
                        }
                      },
                    );
                  },
                  icon: Icon(
                    Icons.delete,
                    semanticLabel: selectedIndex > -1
                        ? localization
                            .deleteIconButton(cards[selectedIndex].name)
                        : null,
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    if (mounted) {
                      await showCardForm(
                        context: context,
                        editMode: true,
                        card: cards[selectedIndex],
                      ).then((_) => setState(() => selectedIndex = -1));
                    }
                  },
                  icon: Icon(
                    Icons.edit,
                    semanticLabel: selectedIndex > -1
                        ? localization.editIconButton(cards[selectedIndex].name)
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
