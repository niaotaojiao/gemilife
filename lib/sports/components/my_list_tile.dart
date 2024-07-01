import 'package:flutter/material.dart';
import 'package:gemilife/sports/pages/pose_detector_page.dart';
import 'package:gemilife/sports/pages/yoga_detector_page.dart';

class MyListTile extends StatelessWidget {
  final String name;
  final String imgPath;
  final bool sportOrYoga; // bool? sport: yoga;

  const MyListTile({
    super.key,
    required this.name,
    required this.imgPath,
    required this.sportOrYoga,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Image.asset(imgPath),
        title: Text(name),
        trailing: const Icon(
          Icons.chevron_right,
        ),
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => sportOrYoga
                      ? PoseDetectorPage(
                          name: name,
                        )
                      : YogaDetectorPage(
                          name: name,
                        )));
        },
      ),
    );
  }
}
