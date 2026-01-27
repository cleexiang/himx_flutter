import 'package:flutter/material.dart';
import '../theme/starry_theme.dart';
import 'tabs/home_discover_tab.dart';
import 'tabs/home_roles_tab.dart';
import 'tabs/home_community_tab.dart';
import 'tabs/home_profile_tab.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentTabIndex = 0;

  // 使用 IndexedStack 保持 Tab 状态
  final List<Widget> _tabs = const [
    HomeDiscoverTab(),
    HomeRolesTab(),
    HomeCommunityTab(),
    HomeProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: IndexedStack(
          index: _currentTabIndex,
          children: _tabs,
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)],
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentTabIndex,
          onTap: (index) {
            setState(() {
              _currentTabIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: StarryTheme.accentPink,
          unselectedItemColor: Colors.white54,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_filled, size: 28), label: 'Discover'),
            BottomNavigationBarItem(icon: Icon(Icons.chat_bubble, size: 28), label: 'My Dates'),
            BottomNavigationBarItem(icon: Icon(Icons.explore, size: 28), label: 'Community'),
            BottomNavigationBarItem(icon: Icon(Icons.person, size: 28), label: 'Profile'),
          ],
        ),
      ),
      extendBody: true,
    );
  }
}
