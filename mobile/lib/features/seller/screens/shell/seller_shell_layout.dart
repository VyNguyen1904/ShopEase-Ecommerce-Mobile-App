import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'seller_app_bottom_nav.dart';

class SellerShellLayout extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const SellerShellLayout({super.key, required this.navigationShell});

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: SellerAppBottomNav(
        currentIndex: navigationShell.currentIndex,
        onTap: _onTap,
      ),
    );
  }
}
