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

  @override
  void initState() {
    super.initState();
    setWeekRange();
    fetchWeeklyEvants();
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

  Future<void> fetchWeeklyEvants() async {
    final currentUser = FirebaseAuth.instance.currentUser?.email;
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection(currentUser!)
        .doc('eventlist')
        .collection('events')
        .where('date', isGreaterThanOrEqualTo: startDate)
        .where('date', isLessThanOrEqualTo: endDate)
        .get();

    List<Map<String, dynamic>> entries = snapshot.docs.map((doc) {
      return {
        'date': doc['date'],
        'description': doc['description'],
        'energy': doc['energy'],
        'engagement': doc['engagement'],
        'title': doc['title'],
      };
    }).toList();
    setState(() {
      weeklyEntries = entries;
    });

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
      });
    } else {
      print('!!!!!!!!!!!!!!');
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
      appBar: AppBar(
        title: const Text('Weekly Insights'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${DateFormat('MMMM d').format(startDate)} - ${DateFormat('MMMM d, yyyy').format(endDate)}',
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Weekly Summary',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        constraints: BoxConstraints(maxHeight: 400),
                        child: Markdown(
                          data: summary ?? 'Generating suggestions...',
                        ),
                      ),
                      IconButton(
                          onPressed: generateSuggestions,
                          icon: const Icon(Icons.add_alert))
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Meditation Trend',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 200,
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
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
