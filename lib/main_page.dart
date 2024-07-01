import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

import 'profile/pages/profile_page.dart';
import 'home/pages/home_page.dart';
import 'timer/pages/timer_page.dart';
import 'sports/pages/sports_list_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const Home(),
    const TimerPage(),
    const SportsListPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: _pages[_selectedIndex],
        bottomNavigationBar: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(15.0),
            topRight: Radius.circular(15.0),
          ),
          child: GNav(
            backgroundColor: Colors.blue[900]!,
            selectedIndex: _selectedIndex,
            onTabChange: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            gap: 8,
            tabs: const [
              GButton(
                icon: Icons.home,
                text: 'Home',
                iconColor: Colors.white,
                iconActiveColor: Colors.white,
                textColor: Colors.white,
              ),
              GButton(
                icon: Icons.timer,
                text: 'Timer',
                iconColor: Colors.white,
                iconActiveColor: Colors.white,
                textColor: Colors.white,
              ),
              GButton(
                icon: Icons.sports_gymnastics,
                text: 'Sports',
                iconColor: Colors.white,
                iconActiveColor: Colors.white,
                textColor: Colors.white,
              ),
              GButton(
                icon: Icons.person,
                text: 'Profile',
                iconColor: Colors.white,
                iconActiveColor: Colors.white,
                textColor: Colors.white,
              ),
            ],
          ),
        ));
  }
}
