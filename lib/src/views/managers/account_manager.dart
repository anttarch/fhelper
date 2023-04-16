import 'package:dynamic_color/dynamic_color.dart';
import 'package:fhelper/src/logic/collections/attribute.dart';
import 'package:fhelper/src/logic/collections/exchange.dart';
import 'package:fhelper/src/widgets/inputfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';

class AccountManager extends StatefulWidget {
  const AccountManager({super.key});

  @override
  State<AccountManager> createState() => _AccountManagerState();
}

class _AccountManagerState extends State<AccountManager> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.medium(
            title: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                AppLocalizations.of(context)!.account(-1),
                style: Theme.of(context).textTheme.headlineMedium,
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
                      AttributeType.account,
                    ),
                    builder: (context, snapshot) {
                      final List<Attribute> attributes = snapshot.hasData ? snapshot.data! : [];
                      return ListView.separated(
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
                                  enableDrag: false,
                                  builder: (context) {
                                    return SafeArea(
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                                        child: SingleChildScrollView(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.stretch,
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    attributes[index].name,
                                                    style: Theme.of(context).textTheme.headlineMedium,
                                                  ),
                                                  FutureBuilder(
                                                    future: getSumValueByAttribute(Isar.getInstance()!, attributes[index].id, AttributeType.account),
                                                    builder: (context, snapshot) {
                                                      return Text(
                                                        snapshot.hasData
                                                            ? NumberFormat.simpleCurrency(locale: Localizations.localeOf(context).languageCode)
                                                                .format(snapshot.data)
                                                            : '',
                                                        style: Theme.of(context).textTheme.headlineMedium!.apply(
                                                              color: Color(
                                                                snapshot.hasData && snapshot.data! < 0 ? 0xffbd1c1c : 0xff199225,
                                                              ).harmonizeWith(
                                                                Theme.of(context).colorScheme.primary,
                                                              ),
                                                            ),
                                                      );
                                                    },
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 15),
                                              FutureBuilder(
                                                future: checkForAttributeDependencies(Isar.getInstance()!, attributes[index].id, AttributeType.account),
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
                                                  useSafeArea: MediaQuery.orientationOf(context) == Orientation.portrait,
                                                  builder: (context) {
                                                    final formKey = GlobalKey<FormState>();
                                                    _controller.text = attributes[index].name;
                                                    if (MediaQuery.orientationOf(context) == Orientation.portrait) {
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
                                                              } else if (value.contains('#/spt#/')) {
                                                                return AppLocalizations.of(context)!.invalidName;
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
                                                    }
                                                    return Dialog.fullscreen(
                                                      child: CustomScrollView(
                                                        slivers: [
                                                          SliverAppBar(
                                                            pinned: true,
                                                            forceElevated: true,
                                                            title: Text(AppLocalizations.of(context)!.edit),
                                                            leading: IconButton(
                                                              onPressed: () => Navigator.pop(context),
                                                              icon: const Icon(Icons.close),
                                                            ),
                                                            actions: [
                                                              TextButton(
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
                                                                child: Text(AppLocalizations.of(context)!.save),
                                                              ),
                                                            ],
                                                          ),
                                                          SliverToBoxAdapter(
                                                            child: Padding(
                                                              padding: const EdgeInsets.symmetric(horizontal: 24),
                                                              child: Form(
                                                                key: formKey,
                                                                child: Padding(
                                                                  padding: const EdgeInsets.only(top: 15),
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
                                                                      } else if (value.contains('#/spt#/')) {
                                                                        return AppLocalizations.of(context)!.invalidName;
                                                                      }
                                                                      return null;
                                                                    },
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
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
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
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
                    useSafeArea: MediaQuery.orientationOf(context) == Orientation.portrait,
                    builder: (context) {
                      final formKey = GlobalKey<FormState>();
                      if (MediaQuery.orientationOf(context) == Orientation.portrait) {
                        return AlertDialog(
                          title: Text(AppLocalizations.of(context)!.add),
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
                                } else if (value.contains('#/spt#/')) {
                                  return AppLocalizations.of(context)!.invalidName;
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
                                    type: AttributeType.account,
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
                      }
                      return Dialog.fullscreen(
                        child: CustomScrollView(
                          slivers: [
                            SliverAppBar(
                              pinned: true,
                              forceElevated: true,
                              title: Text(AppLocalizations.of(context)!.add),
                              leading: IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(Icons.close),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () async {
                                    if (formKey.currentState!.validate()) {
                                      final Isar isar = Isar.getInstance()!;
                                      final Attribute attribute = Attribute(
                                        name: _controller.text,
                                        type: AttributeType.account,
                                      );
                                      await isar.writeTxn(() async {
                                        await isar.attributes.put(attribute);
                                      }).then((_) => Navigator.pop(context));
                                    }
                                  },
                                  child: Text(AppLocalizations.of(context)!.add),
                                ),
                              ],
                            ),
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                child: Form(
                                  key: formKey,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 15),
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
                                        } else if (value.contains('#/spt#/')) {
                                          return AppLocalizations.of(context)!.invalidName;
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
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
      ),
    );
  }
}
