import 'package:fhelper/src/views/head/home.dart';
import 'package:flutter/material.dart';

class HeadView extends StatefulWidget {
  const HeadView({super.key});

  @override
  State<HeadView> createState() => _HeadViewState();
}

class _HeadViewState extends State<HeadView> {
  final PageController _pageCtrl = PageController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: PreferredSize(
        preferredSize:
            Size(double.infinity, MediaQuery.of(context).size.height / 8),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                'Good Morning!',
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
        ],
      ),
      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.history), label: 'History'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
        onDestinationSelected: (dest) {
          _pageCtrl.animateToPage(
            dest,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInBack,
          );
        },
      ),
    );
  }
}
