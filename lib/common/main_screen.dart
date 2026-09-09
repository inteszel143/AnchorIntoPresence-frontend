import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mindfully_evolve_app/common/widgets/buy_subscription_dialog.dart';

import '../screens/community/community_screen.dart';
import '../screens/dashboard/home_screen.dart';
import '../screens/setting/setting_screen.dart';
import '../screens/track/track_screen.dart';
import '../utils/color_constants.dart';
import '../utils/global.dart' as globals;

class MainScreen extends StatefulWidget {
  final int initialIndex;

  const MainScreen({super.key, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  final List<Widget> _pages = [
    HomePage(),
    CommunityScreen(),
    TrackScreen(),
    SettingScreen(),
  ];

  void _onItemTapped(int index) {
    if (globals.isSubscribed == true) {
      setState(() {
        _selectedIndex = index;
      });
    } else {
      if (index == 1 || index == 2) {
        showSubscriptionDialog(context);
      } else {
        setState(() {
          _selectedIndex = index;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(12, 0, 12, 10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withValues(alpha: 0.72)
                    : ColorCodes.backgroundcolor.withValues(alpha: 0.78),
                border: Border.all(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.12),
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: NavigationBar(
                selectedIndex: _selectedIndex,
                onDestinationSelected: _onItemTapped,
                height: 76,
                backgroundColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                indicatorColor: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.16),
                elevation: 0,
                destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_rounded),
                selectedIcon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.groups_rounded),
                selectedIcon: Icon(Icons.groups_rounded),
                label: 'Community',
              ),
              NavigationDestination(
                icon: Icon(Icons.insights_rounded),
                selectedIcon: Icon(Icons.insights_rounded),
                label: 'Track',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_rounded),
                selectedIcon: Icon(Icons.person_rounded),
                label: 'Profile',
              ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
