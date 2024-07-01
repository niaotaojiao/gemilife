import 'dart:math';

class SlognsList {
  List<String> slogansList = [
    "Dream big, work hard, stay focused.",
    "Embrace the challenges, conquer the goals.",
    "Success begins with a single step.",
    "Turn obstacles into opportunities.",
    "Strive for progress, not perfection.",
    "Your only limit is you.",
    "Believe in yourself and all that you are.",
  ];

  String getSlogan() {
    return slogansList[Random().nextInt(slogansList.length)];
  }
}
