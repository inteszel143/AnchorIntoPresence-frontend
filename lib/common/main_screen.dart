import 'package:mindfully_evolve_app/common/widgets/app_scaffold.dart';
import 'widgets/app_tab_bar.dart';
import 'widgets/membership_banner.dart';

import 'package:flutter/material.dart';
import 'widgets/subscription_tab_page.dart';
import '../screens/subscriptionmanagement/subscription_management.dart';

import '../screens/community/community_screen.dart';
import '../screens/meditate/meditate_screen.dart';
import '../screens/dashboard/home_screen.dart';
import '../screens/setting/setting_screen.dart';
import '../screens/track/track_screen.dart';
import '../utils/global.dart' as globals;

class MainScreen extends StatefulWidget {
  final int? initialIndex;

  const MainScreen({super.key, this.initialIndex});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final Set<int> _visited = {};
  bool _membershipBannerDismissed = false;

  @override
  void initState() {
    super.initState();
    _selectedIndex = (widget.initialIndex ?? 0).clamp(0, _pages.length - 1);
    _visited.add(_selectedIndex);
  }

  List<Widget> get _pages => [
        HomePage(onLibrary: () => _onItemTapped(1)),
        const MeditateScreen(),
        CommunityScreen(),
        TrackScreen(isActive: _selectedIndex == 3),
        SettingScreen(isTab: true),
      ];

  void _onItemTapped(int index) {
    if (index < 0 || index >= _pages.length) return;
    setState(() {
      _selectedIndex = index;
      _visited.add(index);
    });
  }

  Future<void> _openSubscriptionPlans() async {
    await Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => const SubscriptionManagementScreen(isSubscribed: false),
    ));
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final pages = _pages;
    return AppScaffold(
      extendBody: true,
      body: IndexedStack(
        index: _selectedIndex,
        children: List.generate(
            pages.length,
            (index) => _visited.contains(index)
                ? (index < 4 && !globals.isSubscribed
                    ? SubscriptionTabPage(
                        tabIndex: index,
                        onSubscribe: _openSubscriptionPlans,
                      )
                    : pages[index])
                : const SizedBox.shrink()),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!globals.isSubscribed && !_membershipBannerDismissed)
            MembershipBanner(
              onExplore: _openSubscriptionPlans,
              onDismiss: () =>
                  setState(() => _membershipBannerDismissed = true),
            ),
          AppTabBar(
            selectedIndex: _selectedIndex,
            onTap: _onItemTapped,
          ),
        ],
      ),
    );
  }
}
