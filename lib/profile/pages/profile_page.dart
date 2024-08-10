import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gemilife/profile/widgets/my_card.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int activityCount = 0;
  int logCount = 0;
  int time = 0;
  String username = 'username';
  bool isLoading = true;

  Future getUserData() async {
    final currentUser = FirebaseAuth.instance.currentUser?.email;
    final user = await FirebaseFirestore.instance
        .collection(currentUser!)
        .doc('account')
        .get();

    setState(() {
      activityCount = user['activity_count'];
      logCount = user['log_count'];
      username = user['username'];
      time = user['time'];
      isLoading = false;
    });
  }

  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.only(
                            top: 45.0, left: 20.0, right: 20.0),
                        height: MediaQuery.of(context).size.height / 4.3,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.vertical(
                                bottom: Radius.elliptical(
                                    MediaQuery.of(context).size.width, 105.0))),
                      ),
                      Center(
                        child: Container(
                          margin: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height / 6.5),
                          child: Material(
                              color: Colors.white,
                              elevation: 10.0,
                              borderRadius: BorderRadius.circular(60),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(60),
                                child: Icon(
                                  Icons.person,
                                  size: 120,
                                  color: Colors.blue[800],
                                ),
                              )),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 70.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              username,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 70.0),
                        child: Container(
                          alignment: Alignment.topRight,
                          child: IconButton(
                              onPressed: signUserOut,
                              icon: const Icon(Icons.logout,
                                  color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Welcome!',
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                        Card(
                          color: Colors.amber[50],
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Start your day',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w800),
                                    ),
                                    Text(
                                        'Track, improve, and elevate your daily life'),
                                  ],
                                ),
                                Image.asset(
                                  'assets/img/ai-technology.png',
                                  height: 64,
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Overview',
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                        Card(
                          color: Colors.amber[800],
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: ListTile(
                                  title: Text('Record',
                                      style:
                                          TextStyle(color: Colors.grey[100])),
                                  subtitle: Container(
                                    alignment: Alignment.center,
                                    child: Text('$logCount',
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 32)),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: ListTile(
                                  title: Text('Meditation',
                                      style:
                                          TextStyle(color: Colors.grey[100])),
                                  subtitle: Container(
                                    alignment: Alignment.center,
                                    child: Text('$time m',
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 32)),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: ListTile(
                                  title: Text(
                                    'Activity',
                                    style: TextStyle(color: Colors.grey[100]),
                                  ),
                                  subtitle: Container(
                                    alignment: Alignment.center,
                                    child: Text('$activityCount',
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 32)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Achievements',
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                        MyCard(
                            title: 'Starter Sprinter',
                            description:
                                'Complete your first exercise session.',
                            currentCont: activityCount,
                            targetCont: 1),
                        MyCard(
                            title: 'Decathlete',
                            description: 'Exercise ten times.',
                            currentCont: activityCount,
                            targetCont: 10),
                        MyCard(
                            title: 'Half Century Hero',
                            description: 'Exercise fifty times.',
                            currentCont: activityCount,
                            targetCont: 50),
                        MyCard(
                            title: 'Century Conqueror',
                            description: 'Exercise one hundred times.',
                            currentCont: activityCount,
                            targetCont: 100),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
