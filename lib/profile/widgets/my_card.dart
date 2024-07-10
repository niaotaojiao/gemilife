import 'package:flutter/material.dart';

class MyCard extends StatelessWidget {
  final String title;
  final String description;
  final int currentCont;
  final int targetCont;
  const MyCard(
      {super.key,
      required this.title,
      required this.description,
      required this.currentCont,
      required this.targetCont});

  @override
  Widget build(BuildContext context) {
    return currentCont >= targetCont
        ? Card(
            color: Colors.blue[900],
            child: ListTile(
              leading: Image.asset('assets/img/$title.png'),
              title: Text(title, style: const TextStyle(color: Colors.white)),
              subtitle: Text(description,
                  style: const TextStyle(color: Colors.white)),
              trailing: const Icon(Icons.check, color: Colors.white),
            ))
        : Card(
            color: Colors.grey,
            child: ListTile(
              leading: Image.asset('assets/img/${title}nn.png'),
              title: Text(
                title,
              ),
              subtitle: Text(description),
              trailing: const Icon(Icons.lock),
            ));
  }
}
