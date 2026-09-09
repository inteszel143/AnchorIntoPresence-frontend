import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';

import 'package:flutter/material.dart';
import 'package:mindfully_evolve_app/common/widgets/buy_subscription_dialog.dart';

import '../screens/community/community_screen.dart';
import '../screens/dashboard/home_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/track/track_screen.dart';
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
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    if (globals.isSubscribed == true) {
      setState(() {
        _selectedIndex = index;
      });
    } else {
      if (index == 1 || index == 2) {
        // Rebuild so the native tab bar restores the permitted selection.
        setState(() {});
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
    final nativeIcons = PlatformInfo.isIOS26OrHigher();
    return AdaptiveScaffold(
      minimizeBehavior: TabBarMinimizeBehavior.never,
      // The native bar overlays its body; reserve room for page controls.
      body: Padding(
        padding: EdgeInsets.only(bottom: nativeIcons ? 64 : 0),
        child: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
      ),
      bottomNavigationBar: AdaptiveBottomNavigationBar(
        useNativeBottomBar: true,
        selectedIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          AdaptiveNavigationDestination(
            icon: nativeIcons ? 'house.fill' : Icons.home_rounded,
            label: 'Home',
          ),
          AdaptiveNavigationDestination(
            icon: nativeIcons ? 'person.3.fill' : Icons.groups_rounded,
            label: 'Community',
          ),
          AdaptiveNavigationDestination(
            icon: nativeIcons ? 'chart.xyaxis.line' : Icons.insights_rounded,
            label: 'Track',
          ),
          AdaptiveNavigationDestination(
            icon: nativeIcons ? 'person.fill' : Icons.person_rounded,
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
