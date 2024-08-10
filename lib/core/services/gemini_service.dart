import 'dart:typed_data';
import 'package:gemilife/home/services/event.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  static const String _modelName = 'gemini-1.5-flash';
  late GenerativeModel _model;
  List<Uint8List> _sessionImages = [];

  void initialize() {
    String? apiKey = dotenv.env['GEMINI_API_KEY'];

    if (apiKey == 'key not found') {
      throw Exception('No \$GEMINI_API_KEY environment variable');
    }
    _model = GenerativeModel(model: _modelName, apiKey: apiKey!);
  }

  Stream<String> generateShortFeedback(List<Event> events) async* {
    try {
      final String journalEntries =
          events.map((e) => "${e.title}: ${e.description ?? ''}").join('\n');
      final prompt = '''
        Here are today's journal entries: $journalEntries.
        Based on these, provide brief feedback in 10 words or less.
      ''';

      final content = [Content.text(prompt)];

      final response = _model.generateContentStream(content);

      await for (final chunk in response) {
        if (chunk.text != null) {
          yield chunk.text!;
        }
      }
    } catch (e) {
      yield 'Error Review: $e';
    }
  }

  Stream<String> generateReview(List<Map<String, dynamic>> events) async* {
    try {
      final eventDescriptions = events.map((event) {
        return '''
      Date: ${event['date']}
      Title: ${event['title']}
      Description: ${event['description']}
      Energy: ${event['energy']}
      Engagement: ${event['engagement']}
      ''';
      }).join('\n\n');
      final prompt = '''
        Based on the following journal entries from the past week, provide a detailed weekly review. 
        Include insights on personal development, productivity, emotional well-being, 
        and any noticeable patterns or trends. Offer actionable suggestions for improvement 
        and highlight any significant achievements or challenges.
        

        $eventDescriptions
      ''';

      final content = [Content.text(prompt)];

      final response = _model.generateContentStream(content);

      await for (final chunk in response) {
        if (chunk.text != null) {
          yield chunk.text!;
        }
      }
    } catch (e) {
      yield 'Error Review: $e';
    }
  }

  Future<String?> generateMeditationReview(
      String forwardFeel, String endFeel) async {
    final prompt = '''
    Please provide a brief review based on the user's meditation session.
      - Before meditation, the user felt: $forwardFeel.
      - After meditation, the user felt: $endFeel.

    Based on these feelings, generate an evaluation highlighting any notable changes, insights, or experiences the user might have had during the session. The review should be concise, around 200 words, and focus on how the meditation may have impacted the user's mental or emotional state.
    ''';
    final content = [Content.text(prompt)];
    final response = await _model.generateContent(content);
    print('Gemini log: ${response.text}!!!!!!!!!!!!!!!!!!');
    return response.text;
  }

  Stream<String> analyzePose(Uint8List imageBytes, String poseName) async* {
    try {
      _sessionImages.add(imageBytes);

      final prompt = '''
        Act as a fitness coach analyzing this $poseName pose image:
        1. Accuracy: Is the pose correct? (Yes/Slightly off/No)
        2. Key observation: What's the most notable aspect (good or needs improvement)?
        3. Quick tip: One short, specific correction or encouragement (max 10 words).
        Keep the entire response within 20 words. Focus on clarity and brevity.
        Avoid any Markdown formatting in your response.
      ''';

      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', imageBytes),
        ])
      ];

      final response = _model.generateContentStream(content);

      await for (final chunk in response) {
        if (chunk.text != null) {
          yield chunk.text!;
        }
      }
    } catch (e) {
      yield 'Error analyzing pose: $e';
    }
  }

  Future<String> generateSessionReview() async {
    if (_sessionImages.isEmpty) {
      return 'No yoga session data available.';
    }

    try {
      final prompt = TextPart('''
        As an experienced yoga instructor, review the entire yoga session represented by these images. 
        Provide a comprehensive summary of the session, including:
        1. Overall performance assessment
        2. Identification of strengths and areas for improvement
        3. Suggestions for future practice
        4. Any potential safety concerns or modifications needed
        Be thorough but concise, focusing on the most impactful observations and advice.
      ''');

      final response = await _model.generateContent([
        Content.multi([
          prompt,
          ...[DataPart('image/jpeg', _sessionImages as Uint8List)],
        ])
      ]);
      _clearSessionData(); // Clear the session data after generating the summary
      return response.text ?? 'No summary generated';
    } catch (e) {
      return 'Error generating session summary: $e';
    }
  }

  void _clearSessionData() {
    _sessionImages.clear();
  }
}
