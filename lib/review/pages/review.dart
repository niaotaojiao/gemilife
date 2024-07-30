import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gemilife/core/services/gemini_service.dart';
import 'package:intl/intl.dart';

class Review extends StatefulWidget {
  const Review({super.key});

  @override
  _ReviewState createState() => _ReviewState();
}

class _ReviewState extends State<Review> {
  List<String> weeklyEntries = [];
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
    endDate = now.subtract(Duration(days: now.weekday)); // 上周日
    startDate = endDate.subtract(Duration(days: 6)); // 上周一
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

    List<String> entries =
        snapshot.docs.map((doc) => doc['content'].toString()).toList();
    setState(() {
      weeklyEntries = entries;
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
      'startDate': startDate,
      'endDate': endDate,
      'summary': summary,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Insights'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
                      ),
                      const SizedBox(height: 8),
                      Text(
                        summary ?? 'Generating suggestions...',
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
                        'Mood Trend',
                      ),
                      SizedBox(height: 8),
                      Container(
                        height: 200,
                        child: LineChart(
                          LineChartData(
                              // TODO: Implement actual chart data
                              ),
                        ),
                      ),
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
                      Text('Next Week\'s Goals'),
                      SizedBox(height: 8),
                      ListTile(
                        leading: Icon(Icons.check_circle_outline),
                        title: Text('Complete the Flutter app prototype'),
                      ),
                      ListTile(
                        leading: Icon(Icons.add_circle_outline),
                        title: Text('Add a new goal'),
                        onTap: () {
                          // TODO: Implement add goal functionality
                        },
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
