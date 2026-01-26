import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'home_screen.dart';
import 'jobs_screen.dart';
import 'active_profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;
  const MainNavigationScreen({super.key, this.initialIndex = 0});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _currentIndex;

  final List<Widget> _pages = [
    const HomeScreen(),
    const JobsScreen(),
    const Center(child: Text('Orders Screen Placeholder')), // Index 2
    const ActiveProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: CurvedNavigationBar(
        color: const Color(0xFF000000),
        backgroundColor: Colors.transparent,
        buttonBackgroundColor: const Color(0xFF000000),
        height: 60,
        animationDuration: const Duration(milliseconds: 300),
        animationCurve: Curves.easeInOutCubic,
        index: _currentIndex,
        onTap: (index) {
          if (index != 2) { // Allow navigation to Home, Jobs, Profile
            setState(() {
              _currentIndex = index;
            });
          }
        },
        items: [
          Icon(Icons.home, size: 28, color: _currentIndex == 0 ? Colors.white : Colors.white60),
          Icon(Icons.print, size: 28, color: _currentIndex == 1 ? Colors.white : Colors.white60),
          Icon(Icons.description, size: 28, color: _currentIndex == 2 ? Colors.white : Colors.white60),
          Icon(Icons.person, size: 28, color: _currentIndex == 3 ? Colors.white : Colors.white60),
        ],
      ),
    );
  }
}
