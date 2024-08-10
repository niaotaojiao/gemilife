import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:gemilife/core/services/gemini_service.dart';
import 'package:intl/intl.dart';

class Review extends StatefulWidget {
  const Review({super.key});

  @override
  _ReviewState createState() => _ReviewState();
}

class _ReviewState extends State<Review> {
  List<Map<String, dynamic>> weeklyEntries = [];
  Map<String, double> meditationData = {};
  String? summary;
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  final GeminiService _geminiService = GeminiService();
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    setWeekRange();
    fetchWeeklyEvents();
    _geminiService.initialize();
  }

  void setWeekRange() {
    DateTime now = DateTime.now();
    endDate = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday))
        .add(Duration(hours: 23, minutes: 59, seconds: 59));
    startDate = endDate
        .subtract(Duration(days: 6))
        .subtract(Duration(hours: 23, minutes: 59, seconds: 59));
  }

  void adjustWeek(int direction) {
    setState(() {
      _isExpanded = false;
      startDate = startDate.add(Duration(days: 7 * direction));
      endDate = endDate.add(Duration(days: 7 * direction));
      summary =
          'Not generated yet, please click the button below to generate suggestions and reflections.';
    });
    fetchWeeklyEvents();
  }

  Future<void> fetchWeeklyEvents() async {
    final currentUser = FirebaseAuth.instance.currentUser?.email;
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection(currentUser!)
        .doc('eventlist')
        .collection('events')
        .where('date', isGreaterThanOrEqualTo: startDate)
        .where('date', isLessThanOrEqualTo: endDate)
        .get();

    List<Map<String, dynamic>> entries = snapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return {
        'date': doc['date'],
        'description': doc['description'],
        'energy': data.containsKey('energy') ? doc['energy'] : 'No energy data',
        'engagement': data.containsKey('engagement')
            ? data['engagement']
            : 'No engagement data',
        'title': doc['title'],
      };
    }).toList();

    if (mounted) {
      setState(() {
        weeklyEntries = entries;
      });
    }

    final reviewSnapshot = await FirebaseFirestore.instance
        .collection(currentUser)
        .doc('eventlist')
        .collection('reviews')
        .where('startDate', isEqualTo: Timestamp.fromDate(startDate))
        .where('endDate', isEqualTo: Timestamp.fromDate(endDate))
        .get();

    if (reviewSnapshot.docs.isNotEmpty) {
      setState(() {
        summary = reviewSnapshot.docs.first['summary'];
        _isExpanded = true;
      });
    }

    final meditationSnapshot = await FirebaseFirestore.instance
        .collection(currentUser)
        .doc('eventlist')
        .collection('meditation')
        .where('date', isGreaterThanOrEqualTo: startDate)
        .where('date', isLessThanOrEqualTo: endDate)
        .get();

    Map<String, double> data = {};

    meditationSnapshot.docs.forEach((doc) {
      DateTime date = doc['date'].toDate();
      String formattedDate = DateFormat('MM/dd').format(date);
      double duration = doc['duration'].toDouble();

      if (data.containsKey(formattedDate)) {
        data[formattedDate] = data[formattedDate]! + duration;
      } else {
        data[formattedDate] = duration;
      }
    });

    setState(() {
      meditationData = data;
    });
  }

  Future<void> generateSuggestions() async {
    if (weeklyEntries.isEmpty) return;
    final stream = _geminiService.generateReview(weeklyEntries);
    setState(() {
      _isExpanded = true;
    });
    String fullFeedback = '';
    await for (final feedback in stream) {
      fullFeedback += feedback;
      setState(() {
        summary = fullFeedback;
      });
    }

    final currentUser = FirebaseAuth.instance.currentUser?.email;
    await FirebaseFirestore.instance
        .collection(currentUser!)
        .doc('eventlist')
        .collection('reviews')
        .add({
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'summary': summary,
    });
  }

  List<BarChartGroupData> getBarChartData() {
    List<BarChartGroupData> barChartData = [];
    for (int i = 0; i < 7; i++) {
      DateTime date = startDate.add(Duration(days: i));
      String formattedDate = DateFormat('MM/dd').format(date);
      double duration = meditationData[formattedDate] ?? 0.0;

      barChartData.add(
        BarChartGroupData(
          x: i,
          barRods: [BarChartRodData(toY: duration, color: Colors.blue)],
        ),
      );
    }
    return barChartData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FD),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Weekly Summary',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                        onPressed: () => adjustWeek(-1),
                        icon: const Icon(Icons.arrow_back_ios_new)),
                    Text(
                      '${DateFormat('MMMM d').format(startDate)} - ${DateFormat('MMMM d, yyyy').format(endDate)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    IconButton(
                        onPressed: () => adjustWeek(1),
                        icon: const Icon(Icons.arrow_forward_ios)),
                  ],
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          constraints: BoxConstraints(
                            maxHeight: _isExpanded ? 400 : 200,
                            minHeight: _isExpanded ? 400 : 200,
                          ),
                          child: Markdown(
                            data: summary ??
                                'Not generated yet, please click the button below to generate suggestions and reflections.',
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.thumb_up_outlined),
                              tooltip: 'Like',
                            ),
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.thumb_down_outlined),
                              tooltip: 'Dislike',
                            ),
                            ElevatedButton(
                                onPressed: () {
                                  generateSuggestions();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.amber[800],
                                ),
                                child: const Text(
                                  'Generation report',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                )),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  '   Meditation Trend',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 250,
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              barGroups: getBarChartData(),
                              titlesData: FlTitlesData(
                                topTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false)),
                                leftTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false)),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 40,
                                    interval: 1,
                                    getTitlesWidget: (value, meta) {
                                      final date = startDate
                                          .add(Duration(days: value.toInt()));
                                      return SideTitleWidget(
                                        axisSide: meta.axisSide,
                                        child: Text(
                                          DateFormat('EEE').format(date),
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [Text('(min)')],
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
