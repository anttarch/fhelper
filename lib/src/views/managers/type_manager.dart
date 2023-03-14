import 'package:dynamic_color/dynamic_color.dart';
import 'package:fhelper/src/logic/collections/attribute.dart';
import 'package:fhelper/src/widgets/inputfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:isar/isar.dart';

class TypeManager extends StatefulWidget {
  const TypeManager({super.key});

  @override
  State<TypeManager> createState() => _TypeManagerState();
}

class _TypeManagerState extends State<TypeManager> {
  Set<AttributeType> _attributeType = {AttributeType.incomeType};

  final List<TextEditingController> _controller = [
    TextEditingController(),
    TextEditingController(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height - 88 - MediaQuery.of(context).padding.bottom - MediaQuery.of(context).padding.top,
              child: CustomScrollView(
                slivers: [
                  SliverAppBar.medium(
                    title: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        AppLocalizations.of(context)!.type(-1),
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
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
                            ),
                            builder: (context, snapshot) {
                              final List<Attribute> attributes = snapshot.hasData ? snapshot.data! : [];
                              return ListView.separated(
                                shrinkWrap: true,
                                itemCount: attributes.length,
                                itemBuilder: (context, index) {
                                  return Column(
                                    children: [
                                      ListTile(
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                                        title: Text(
                                          attributes[index].name,
                                          style: Theme.of(context).textTheme.bodyLarge,
                                        ),
                                        trailing: Icon(
                                          Icons.arrow_right,
                                          color: Theme.of(context).colorScheme.onSurface,
                                        ),
                                        onTap: () => showModalBottomSheet<void>(
                                          context: context,
                                          constraints: BoxConstraints(
                                            maxHeight: MediaQuery.of(context).size.height / 3.2,
                                          ),
                                          builder: (context) {
                                            return Padding(
                                              padding: const EdgeInsets.all(20),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    attributes[index].name,
                                                    style: Theme.of(context).textTheme.headlineMedium,
                                                  ),
                                                  const SizedBox(height: 15),
                                                  OutlinedButton.icon(
                                                    icon: const Icon(Icons.delete),
                                                    onPressed: () async {
                                                      final Isar isar = Isar.getInstance()!;
                                                      await isar.writeTxn(() async {
                                                        await isar.attributes.delete(attributes[index].id);
                                                      }).then((_) => Navigator.pop(context));
                                                    },
                                                    label: Text(AppLocalizations.of(context)!.delete),
                                                  ),
                                                  FilledButton.icon(
                                                    onPressed: () => showDialog<void>(
                                                      context: context,
                                                      builder: (context) {
                                                        _controller[1].text = attributes[index].name;
                                                        return AlertDialog(
                                                          title: Text(AppLocalizations.of(context)!.edit),
                                                          icon: const Icon(Icons.edit),
                                                          content: InputField(
                                                            controller: _controller[1],
                                                            label: AppLocalizations.of(context)!.name,
                                                          ),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () => Navigator.pop(context),
                                                              child: Text(AppLocalizations.of(context)!.cancel),
                                                            ),
                                                            FilledButton.tonalIcon(
                                                              icon: const Icon(Icons.done),
                                                              onPressed: () async {
                                                                final Isar isar = Isar.getInstance()!;
                                                                final Attribute attribute = attributes[index].copyWith(name: _controller[1].text);
                                                                await isar.writeTxn(() async {
                                                                  await isar.attributes.put(attribute);
                                                                }).then((_) {
                                                                  Navigator.pop(context);
                                                                  Navigator.pop(context);
                                                                  _controller[1].clear();
                                                                });
                                                              },
                                                              label: Text(AppLocalizations.of(context)!.save),
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    ),
                                                    icon: const Icon(Icons.edit),
                                                    label: Text(AppLocalizations.of(context)!.edit),
                                                    style: ButtonStyle(
                                                      backgroundColor: MaterialStatePropertyAll<Color>(
                                                        Theme.of(context).colorScheme.primary,
                                                      ),
                                                      foregroundColor: MaterialStatePropertyAll<Color>(
                                                        Colors.white.harmonizeWith(
                                                          Theme.of(context).colorScheme.primary,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const Divider(
                                                    height: 24,
                                                    thickness: 2,
                                                  ),
                                                  FilledButton.tonalIcon(
                                                    onPressed: () => Navigator.pop(context),
                                                    icon: const Icon(Icons.arrow_back),
                                                    label: Text(AppLocalizations.of(context)!.back),
                                                  )
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      if (index == attributes.length - 1)
                                        Divider(
                                          height: 1,
                                          thickness: 1,
                                          color: Theme.of(context).colorScheme.outlineVariant,
                                        ),
                                    ],
                                  );
                                },
                                separatorBuilder: (_, __) => Divider(
                                  height: 1,
                                  thickness: 1,
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
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(AppLocalizations.of(context)!.back),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => showDialog<void>(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text(
                              AppLocalizations.of(context)!.add,
                            ),
                            icon: const Icon(Icons.add),
                            content: InputField(
                              controller: _controller[0],
                              label: AppLocalizations.of(context)!.name,
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(
                                  AppLocalizations.of(context)!.cancel,
                                ),
                              ),
                              FilledButton.tonalIcon(
                                icon: const Icon(Icons.add),
                                onPressed: () async {
                                  final Isar isar = Isar.getInstance()!;
                                  final Attribute attribute = Attribute(
                                    name: _controller[0].text,
                                    type: _attributeType.single,
                                  );
                                  await isar.writeTxn(() async {
                                    await isar.attributes.put(attribute);
                                  }).then((_) => Navigator.pop(context));
                                  _controller[0].clear();
                                },
                                label: Text(AppLocalizations.of(context)!.add),
                              ),
                            ],
                          );
                        },
                      ),
                      icon: const Icon(Icons.add),
                      label: Text(AppLocalizations.of(context)!.add),
                      style: ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll<Color>(
                          Theme.of(context).colorScheme.primary,
                        ),
                        foregroundColor: MaterialStatePropertyAll<Color>(
                          Colors.white.harmonizeWith(
                            Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}