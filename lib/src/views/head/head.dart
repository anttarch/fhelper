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
    final int hour = TimeOfDay.now().hour;
    switch (hour) {
      case >= 5 && <= 11:
        return AppLocalizations.of(context)!.goodMorning;
      case >= 12 && <= 17:
        return AppLocalizations.of(context)!.goodAfternoon;
      case >= 0 && <= 4 || >= 18 && <= 23:
        return AppLocalizations.of(context)!.goodEvening;
      default:
        return AppLocalizations.of(context)!.home;
    }
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
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
        controller: _scrollCtrl,
        slivers: [
          SliverAppBar.large(
            title: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                headline[_pageIndex],
              ),
            ),
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
          AppLocalizations.of(context)!.add,
          semanticsLabel: AppLocalizations.of(context)!.addTransactionFAB,
        ),
        icon: Icon(
          Icons.add,
          semanticLabel: _pageIndex == 0 ? null : AppLocalizations.of(context)!.addTransactionFAB,
        ),
        isExtended: _pageIndex == 0,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _pageIndex,
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
