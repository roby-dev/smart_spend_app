import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_spend_app/features/shared/layouts/layout_1.dart';

class BottomNavLayout1 extends StatelessWidget {
  final Widget child;

  const BottomNavLayout1({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = location.startsWith('/archivadas') ? 1 : 0;

    return Layout1(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: child,
        bottomNavigationBar: SafeArea(
          top: false,
          child: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: (index) {
              if (index == 0) context.go('/home');
              if (index == 1) context.go('/archivadas');
            },
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
