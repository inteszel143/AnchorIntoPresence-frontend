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
  final int? initialIndex;

  const MainScreen({super.key, this.initialIndex});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _selectedIndex;
  final Set<int> _visited = {};

  @override
  void initState() {
    super.initState();
    _selectedIndex = (widget.initialIndex ?? 0).clamp(0, _pages.length - 1);
    _visited.add(_selectedIndex);
  }

  List<Widget> get _pages => [
        HomePage(onMeditate: () => _onItemTapped(1)),
        const MeditateScreen(),
        CommunityScreen(),
        TrackScreen(),
        const ProfileScreen(),
      ];

  void _onItemTapped(int index) {
    if (index < 0 || index >= _pages.length) return;
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
    final pages = _pages;
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _selectedIndex,
        children: List.generate(
            pages.length,
            (index) => _visited.contains(index)
                ? pages[index]
                : const SizedBox.shrink()),
      ),
      bottomNavigationBar: AppTabBar(
        selectedIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
