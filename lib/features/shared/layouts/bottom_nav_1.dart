import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_spend_app/features/compras_archivadas/screens/compras_archivadas_screen.dart';
import 'package:smart_spend_app/features/home/screens/home_screen.dart';
import 'package:smart_spend_app/features/shared/layouts/layout_1.dart';

class BottomNavLayout1 extends StatefulWidget {
  const BottomNavLayout1({super.key, required this.child});

  final Widget child;

  @override
  State<BottomNavLayout1> createState() => _BottomNavLayout1State();
}

class _BottomNavLayout1State extends State<BottomNavLayout1> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<String> _routes = ['/home', '/archivadas'];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final uri = GoRouterState.of(context).uri;
    final location = uri.toString();
    final pageIndex = _routes.indexWhere((r) => location.startsWith(r));
    if (pageIndex != -1 && pageIndex != _currentIndex) {
      _currentIndex = pageIndex;
      _pageController.jumpToPage(pageIndex);
    }
  }

  void _onPageChanged(int index) {
    if (index != _currentIndex) {
      setState(() => _currentIndex = index);
      context.go(_routes[index]);
    }
  }

  void _onTabTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Layout1(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: PageView(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          children: const [
            HomeScreen(),
            ComprasArchivadasScreen(),
          ],
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onTabTapped,
            selectedItemColor: Colors.black,
            unselectedItemColor: Colors.grey,
            backgroundColor: Colors.transparent,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.list_alt_outlined),
                label: 'Compras',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.archive_outlined),
                label: 'Archivadas',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
