import 'package:flutter/material.dart';
import 'package:gemilife/sports/components/my_list_tile.dart';

class SportsListPage extends StatefulWidget {
  const SportsListPage({super.key});

  @override
  State<SportsListPage> createState() => _SportsListPageState();
}

class _SportsListPageState extends State<SportsListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            Card(child: Image.asset('assets/img/sports.png')),
            Text(
              'Sports',
              style: TextStyle(fontSize: 20, color: Colors.blue[900]),
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
            Text(
              'Yoga',
              style: TextStyle(fontSize: 20, color: Colors.blue[900]),
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
    );
  }
}
