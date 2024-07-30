import 'dart:typed_data';
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

  Stream<String> generateReview(List<String> events) async* {
    try {
      final prompt = '''
        Based on the following journal entries from the past week, provide a detailed weekly review. 
        Include insights on personal development, productivity, emotional well-being, 
        and any noticeable patterns or trends. Offer actionable suggestions for improvement 
        and highlight any significant achievements or challenges.

        ${events.join('\n')}
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

  Future<String?> generateMeditationReview() async {
    final prompt = '''''';
    final content = [Content.text(prompt)];
    final response = await _model.generateContent(content);
    return response.text;
  }

  Stream<String> analyzePose(Uint8List imageBytes) async* {
    try {
      _sessionImages.add(imageBytes);

      const prompt = '''
        As a yoga instructor, analyze this yoga pose image and provide brief feedback:
        1. Identify the pose
        2. Assess the pose accuracy
        3. Suggest one key improvement, if necessary
        Keep the response concise, focusing on the most important point.
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

  Future<String> generateSessionSummary() async {
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
