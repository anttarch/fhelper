import 'package:fhelper/src/logic/collections/attribute.dart';
import 'package:fhelper/src/logic/collections/exchange.dart';
import 'package:fhelper/src/widgets/inputfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:isar/isar.dart';

class TypeManager extends StatefulWidget {
  const TypeManager({super.key});

  @override
  State<TypeManager> createState() => _TypeManagerState();
}

class _TypeManagerState extends State<TypeManager> {
  Set<AttributeType> _attributeType = {AttributeType.incomeType};

  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
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
                child: SizedBox(
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
                                              builder: (context) {
                                                return SafeArea(
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(20),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                                      mainAxisAlignment: MainAxisAlignment.end,
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Text(
                                                          attributes[index].name,
                                                          style: Theme.of(context).textTheme.headlineMedium,
                                                        ),
                                                        const SizedBox(height: 15),
                                                        FutureBuilder(
                                                          future:
                                                              checkForAttributeDependencies(Isar.getInstance()!, attributes[index].id, _attributeType.single),
                                                          builder: (context, snapshot) {
                                                            return OutlinedButton.icon(
                                                              icon: const Icon(Icons.delete),
                                                              onPressed: () async {
                                                                final Isar isar = Isar.getInstance()!;
                                                                if (snapshot.data != null && snapshot.data! > 0) {
                                                                  await showDialog<void>(
                                                                    context: context,
                                                                    builder: (context) {
                                                                      return AlertDialog(
                                                                        title: Text(AppLocalizations.of(context)!.proceedQuestion),
                                                                        icon: const Icon(Icons.warning),
                                                                        content: Text(AppLocalizations.of(context)!.dependencyPhrase(snapshot.data!)),
                                                                        actions: [
                                                                          TextButton(
                                                                            onPressed: () => Navigator.pop(context),
                                                                            child: Text(
                                                                              AppLocalizations.of(context)!.cancel,
                                                                            ),
                                                                          ),
                                                                          FilledButton.tonal(
                                                                            onPressed: () async {
                                                                              await isar.writeTxn(() async {
                                                                                await isar.attributes.delete(attributes[index].id);
                                                                              }).then((_) => Navigator.pop(context));
                                                                            },
                                                                            child: Text(AppLocalizations.of(context)!.proceed),
                                                                          )
                                                                        ],
                                                                      );
                                                                    },
                                                                  );
                                                                } else {
                                                                  await isar.writeTxn(() async {
                                                                    await isar.attributes.delete(attributes[index].id);
                                                                  }).then((_) => Navigator.pop(context));
                                                                }
                                                              },
                                                              label: Text(AppLocalizations.of(context)!.delete),
                                                            );
                                                          },
                                                        ),
                                                        FilledButton.icon(
                                                          onPressed: () => showDialog<void>(
                                                            context: context,
                                                            builder: (context) {
                                                              final formKey = GlobalKey<FormState>();
                                                              _controller.text = attributes[index].name;
                                                              return AlertDialog(
                                                                title: Text(AppLocalizations.of(context)!.edit),
                                                                icon: const Icon(Icons.edit),
                                                                content: Form(
                                                                  key: formKey,
                                                                  child: InputField(
                                                                    controller: _controller,
                                                                    label: AppLocalizations.of(context)!.name,
                                                                    inputFormatters: [
                                                                      LengthLimitingTextInputFormatter(15),
                                                                    ],
                                                                    validator: (value) {
                                                                      if (value!.isEmpty) {
                                                                        return AppLocalizations.of(context)!.emptyField;
                                                                      } else if (value.length < 3) {
                                                                        return AppLocalizations.of(context)!.threeCharactersMinimum;
                                                                      }
                                                                      return null;
                                                                    },
                                                                  ),
                                                                ),
                                                                actions: [
                                                                  TextButton(
                                                                    onPressed: () => Navigator.pop(context),
                                                                    child: Text(AppLocalizations.of(context)!.cancel),
                                                                  ),
                                                                  FilledButton.tonalIcon(
                                                                    icon: const Icon(Icons.done),
                                                                    onPressed: () async {
                                                                      if (formKey.currentState!.validate()) {
                                                                        final Isar isar = Isar.getInstance()!;
                                                                        final Attribute attribute = attributes[index].copyWith(name: _controller.text);
                                                                        await isar.writeTxn(() async {
                                                                          await isar.attributes.put(attribute);
                                                                        }).then((_) {
                                                                          Navigator.pop(context);
                                                                          Navigator.pop(context);
                                                                        });
                                                                      }
                                                                    },
                                                                    label: Text(AppLocalizations.of(context)!.save),
                                                                  ),
                                                                ],
                                                              );
                                                            },
                                                          ).then((_) => _controller.clear()),
                                                          icon: const Icon(Icons.edit),
                                                          label: Text(AppLocalizations.of(context)!.edit),
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
                            final formKey = GlobalKey<FormState>();
                            return AlertDialog(
                              title: Text(
                                AppLocalizations.of(context)!.add,
                              ),
                              icon: const Icon(Icons.add),
                              content: Form(
                                key: formKey,
                                child: InputField(
                                  controller: _controller,
                                  label: AppLocalizations.of(context)!.name,
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(15),
                                  ],
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return AppLocalizations.of(context)!.emptyField;
                                    } else if (value.length < 3) {
                                      return AppLocalizations.of(context)!.threeCharactersMinimum;
                                    }
                                    return null;
                                  },
                                ),
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
                                    if (formKey.currentState!.validate()) {
                                      final Isar isar = Isar.getInstance()!;
                                      final Attribute attribute = Attribute(
                                        name: _controller.text,
                                        type: _attributeType.single,
                                      );
                                      await isar.writeTxn(() async {
                                        await isar.attributes.put(attribute);
                                      }).then((_) => Navigator.pop(context));
                                    }
                                  },
                                  label: Text(AppLocalizations.of(context)!.add),
                                ),
                              ],
                            );
                          },
                        ).then((_) => _controller.clear()),
                        icon: const Icon(Icons.add),
                        label: Text(AppLocalizations.of(context)!.add),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
