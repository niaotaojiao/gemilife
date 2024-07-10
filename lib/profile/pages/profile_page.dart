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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(children: [
                  Card(
                    color: Colors.blue[900],
                    child: Column(
                      children: [
                        Container(
                          alignment: Alignment.topRight,
                          child: IconButton(
                              onPressed: signUserOut,
                              icon: const Icon(Icons.logout,
                                  color: Colors.white)),
                        ),
                        const Icon(
                          Icons.account_circle,
                          size: 200,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 10),
                        // user name
                        Center(
                          child: Text(
                            username,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 32),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: ListTile(
                                title: Text('Record',
                                    style: TextStyle(color: Colors.grey[300])),
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
                                title: Text('Time (m)',
                                    style: TextStyle(color: Colors.grey[300])),
                                subtitle: Container(
                                  alignment: Alignment.center,
                                  child: Text('$time',
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 32)),
                                ),
                              ),
                            ),
                            Expanded(
                              child: ListTile(
                                title: Text(
                                  'Activity',
                                  style: TextStyle(color: Colors.grey[300]),
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
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),

                  // achievements coding here!!
                  const SizedBox(height: 10),
                  MyCard(
                      title: 'Starter Sprinter',
                      description: 'Complete your first exercise session.',
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
                ]),
        ),
      ),
    );
  }
}
