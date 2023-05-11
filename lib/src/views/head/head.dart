import 'package:fhelper/src/views/add/add.dart';
import 'package:fhelper/src/views/head/history.dart';
import 'package:fhelper/src/views/head/home.dart';
import 'package:fhelper/src/views/head/settings.dart';
import 'package:fhelper/src/widgets/expandable_page_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HeadView extends StatefulWidget {
  const HeadView({super.key});

  @override
  State<HeadView> createState() => _HeadViewState();
}

class _HeadViewState extends State<HeadView> {
  final PageController _pageCtrl = PageController();
  static String _getHomeString(BuildContext context) {
    final int hour = TimeOfDay.now().hour;
    switch (hour) {
      case 5:
      case 6:
      case 7:
      case 8:
      case 9:
      case 10:
      case 11:
        return AppLocalizations.of(context)!.goodMorning;
      case 12:
      case 13:
      case 14:
      case 15:
      case 16:
      case 17:
        return AppLocalizations.of(context)!.goodAfternoon;
      case 18:
      case 19:
      case 20:
      case 21:
      case 22:
      case 23:
      case 0:
      case 1:
      case 2:
      case 3:
      case 4:
        return AppLocalizations.of(context)!.goodEvening;
      default:
        return AppLocalizations.of(context)!.home;
    }
  }

  int? _pageIndex;

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<String> headline = [
      _getHomeString(context),
      AppLocalizations.of(context)!.history,
      AppLocalizations.of(context)!.settings,
    ];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                headline[_pageIndex ?? 0],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: ExpandablePageView(
              controller: _pageCtrl,
              minHeight: MediaQuery.sizeOf(context).height - 256 - MediaQuery.paddingOf(context).bottom,
              children: const [
                HomePage(),
                HistoryPage(),
                SettingsPage(),
              ],
              onPageChanged: (page) => setState(() {
                _pageIndex = page;
              }),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute<AddView>(
            builder: (context) => const AddView(),
          ),
        ),
        label: Text(
          AppLocalizations.of(context)!.add,
          semanticsLabel: AppLocalizations.of(context)!.addTransactionFAB,
        ),
        icon: Icon(
          Icons.add,
          semanticLabel: _pageIndex == 0 ? null : AppLocalizations.of(context)!.addTransactionFAB,
        ),
        isExtended: _pageIndex == null || _pageIndex == 0,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _pageIndex ?? 0,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home),
            label: AppLocalizations.of(context)!.home,
          ),
          NavigationDestination(
            icon: const Icon(Icons.history),
            label: AppLocalizations.of(context)!.history,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings),
            label: AppLocalizations.of(context)!.settings,
          ),
        ],
        onDestinationSelected: (dest) {
          _pageCtrl.animateToPage(
            dest,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeIn,
          );
        },
      ),
    );
  }
}
