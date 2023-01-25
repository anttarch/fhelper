import 'package:fhelper/src/views/head/history.dart';
import 'package:fhelper/src/views/head/home.dart';
import 'package:flutter/material.dart';

class HeadView extends StatefulWidget {
  const HeadView({super.key});

  @override
  State<HeadView> createState() => _HeadViewState();
}

class _HeadViewState extends State<HeadView> {
  final PageController _pageCtrl = PageController();
  //final List<String> _homeTitle = ['Good Morning!', 'Good Afternoon!'];
  final List<String> _headline = [_getHomeString(), 'History', 'Settings'];

  static String _getHomeString() {
    final int hour = TimeOfDay.now().hour;
    switch (hour) {
      case 5:
      case 6:
      case 7:
      case 8:
      case 9:
      case 10:
      case 11:
        return 'Good Morning!';
      case 12:
      case 13:
      case 14:
      case 15:
      case 16:
      case 17:
        return 'Good Afternoon!';
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
        return 'Good Evening!';
      default:
        return 'Home';
    }
  }

  int? _pageIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: PreferredSize(
        preferredSize:
            Size(double.infinity, MediaQuery.of(context).size.height / 8),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                _headline[_pageIndex ?? 0],
                textAlign: TextAlign.start,
                style: Theme.of(context)
                    .textTheme
                    .displaySmall!
                    .apply(color: Theme.of(context).colorScheme.onBackground),
              ),
            ),
          ),
        ),
      ),
      body: PageView(
        controller: _pageCtrl,
        children: const [
          HomePage(),
          HistoryPage(),
        ],
        onPageChanged: (page) => setState(() {
          _pageIndex = page;
        }),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _pageIndex ?? 0,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.history), label: 'History'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
        onDestinationSelected: (dest) {
          _pageCtrl.animateToPage(
            dest,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
          );
        },
      ),
    );
  }
}