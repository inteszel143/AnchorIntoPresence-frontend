import 'widgets/app_tab_bar.dart';

import 'package:flutter/material.dart';
import 'package:mindfully_evolve_app/common/widgets/buy_subscription_dialog.dart';

import '../screens/community/community_screen.dart';
import '../screens/meditate/meditate_screen.dart';
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
  final Set<int> _visited = {};

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _visited.add(_selectedIndex);
  }

  final List<Widget> _pages = [
    HomePage(),
    const MeditateScreen(),
    CommunityScreen(),
    TrackScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    if (globals.isSubscribed == true) {
      setState(() {
        _selectedIndex = index;
        _visited.add(index);
      });
    } else {
      if (index == 1 || index == 2 || index == 3) {
        // Keep the current tab selected when access requires a subscription.
        setState(() {});
        showSubscriptionDialog(context);
      } else {
        setState(() {
          _selectedIndex = index;
          _visited.add(index);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _selectedIndex,
        children: List.generate(
            _pages.length,
            (index) => _visited.contains(index)
                ? _pages[index]
                : const SizedBox.shrink()),
      ),
      bottomNavigationBar: AppTabBar(
        selectedIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
