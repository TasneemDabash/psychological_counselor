import 'dart:convert';
import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;

class SpeechService {
  final FlutterTts _flutterTts = FlutterTts();

  final List<Map<String, String>> _baseSystemPrompt = [
    {
      'role': 'system',
      'content': "Hi {NAME}, I'm Hewar, an AI-based assistant designed to help you deeply understand and process the negative events and situations you encounter in daily life. In our conversations, we'll try to break down and analyze these situations and identify thinking patterns in a way that helps you expand your perspective on negative life experiences."
    }
  ];

  final Map<String, List<Map<String, String>>> _conversationMap = {};

  Future<void> speak(String text) async {
    await _flutterTts.setLanguage("he-IL");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.speak(text);
  }

  Future<String?> getGPTResponse(String userMessage, String threadId) async {
    final apiKey = dotenv.env['OPENAI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      return "Error: API key not configured.";
    }

    final gptUrl = Uri.parse("https://api.openai.com/v1/chat/completions");

    // Initialize system prompt for thread
    if (!_conversationMap.containsKey(threadId)) {
      _initializeThread(threadId);
    }

    // Optional ML score from backend
    String score = "N/A";
    try {
      final backendResponse = await http.post(
        Uri.parse("http://127.0.0.1:5000/predict"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"userId": threadId, "statement": userMessage}),
      ).timeout(const Duration(seconds: 5));

      if (backendResponse.statusCode == 200) {
        final decoded = jsonDecode(backendResponse.body);
        score = decoded['meanCAVE'].toString();
      }
    } catch (_) {}

    // Add user message
    _conversationMap[threadId]?.add({'role': 'user', 'content': userMessage});
    _trimMessageHistory(_conversationMap[threadId]!);

    // Send to GPT
    try {
      final requestBody = {
        'model': 'gpt-3.5-turbo',
        'messages': _conversationMap[threadId],
        'max_tokens': 1500,
        'temperature': 0.3,
      };

      print("🧠 Full GPT prompt:");
      print(jsonEncode(requestBody['messages']));

      final response = await http.post(
        gptUrl,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final content = json['choices'][0]['message']['content'].trim();
        final clean = _cleanText(content);
        _conversationMap[threadId]?.add({'role': 'assistant', 'content': clean});
        return clean;
      } else {
        return _handleGPTError(response);
      }
    } catch (_) {
      return "An error occurred. Please try again.";
    }
  }

  // Future<String> runAttributionFlow({
  //   required String event,
  //   required String emotion,
  //   required String reason,
  // }) async {
  //   try {
  //     final response = await http.post(
  //       Uri.parse("http://127.0.0.1:5000/attribution"),
  //       headers: {'Content-Type': 'application/json'},
  //       body: jsonEncode({
  //         'event': event,
  //         'emotion': emotion,
  //         'reason': reason,
  //       }),
  //     );

  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //       return data['response'] ?? '⚠️ No response';
  //     } else {
  //       return "❌ Server error: ${response.statusCode}";
  //     }
  //   } catch (e) {
  //     return "⚠️ Attribution request failed: $e";
  //   }
  // }

  void _initializeThread(String threadId, [List<Map<String, String>>? previous]) {
    _conversationMap[threadId] = List<Map<String, String>>.from(_baseSystemPrompt);
    if (previous != null) {
      if (previous != null) {
        _conversationMap[threadId]?.addAll(previous);
      }
    }
  }

  void _trimMessageHistory(List<Map<String, String>> history) {
    const maxMessages = 10;
    if (history.length > maxMessages) {
      history.removeRange(1, history.length - (maxMessages - 1));
    }
  }

  String _cleanText(String text) {
    return utf8.decode(text.runes.toList());
  }

  String _handleGPTError(http.Response response) {
    final errorBody = jsonDecode(response.body);
    final errorType = errorBody['error']?['type'];
    final message = errorBody['error']?['message'] ?? response.body;

    if (response.statusCode == 429 || errorType == 'insufficient_quota') {
      return "⚠️ Service temporarily unavailable. Try again later.";
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      return "⚠️ API key invalid or unauthorized.";
    } else if (response.statusCode == 422) {
      return "⚠️ Invalid request format.";
    } else {
      return "❌ Error ${response.statusCode}: $message";
    }
  }
}
