import 'package:flutter/material.dart';
import 'package:mindfully_evolve_app/common/widgets/buy_subscription_dialog.dart';
import 'package:mindfully_evolve_app/common/widgets/custom_bottombar.dart';

import '../screens/community/community_screen.dart';
import '../screens/dashboard/home_screen.dart';
import '../screens/setting/setting_screen.dart';
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
      bottomNavigationBar: CustomBottomBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
