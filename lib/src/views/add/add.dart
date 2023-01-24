import 'package:fhelper/src/widgets/inputfield.dart';
import 'package:fhelper/src/widgets/sheetchoice.dart';
import 'package:flutter/material.dart';

class AddView extends StatefulWidget {
  const AddView({super.key});

  @override
  State<AddView> createState() => _AddViewState();
}

enum _Type { income, expense }

enum _IType { present, wage }

class _AddViewState extends State<AddView> {
  Set<_Type> _type = {_Type.income};
  _IType _itype = _IType.present;
  final PageController _pageCtrl = PageController();
  final Map<_Type, int> _indexMap = {
    _Type.income: 0,
    _Type.expense: 1,
  };

  // `_getPageHeight()` and `_allowNicerLayout()` are hard coded functions
  // Some kind of hack to allow resizing of the view
  // They NEED TO BE UPDATED on every change of the widget tree
  // `availableHeight` represents the screen size available for the pageview
  // `treeHeight` represents the total height of widgets that need to be rendered

  double _getPageHeight() {
    final double availableHeight = MediaQuery.of(context).size.height -
        172 -
        MediaQuery.of(context).padding.bottom -
        MediaQuery.of(context).padding.top;
    const double treeHeight = 572;
    if (availableHeight > treeHeight) {
      return availableHeight;
    } else {
      return treeHeight;
    }
  }

  double _allowNicerLayout() {
    final double availableHeight = MediaQuery.of(context).size.height -
        172 -
        MediaQuery.of(context).padding.bottom -
        MediaQuery.of(context).padding.top;
    const double treeHeight = 572;
    if (availableHeight - treeHeight > 88) {
      return availableHeight - treeHeight;
    } else {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.background,
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar.medium(
              title: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  'Add',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                color: Theme.of(context).colorScheme.background,
                child: SegmentedButton(
                  segments: const [
                    ButtonSegment(
                      value: _Type.income,
                      label: Text('Income'),
                    ),
                    ButtonSegment(
                      value: _Type.expense,
                      label: Text('Expense'),
                    ),
                  ],
                  selected: _type,
                  onSelectionChanged: (p0) {
                    setState(() {
                      _type = p0;
                    });
                    _pageCtrl.animateToPage(
                      _indexMap.entries
                          .firstWhere((e) => e.key == p0.single)
                          .value,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: _getPageHeight(),
                width: MediaQuery.of(context).size.width,
                child: PageView(
                  controller: _pageCtrl,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 24),
                            child: InputField(label: 'Description'),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(top: 20),
                            child: InputField(label: 'Amount'),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: InputField(
                              label: 'Date',
                              readOnly: true,
                              onTap: () async {
                                final DateTime? _picked = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(DateTime.now().year),
                                  lastDate: DateTime(DateTime.now().year + 1),
                                );
                              },
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
                          Padding(
                            padding: EdgeInsets.only(
                              top: 20 + _allowNicerLayout(),
                              bottom: 20,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel'),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: FilledButton.icon(
                                    onPressed: () {},
                                    icon: const Icon(Icons.add),
                                    label: const Text('Add'),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      color: Colors.indigo,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
