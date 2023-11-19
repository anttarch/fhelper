import 'package:dynamic_color/dynamic_color.dart';
import 'package:fhelper/src/logic/collections/attribute.dart';
import 'package:fhelper/src/logic/collections/exchange.dart';
import 'package:fhelper/src/logic/widgets/show_attribute_dialog.dart';
import 'package:fhelper/src/logic/widgets/utils.dart' as wid_utils;
import 'package:fhelper/src/views/details/exchange_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';

class AttributeDetailsView extends StatefulWidget {
  const AttributeDetailsView({required this.attribute, super.key});
  final Attribute attribute;

  @override
  State<AttributeDetailsView> createState() => _AttributeDetailsViewState();
}

class _AttributeDetailsViewState extends State<AttributeDetailsView> {
  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.medium(
            title: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                // TODO(antarch): update name when edit
                widget.attribute.name,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
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
                    margin: const EdgeInsets.only(top: 20),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                localization.today,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              FutureBuilder(
                                future: getSumValueByAttribute(
                                  Isar.getInstance()!,
                                  widget.attribute.id,
                                  widget.attribute.type,
                                ),
                                builder: (context, snapshot) {
                                  final value =
                                      snapshot.hasData ? snapshot.data! : 0;
                                  return Text(
                                    NumberFormat.simpleCurrency(
                                      locale: Localizations.localeOf(
                                        context,
                                      ).languageCode,
                                    ).format(value),
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge!
                                        .apply(
                                          color: Color(
                                            value.isNegative
                                                ? 0xffbd1c1c
                                                : 0xff199225,
                                          ).harmonizeWith(
                                            Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          ),
                                        ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 0),
                        // TODO(antarch): implement income and expense details
                        IntrinsicHeight(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    CircularProgressIndicator(
                                      value: .75,
                                      color:
                                          const Color(0xffbd1c1c).harmonizeWith(
                                        Theme.of(context).colorScheme.primary,
                                      ),
                                      backgroundColor:
                                          const Color(0xff199225).harmonizeWith(
                                        Theme.of(context).colorScheme.primary,
                                      ),
                                      strokeWidth: 10,
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '25%',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall!
                                              .apply(
                                                color: const Color(0xff199225)
                                                    .harmonizeWith(
                                                  Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                ),
                                              ),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          '75%',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall!
                                              .apply(
                                                color: const Color(0xffbd1c1c)
                                                    .harmonizeWith(
                                                  Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                ),
                                              ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const VerticalDivider(
                                width: 0,
                                indent: 16,
                                endIndent: 16,
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            localization.income,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleLarge,
                                          ),
                                          Text(
                                            NumberFormat.simpleCurrency(
                                              locale: Localizations.localeOf(
                                                context,
                                              ).languageCode,
                                            ).format(56546),
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleLarge!
                                                .apply(
                                                  color: Color(
                                                    56546.isNegative
                                                        ? 0xffbd1c1c
                                                        : 0xff199225,
                                                  ).harmonizeWith(
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .primary,
                                                  ),
                                                ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            localization.expense,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleLarge,
                                          ),
                                          Text(
                                            NumberFormat.simpleCurrency(
                                              locale: Localizations.localeOf(
                                                context,
                                              ).languageCode,
                                            ).format(56546),
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleLarge!
                                                .apply(
                                                  color: Color(
                                                    56546.isNegative
                                                        ? 0xffbd1c1c
                                                        : 0xff199225,
                                                  ).harmonizeWith(
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .primary,
                                                  ),
                                                ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (widget.attribute.role == AttributeRole.parent)
                    StreamBuilder(
                      stream: Isar.getInstance()!.attributes.watchLazy(),
                      builder: (context, snapshot) {
                        return FutureBuilder(
                          future: getAttributes(
                            Isar.getInstance()!,
                            widget.attribute.type,
                            context: context,
                          ).then(
                            (value) => value.entries
                                .singleWhere(
                                  (e) => e.key.id == widget.attribute.id,
                                )
                                .value,
                          ),
                          builder: (context, snapshot) {
                            final childList = snapshot.hasData
                                ? snapshot.data!
                                : <Attribute>[];
                            return _ParentChildren(
                              children: childList,
                              title:
                                  widget.attribute.type == AttributeType.account
                                      ? localization.subaccount
                                      : localization.subtype,
                            );
                          },
                        );
                      },
                    )
                  else
                    FutureBuilder(
                      future: getExchangesByAttribute(
                        Isar.getInstance()!,
                        widget.attribute.id,
                        widget.attribute.type,
                      ),
                      builder: (context, snapshot) {
                        final exchanges =
                            snapshot.hasData ? snapshot.data! : <Exchange>[];
                        return _ChildExchanges(exchanges: exchanges);
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final controller = TextEditingController();
          if (widget.attribute.role == AttributeRole.parent) {
            await showAttributeDialog<void>(
              context: context,
              attributeRole: AttributeRole.child,
              attributeType: AttributeType.account,
              controller: controller,
              parentId: widget.attribute.id,
            ).then((_) => controller.clear());
          } else {
            if (controller.text.isEmpty) {
              controller.text = widget.attribute.name;
            }
            await showAttributeDialog<void>(
              context: context,
              attribute: widget.attribute,
              controller: controller,
              editMode: true,
            ).then((_) => controller.clear());
          }
        },
        elevation: 0,
        child: Icon(
          widget.attribute.role == AttributeRole.parent
              ? Icons.add
              : Icons.edit,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
      bottomNavigationBar: BottomAppBar(
        child: Row(
          children: [
            if (widget.attribute.role == AttributeRole.parent)
              Row(
                mainAxisSize: MainAxisSize.min,
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
              )
            else
              IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.info,
                  semanticLabel:
                      localization.infoIconButton(widget.attribute.name),
                ),
              ),
            IconButton(
              onPressed: () async {
                final isar = Isar.getInstance()!;
                Future<void> isarDelete() async {
                  await isar.writeTxn(() async {
                    await isar.attributes.delete(widget.attribute.id);
                  });
                }

                if (widget.attribute.role == AttributeRole.parent) {
                  final selection =
                      widget.attribute.type == AttributeType.account ? 2 : 1;
                  await showDialog<void>(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        icon: const Icon(Icons.delete_forever),
                        title: Text(
                          localization.deletePermanentlyQuestion,
                        ),
                        content: Text(
                          localization.deleteContentDescription(selection),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(localization.cancel),
                          ),
                          FilledButton.tonal(
                            onPressed: () async => isarDelete().then(
                              (_) {
                                Navigator.pop<Attribute>(
                                  context,
                                  widget.attribute,
                                );
                                Navigator.pop<Attribute>(
                                  context,
                                  widget.attribute,
                                );
                              },
                            ),
                            child: Text(localization.delete),
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  await checkForAttributeDependencies(
                    isar,
                    widget.attribute.id,
                    AttributeType.account,
                  ).then(
                    (value) async {
                      if (value > 0) {
                        await showDialog<void>(
                          context: context,
                          builder: (context) {
                            final localization = AppLocalizations.of(context)!;
                            return AlertDialog(
                              title: Text(localization.proceedQuestion),
                              icon: const Icon(Icons.warning),
                              content:
                                  Text(localization.dependencyPhrase(value)),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(localization.cancel),
                                ),
                                FilledButton.tonal(
                                  onPressed: () async => isarDelete().then(
                                    (_) => Navigator.pop<Attribute>(
                                      context,
                                      widget.attribute,
                                    ),
                                  ),
                                  child: Text(localization.proceed),
                                ),
                              ],
                            );
                          },
                        );
                      } else {
                        await isarDelete().then(
                          (_) => Navigator.pop<Attribute>(
                            context,
                            widget.attribute,
                          ),
                        );
                      }
                    },
                  );
                }
              },
              icon: Icon(
                Icons.delete,
                semanticLabel:
                    localization.deleteIconButton(widget.attribute.name),
              ),
            ),
            if (widget.attribute.role == AttributeRole.parent)
              IconButton(
                onPressed: () async {
                  final controller = TextEditingController();
                  if (controller.text.isEmpty) {
                    controller.text = widget.attribute.name;
                  }
                  await showAttributeDialog<void>(
                    context: context,
                    attribute: widget.attribute,
                    controller: controller,
                    editMode: true,
                  ).then((_) => controller.clear());
                },
                icon: Icon(
                  Icons.edit,
                  semanticLabel:
                      localization.editIconButton(widget.attribute.name),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ParentChildren extends StatelessWidget {
  const _ParentChildren({
    required this.children,
    required this.title,
  });

  final List<Attribute> children;
  final String title;

  SnackBar _undoSnackBar(
    int backupIndex,
    Attribute? backupAttribute,
    Isar isar,
    BuildContext context,
  ) {
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
            if (backupIndex == children.length + 1) {
              children.add(backupAttribute);
            } else if (backupIndex < children.length + 1) {
              children.insert(backupIndex, backupAttribute);
            }
          });
        },
      ),
      behavior: SnackBarBehavior.floating,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
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
          margin: const EdgeInsets.only(top: 16),
          child: ListView.separated(
            itemCount: children.length,
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return ListTile(
                shape: wid_utils.getShapeBorder(index, children.length - 1),
                title: Text(children[index].name),
                trailing: Icon(
                  Icons.arrow_right,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                onTap: () async {
                  final backupAttribute = await Navigator.push(
                    context,
                    MaterialPageRoute<Attribute>(
                      builder: (context) => AttributeDetailsView(
                        attribute: children[index],
                      ),
                    ),
                  );

                  if (backupAttribute != null && context.mounted) {
                    final backupIndex = children.indexOf(backupAttribute);
                    children.removeAt(backupIndex);
                    ScaffoldMessenger.of(context).showSnackBar(
                      _undoSnackBar(
                        backupIndex,
                        backupAttribute,
                        Isar.getInstance()!,
                        context,
                      ),
                    );
                  }
                },
              );
            },
            separatorBuilder: (_, __) => const Divider(height: 0),
          ),
        ),
      ],
    );
  }
}

class _ChildExchanges extends StatelessWidget {
  const _ChildExchanges({required this.exchanges});

  final List<Exchange> exchanges;

  Icon? _getLeadingIcon(Exchange exchange) {
    if (exchange.installments != null) {
      return const Icon(Icons.credit_card);
    } else if (exchange.eType == EType.transfer) {
      return const Icon(Icons.swap_horiz);
    } else if (exchange.id == -1) {
      return const Icon(Icons.receipt_long);
    }
    return null;
  }

  Color _getColor(BuildContext context, Exchange? exchange) {
    if (exchange != null) {
      var valueColor =
          Color(exchange.value.isNegative ? 0xffbd1c1c : 0xff199225)
              .harmonizeWith(Theme.of(context).colorScheme.primary);
      if (exchange.installments != null) {
        valueColor = Theme.of(context).colorScheme.inverseSurface;
      } else if (exchange.eType == EType.transfer) {
        valueColor = Theme.of(context).colorScheme.tertiary;
      }
      return valueColor;
    }
    return Theme.of(context).colorScheme.inverseSurface;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Text(
            'Recent',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        Card(
          elevation: 0,
          color: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            borderRadius: const BorderRadius.all(
              Radius.circular(12),
            ),
          ),
          margin: const EdgeInsets.only(top: 16),
          child: ListView.separated(
            itemCount: exchanges.length,
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return ListTile(
                shape: wid_utils.getShapeBorder(index, exchanges.length - 1),
                leading: _getLeadingIcon(exchanges[index]),
                title: Text(
                  exchanges[index].description,
                ),
                subtitle: Text(
                  NumberFormat.simpleCurrency(
                    locale: Localizations.localeOf(context).languageCode,
                  ).format(exchanges[index].value),
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .apply(color: _getColor(context, exchanges[index])),
                ),
                trailing: Icon(
                  Icons.arrow_right,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute<ExchangeDetailsView>(
                    builder: (context) => ExchangeDetailsView(
                      item: exchanges[index],
                    ),
                  ),
                ),
              );
            },
            separatorBuilder: (_, __) => const Divider(height: 0),
          ),
        ),
      ],
    );
  }
}
