import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gemilife/home/widgets/calendar_widget.dart';
import 'package:gemilife/home/pages/add_event_page.dart';
import 'package:gemilife/home/pages/edit_event_page.dart';
import 'package:gemilife/home/services/event.dart';
import 'package:table_calendar/table_calendar.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  DateTime _today = DateTime.now();
  DateTime? _selectedDay;
  late Map<DateTime, List<Event>> _events;
  String username = 'Username';

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _today = focusedDay;
    });
  }

  void _onPageChanged(DateTime focusedDay) {
    setState(() {
      _today.day == 31
          ? _today = DateTime(focusedDay.year, focusedDay.month, 30)
          : _today = DateTime(focusedDay.year, focusedDay.month, _today.day);
    });
  }

  List<Event> _getEventsForTheDay(DateTime day) {
    return _events[day] ?? [];
  }

  int _getHashCode(DateTime key) {
    return key.day * 1000000 + key.month * 10000 + key.year;
  }

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.utc(_today.year, _today.month, _today.day, 0);
    _events = LinkedHashMap(equals: isSameDay, hashCode: _getHashCode);
    _loadFirestoreEvents();
    getUserName();
  }

  _loadFirestoreEvents() async {
    _events = {};
    final currentUser = FirebaseAuth.instance.currentUser?.email;
    final snap = await FirebaseFirestore.instance
        .collection(currentUser!)
        .doc('eventlist')
        .collection('events')
        .withConverter(
            fromFirestore: Event.fromFirestore,
            toFirestore: (event, options) => event.toFirestore())
        .get();

    for (var doc in snap.docs) {
      final event = doc.data();
      final day =
          DateTime.utc(event.date.year, event.date.month, event.date.day);
      if (_events[day] == null) {
        _events[day] = [];
      }
      _events[day]!.add(event);
    }
    setState(() {});
  }

  void getUserName() async {
    final currentUser = FirebaseAuth.instance.currentUser?.email;
    final snap = await FirebaseFirestore.instance
        .collection(currentUser!)
        .doc('account')
        .get();

    setState(() {
      username = snap['username'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          color: const Color(0xFFF5F8FD),
          child: ListView(
            children: [
              Container(
                decoration: BoxDecoration(color: Colors.white, boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 0.2,
                    blurRadius: 2,
                    offset: const Offset(0, 2),
                  )
                ]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Hello $username,',
                                style: const TextStyle(
                                  fontSize: 24.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              Icon(Icons.settings_outlined)
                            ],
                          ),
                          const SizedBox(height: 20.0),
                          const Text(
                            'Daily Moments',
                            style: TextStyle(
                              fontSize: 28.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const Text(
                            'Reflect on each day with Gemini',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w400,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    CalendarWidget(
                      today: _selectedDay!,
                      onDaySelected: _onDaySelected,
                      onPageChanged: _onPageChanged,
                      getEventsForTheDay: _getEventsForTheDay,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Your life today',
                            style: TextStyle(
                                fontSize: 24.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87)),
                        IconButton(
                          icon: const Icon(
                            Icons.edit_outlined,
                            size: 28,
                          ),
                          onPressed: () async {
                            final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => AddEvent(
                                          today: _today,
                                        )));
                            if (result ?? false) {
                              _loadFirestoreEvents();
                            }
                          },
                        )
                      ],
                    ),
                    if (_events[_selectedDay] == null)
                      const Card(
                        elevation: 2.0,
                        child: ListTile(
                          leading: Icon(
                            Icons.edit_calendar,
                            size: 40,
                          ),
                          title: Text('No events for today',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          subtitle: Text(
                              'Start by adding new events to document your life.'),
                        ),
                      )
                    else
                      ..._getEventsForTheDay(_selectedDay!).map((event) => Card(
                            elevation: 2.0,
                            child: ListTile(
                              leading: const Icon(
                                Icons.album,
                                color: Colors.deepOrange,
                                size: 40,
                              ),
                              title: Text(
                                event.title,
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                event.description!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: IconButton(
                                  onPressed: () async {
                                    final currentUser = FirebaseAuth
                                        .instance.currentUser?.email;
                                    await FirebaseFirestore.instance
                                        .collection(currentUser!)
                                        .doc('eventlist')
                                        .collection('events')
                                        .doc(event.id)
                                        .delete();
                                    _loadFirestoreEvents();

                                    await FirebaseFirestore.instance
                                        .collection(currentUser)
                                        .doc('account')
                                        .update({
                                      "log_count": FieldValue.increment(-1),
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.red,
                                  )),
                              onTap: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => EditEvent(
                                      event: event,
                                      today: _selectedDay!,
                                      title: event.title,
                                      description: event.description,
                                    ),
                                  ),
                                );
                                if (result ?? false) {
                                  _loadFirestoreEvents();
                                }
                              },
                            ),
                          )),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset('assets/img/ai-technology.png',
                            width: 50, height: 50),
                        const SizedBox(
                          width: 12,
                        ),
                        const Expanded(
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.zero,
                                topRight: Radius.circular(12.0),
                                bottomRight: Radius.circular(12.0),
                                bottomLeft: Radius.circular(12.0),
                              ),
                            ),
                            elevation: 2.0,
                            child: Padding(
                                padding: EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Gemilife Assistant',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                        'Start by adding new events to document your life.')
                                  ],
                                )),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
