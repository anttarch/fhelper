import 'package:dynamic_color/dynamic_color.dart';
import 'package:fhelper/src/logic/collections/exchange.dart';
import 'package:fhelper/src/widgets/inputfield.dart';
import 'package:fhelper/src/widgets/sheetchoice.dart';
import 'package:flutter/material.dart';

class DetailsView extends StatefulWidget {
  const DetailsView({super.key, required this.item});
  final Exchange item;

  @override
  State<DetailsView> createState() => _DetailsViewState();
}

enum _IType { present, wage }

class _DetailsViewState extends State<DetailsView> {
  _IType _itype = _IType.present;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.background,
      child: SafeArea(
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
                        'Details',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: InputField(
                              label: 'Description',
                              placeholder: widget.item.description,
                              readOnly: true,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: InputField(
                              label: widget.item.value.isNegative
                                  ? 'Price'
                                  : 'Amount',
                              placeholder: widget.item.value.isNegative
                                  ? widget.item.value
                                      .toStringAsFixed(2)
                                      .replaceAll('-', r'-$')
                                  : r'+$' +
                                      widget.item.value.toStringAsFixed(2),
                              readOnly: true,
                              textColor: Color(
                                widget.item.value.isNegative
                                    ? 0xffbd1c1c
                                    : 0xff199225,
                              ).harmonizeWith(
                                Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: InputField(
                              label: 'Date',
                              readOnly: true,
                              onTap: () {},
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: InputField(
                              label: 'Type',
                              readOnly: true,
                              onTap: () => showModalBottomSheet<void>(
                                context: context,
                                constraints: BoxConstraints(
                                  maxHeight:
                                      MediaQuery.of(context).size.height / 2.5,
                                ),
                                enableDrag: false,
                                builder: (context) {
                                  return StatefulBuilder(
                                    builder: (context, setState) {
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(20),
                                            child: Text(
                                              'Select Type',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleLarge,
                                            ),
                                          ),
                                          SheetChoice<_IType>(
                                            groupValue: _itype,
                                            onChanged: (value) {
                                              setState(() {
                                                _itype = value!;
                                              });
                                            },
                                            items: const {
                                              'Present': _IType.present,
                                              'Wage': _IType.wage
                                            },
                                          )
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                          Visibility(
                            visible: widget.item.value.isNegative,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: InputField(
                                label: 'Card',
                                readOnly: true,
                                onTap: () => showModalBottomSheet<void>(
                                  context: context,
                                  constraints: BoxConstraints(
                                    maxHeight:
                                        MediaQuery.of(context).size.height /
                                            2.5,
                                  ),
                                  enableDrag: false,
                                  builder: (context) {
                                    return StatefulBuilder(
                                      builder: (context, setState) {
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.all(20),
                                              child: Text(
                                                'Select Card',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleLarge,
                                              ),
                                            ),
                                            SheetChoice<_IType>(
                                              groupValue: _itype,
                                              onChanged: (value) {
                                                setState(() {
                                                  _itype = value!;
                                                });
                                              },
                                              items: const {
                                                'Card 1': _IType.present,
                                                'Card 2': _IType.wage
                                              },
                                            )
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: InputField(
                              label: 'Account',
                              readOnly: true,
                              onTap: () => showModalBottomSheet<void>(
                                context: context,
                                constraints: BoxConstraints(
                                  maxHeight:
                                      MediaQuery.of(context).size.height / 2.5,
                                ),
                                enableDrag: false,
                                builder: (context) {
                                  return StatefulBuilder(
                                    builder: (context, setState) {
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(20),
                                            child: Text(
                                              'Select Account',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleLarge,
                                            ),
                                          ),
                                          SheetChoice<_IType>(
                                            groupValue: _itype,
                                            onChanged: (value) {
                                              setState(() {
                                                _itype = value!;
                                              });
                                            },
                                            items: const {
                                              'Wallet': _IType.present,
                                              'Bank': _IType.wage
                                            },
                                          )
                                        ],
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
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: FilledButton.tonalIcon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
