import 'package:flutter/material.dart';
import 'package:gemilife/sports/widgets/my_list_tile.dart';

class SportsListPage extends StatefulWidget {
  const SportsListPage({super.key});

  @override
  State<SportsListPage> createState() => _SportsListPageState();
}

class _SportsListPageState extends State<SportsListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FD),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
          child: ListView(
            children: [
              RichText(
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  children: [
                    TextSpan(text: 'Get Fit!\n'),
                    TextSpan(text: 'Stay Balanced'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Card(
                  child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/img/sports.png',
                ),
              )),
              const SizedBox(height: 20),
              // Sports list
              const Text(
                'Move your body',
                style: TextStyle(
                    fontSize: 24,
                    color: Colors.black87,
                    fontWeight: FontWeight.bold),
              ),
              const MyListTile(
                name: 'Push-up',
                imgPath: 'assets/img/push-up.png',
                sportOrYoga: true,
              ),
              const MyListTile(
                name: 'Sit-up',
                imgPath: 'assets/img/sit-up.png',
                sportOrYoga: true,
              ),
              const MyListTile(
                name: 'Squat',
                imgPath: 'assets/img/squat.png',
                sportOrYoga: true,
              ),
              const SizedBox(height: 16),
              // Yoga list
              const Text(
                'Find your balance',
                style: TextStyle(
                    fontSize: 24,
                    color: Colors.black87,
                    fontWeight: FontWeight.bold),
              ),
              const MyListTile(
                name: 'Warrior-1',
                imgPath: 'assets/img/warrior-1.png',
                sportOrYoga: false,
              ),
              const MyListTile(
                name: 'Warrior-2',
                imgPath: 'assets/img/warrior-2.png',
                sportOrYoga: false,
              ),
              const MyListTile(
                name: 'Tree Pose',
                imgPath: 'assets/img/tree-pose.png',
                sportOrYoga: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
