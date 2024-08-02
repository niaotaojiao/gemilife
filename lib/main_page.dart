import 'package:flutter/material.dart';
import 'package:gemilife/review/pages/review.dart';
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
    const Review(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: _pages[_selectedIndex],
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: Colors.grey, width: 0.5), // 分隔線
            ),
          ),
          child: GNav(
            backgroundColor: Colors.white,
            selectedIndex: _selectedIndex,
            onTabChange: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            gap: 8,
            color: Colors.grey,
            activeColor: Colors.black,
            tabs: const [
              GButton(
                icon: Icons.home,
                text: 'Home',
              ),
              GButton(
                icon: Icons.timer,
                text: 'Timer',
              ),
              GButton(
                icon: Icons.sports_gymnastics,
                text: 'Sports',
              ),
              GButton(
                icon: Icons.assessment,
                text: 'Review',
              ),
              GButton(
                icon: Icons.person,
                text: 'Profile',
              ),
            ],
          ),
        ));
  }
}
