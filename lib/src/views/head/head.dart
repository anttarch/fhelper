import 'package:animations/animations.dart';
import 'package:fhelper/src/views/add/add.dart';
import 'package:fhelper/src/views/head/history.dart';
import 'package:fhelper/src/views/head/home.dart';
import 'package:fhelper/src/views/head/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HeadView extends StatefulWidget {
  const HeadView({super.key});

  @override
  State<HeadView> createState() => _HeadViewState();
}

class _HeadViewState extends State<HeadView> {
  final ScrollController _scrollCtrl = ScrollController();
  final List<Widget> pages = [
    const HomePage(),
    const HistoryPage(),
    const SettingsPage(),
  ];

  int _pageIndex = 0;
  bool displayNavigationBar = true;

  static String _getHomeString(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final hour = TimeOfDay.now().hour;
    switch (hour) {
      case >= 5 && <= 11:
        return localization.goodMorning;
      case >= 12 && <= 17:
        return localization.goodAfternoon;
      case >= 0 && <= 4 || >= 18 && <= 23:
        return localization.goodEvening;
      default:
        return localization.home;
    }
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final headline = <String>[
      _getHomeString(context),
      localization.history,
      localization.settings,
    ];

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollCtrl,
        slivers: [
          SliverAppBar(
            centerTitle: true,
            title: const Text('FHelper'),
            actions: [
              SearchAnchor(
                builder: (context, controller) {
                  return IconButton(
                    onPressed: () => controller.openView(),
                    icon: const Icon(Icons.search),
                  );
                },
                suggestionsBuilder: (context, controller) {
                  // TODO(antarch): populate
                  return [];
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: PageTransitionSwitcher(
              transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
                return FadeThroughTransition(
                  animation: primaryAnimation,
                  secondaryAnimation: secondaryAnimation,
                  child: child,
                );
              },
              layoutBuilder: (entries) {
                return Stack(
                  alignment: Alignment.topCenter,
                  children: entries,
                );
              },
              child: pages[_pageIndex],
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
          localization.add,
          semanticsLabel: localization.addTransactionFAB,
        ),
        icon: Icon(
          Icons.add,
          semanticLabel:
              _pageIndex == 0 ? null : localization.addTransactionFAB,
        ),
        isExtended: _pageIndex == 0,
        extendedPadding: _pageIndex == 0
            ? null
            : const EdgeInsetsDirectional.only(start: 16, end: 16),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _pageIndex,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home),
            label: localization.home,
          ),
          NavigationDestination(
            icon: const Icon(Icons.history),
            label: localization.history,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings),
            label: localization.settings,
          ),
        ],
        onDestinationSelected: (dest) {
          setState(() => _pageIndex = dest);
          _scrollCtrl.animateTo(
            0,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeInOut,
          );
        },
      ),
    );
  }
}
