import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../domain/models/scanned_answer_item.dart';

class AIOMRScannerService {
  final String apiKey;
  final String apiEndpoint;

  AIOMRScannerService({
    required this.apiKey,
    this.apiEndpoint = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent',
  });

  Future<List<ScannedAnswerItem>> scanPaperSheet(File sheetImage) async {
    final String base64Img = base64Encode(await sheetImage.readAsBytes());
    final payload = {
      "contents": [
        {
          "parts": [
            {
              "text": "Read this MMPI-2 answer sheet image carefully. Extract client metadata "
                      "(name, age, gender, start time, end time) if written at the top, and extract all marked "
                      "answers sequentially. For each question number, return an array of objects with keys: "
                      "'questionNumber' (int), 'answer' ('T' for True/Right bubble, 'F' for False/Left bubble, or 'U' if blank or double-marked), "
                      "and 'confidence' (float between 0.0 and 1.0)."
            },
            {
              "inline_data": {
                "mime_type": "image/jpeg",
                "data": base64Img,
              }
            }
          ]
        }
      ],
      "generationConfig": {
        "response_mime_type": "application/json",
        "temperature": 0.0,
      }
    };

    final response = await http.post(
      Uri.parse('$apiEndpoint?key=$apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (response.statusCode != 200) {
      throw Exception('AI Vision Error: ${response.statusCode} - ${response.body}');
    }

    final decoded = jsonDecode(response.body);
    final text = decoded['candidates'][0]['content']['parts'][0]['text'];
    final data = jsonDecode(text);

    final List<ScannedAnswerItem> items = [];
    if (data is List) {
      for (final item in data) {
        items.add(ScannedAnswerItem.fromMap(Map<String, dynamic>.from(item)));
      }
    } else if (data is Map && data['answers'] is List) {
      for (final item in data['answers']) {
        items.add(ScannedAnswerItem.fromMap(Map<String, dynamic>.from(item)));
      }
    }

    return items;
  }
}
