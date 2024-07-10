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
  bool _eventsLoaded = false;
  late Map<DateTime, List<Event>> _events;

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
    setState(() {
      _eventsLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${_today.year.toString()}/${_today.month.toString()}/${_today.day.toString()}',
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue[900],
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _eventsLoaded
            ? ListView(
                children: [
                  CalendarWidget(
                    today: _selectedDay!,
                    onDaySelected: _onDaySelected,
                    onPageChanged: _onPageChanged,
                    getEventsForTheDay: _getEventsForTheDay,
                  ),
                  Divider(
                    height: 2,
                    color: Colors.red[100],
                  ),
                  const SizedBox(height: 10),
                  ..._getEventsForTheDay(_selectedDay!).map((event) => Card(
                        child: ListTile(
                          title: Text(
                            event.title,
                          ),
                          subtitle: Text(
                            event.description!,
                          ),
                          trailing:
                              Row(mainAxisSize: MainAxisSize.min, children: [
                            IconButton(
                                onPressed: () async {
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
                                icon: const Icon(Icons.settings)),
                            IconButton(
                                onPressed: () async {
                                  final currentUser =
                                      FirebaseAuth.instance.currentUser?.email;
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
                                  Icons.delete,
                                  color: Colors.red,
                                )),
                          ]),
                        ),
                      )),
                ],
              )
            : const Center(child: CircularProgressIndicator()),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue[900],
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
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
