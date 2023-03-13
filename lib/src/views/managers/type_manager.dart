import 'package:dynamic_color/dynamic_color.dart';
import 'package:fhelper/src/widgets/inputfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TypeManager extends StatefulWidget {
  const TypeManager({super.key});

  @override
  State<TypeManager> createState() => _TypeManagerState();
}

class _TypeManagerState extends State<TypeManager> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height -
                  88 -
                  MediaQuery.of(context).padding.bottom -
                  MediaQuery.of(context).padding.top,
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
                    child: Material(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: 2,
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              ListTile(
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                title: Text(
                                  'Wallet',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                trailing: Icon(
                                  Icons.arrow_right,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                                onTap: () => showModalBottomSheet<void>(
                                  context: context,
                                  constraints: BoxConstraints(
                                    maxHeight:
                                        MediaQuery.of(context).size.height /
                                            3.2,
                                  ),
                                  builder: (context) {
                                    return Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            'Wallet',
                                            style: Theme.of(context)
                                                .textTheme
                                                .headlineMedium,
                                          ),
                                          const SizedBox(height: 15),
                                          OutlinedButton.icon(
                                            icon: const Icon(Icons.delete),
                                            onPressed: () {},
                                            label: Text(
                                              AppLocalizations.of(context)!
                                                  .delete,
                                            ),
                                          ),
                                          FilledButton.icon(
                                            onPressed: () => showDialog<void>(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  title: Text(
                                                    AppLocalizations.of(
                                                      context,
                                                    )!
                                                        .edit,
                                                  ),
                                                  icon: const Icon(Icons.edit),
                                                  content: InputField(
                                                    label: AppLocalizations.of(
                                                      context,
                                                    )!
                                                        .type(1),
                                                    placeholder: 'Wallet',
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                        context,
                                                      ),
                                                      child: Text(
                                                        AppLocalizations.of(
                                                          context,
                                                        )!
                                                            .cancel,
                                                      ),
                                                    ),
                                                    FilledButton.tonalIcon(
                                                      icon: const Icon(
                                                        Icons.done,
                                                      ),
                                                      onPressed: () {},
                                                      label: Text(
                                                        AppLocalizations.of(
                                                          context,
                                                        )!
                                                            .save,
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              },
                                            ),
                                            icon: const Icon(Icons.edit),
                                            label: Text(
                                              AppLocalizations.of(context)!
                                                  .edit,
                                            ),
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStatePropertyAll<
                                                      Color>(
                                                Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                              ),
                                              foregroundColor:
                                                  MaterialStatePropertyAll<
                                                      Color>(
                                                Colors.white.harmonizeWith(
                                                  Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const Divider(
                                            height: 24,
                                            thickness: 2,
                                          ),
                                          FilledButton.tonalIcon(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            icon: const Icon(Icons.arrow_back),
                                            label: Text(
                                              AppLocalizations.of(context)!
                                                  .back,
                                            ),
                                          )
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                              if (index == 2 - 1)
                                Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .outlineVariant,
                                ),
                            ],
                          );
                        },
                        separatorBuilder: (_, __) => Divider(
                          height: 1,
                          thickness: 1,
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
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
                      onPressed: () async {},
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
