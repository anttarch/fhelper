import 'package:fhelper/src/widgets/inputfield.dart';
import 'package:flutter/material.dart';

class AddView extends StatefulWidget {
  const AddView({super.key});

  @override
  State<AddView> createState() => _AddViewState();
}

enum _Type { income, expense }

class _AddViewState extends State<AddView> {
  Set<_Type> _type = {_Type.income};
  final PageController _pageCtrl = PageController();
  final Map<_Type, int> _indexMap = {
    _Type.income: 0,
    _Type.expense: 1,
  };

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
                height: MediaQuery.of(context).size.height -
                    172 -
                    MediaQuery.of(context).padding.bottom -
                    MediaQuery.of(context).padding.top,
                width: MediaQuery.of(context).size.width,
                child: PageView(
                  controller: _pageCtrl,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: const [
                          Padding(
                            padding: EdgeInsets.only(top: 24),
                            child: InputField(label: 'Description'),
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
