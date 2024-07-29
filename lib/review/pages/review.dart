import 'package:flutter/material.dart';

import 'package:fl_chart/fl_chart.dart';

class Review extends StatelessWidget {
  const Review({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weekly Insights'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'December 11 - December 17, 2023',
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Weekly Summary',
                      ),
                      SizedBox(height: 8),
                      Text(
                        'This week, you focused on personal development and work projects. You had several productive days and managed stress well.',
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
                      Text(
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
