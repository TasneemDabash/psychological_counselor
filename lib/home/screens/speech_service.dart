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
    _conversationMap[threadId]!.add({'role': 'user', 'content': userMessage});
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
        _conversationMap[threadId]!.add({'role': 'assistant', 'content': clean});
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
      _conversationMap[threadId]!.addAll(previous);
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

// import 'dart:convert';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:flutter_tts/flutter_tts.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter/foundation.dart';

// class SpeechService {
//   final FlutterTts _flutterTts = FlutterTts();

//   Future<void> speak(String text) async {
//     await _flutterTts.setLanguage("he-IL");
//     await _flutterTts.setPitch(1.0);
//     await _flutterTts.speak(text);
//   }

//   Future<String?> getGPTResponse(String userMessage, String threadId) async {
//     final apiKey = kIsWeb ? "your-api-key-here" : dotenv.env['API_KEY'];
//     final url = Uri.parse("https://api.openai.com/v1/chat/completions");

//     if (!_conversationMap.containsKey(threadId)) {
//       _initializeThread(threadId);
//     }

//     // Optional: call Python backend first
//     String score = "N/A";
//     try {
//       final backendResponse = await http.post(
//         Uri.parse("http://127.0.0.1:5000/predict"),
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode({"userId": threadId, "statement": userMessage}),
//       );
//       if (backendResponse.statusCode == 200) {
//         final decoded = jsonDecode(backendResponse.body);
//         score = decoded['meanCAVE'].toString();
//       }
//     } catch (e) {
//       print("⚠️ Error calling Python backend: $e");
//     }

//     _conversationMap[threadId]!.add({
//       'role': 'user',
//       'content': "Statement: $userMessage\nPredicted meanCAVE: $score"
//     });

//     _trimMessageHistory(_conversationMap[threadId]!);

//     try {
//       final response = await http.post(
//         url,
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $apiKey',
//         },
//         body: jsonEncode({
//           'model': 'gpt-3.5-turbo',
//           'messages': _conversationMap[threadId],
//           'max_tokens': 1500,
//           'temperature': 0.3,
//         }),
//       );

//       if (response.statusCode == 200) {
//         final jsonResponse = jsonDecode(response.body);
//         final gptResponse = _cleanText(
//           jsonResponse['choices'][0]['message']['content'].trim(),
//         );
//         _conversationMap[threadId]!.add({'role': 'assistant', 'content': gptResponse});
//         return gptResponse;
//       } else {
//         return "⚠️ GPT error: ${response.statusCode}";
//       }
//     } catch (error) {
//       print("❌ Exception in getGPTResponse: $error");
//       return "An error occurred.";
//     }
//   }

//   final List<Map<String, String>> _baseSystemPrompt = [
//     {
//       'role': 'system',
//       'content': "הי {NAME}, אני Hewar, ואני בוט מבוסס בינה מלאכותית שנועד לעזור לך להבין לעומק ולעבד אירועים ומצבים שליליים שאת\ה נתקלת בהם ביום יום. בשיחות שלנו, אנחנו ננסה לפרק ולנתח את המצבים האלה ולזהות דפוסים בחשיבה באופן שיעזור לך להרחיב את ההסתכלות שלך על מצבים שליליים בחיים."
//     }
//   ];

//   final Map<String, List<Map<String, String>>> _conversationMap = {};

//   void _initializeThread(String threadId, [List<Map<String, String>>? previousMessages]) {
//     _conversationMap[threadId] = List<Map<String, String>>.from(_baseSystemPrompt);
//     if (previousMessages != null) {
//       _conversationMap[threadId]!.addAll(previousMessages);
//     }
//   }

//   void _trimMessageHistory(List<Map<String, String>> history) {
//     const maxMessages = 10;
//     if (history.length > maxMessages) {
//       history.removeRange(1, history.length - (maxMessages - 1));
//     }
//   }

//   String _cleanText(String text) {
//     return utf8.decode(text.runes.toList());
//   }
// }




// // // 📄 קובץ: lib/home/screens/speech_service.dart

// // import 'dart:convert';
// // import 'package:flutter_dotenv/flutter_dotenv.dart';
// // import 'package:flutter_tts/flutter_tts.dart';
// // import 'package:http/http.dart' as http;
// // import 'package:flutter/foundation.dart';

// // class SpeechService {
// //   final FlutterTts _flutterTts = FlutterTts();

// //   Future<void> speak(String text) async {
// //     await _flutterTts.setLanguage("he-IL");
// //     await _flutterTts.setPitch(1.0);
// //     await _flutterTts.speak(text);
// //   }

// //   // 🧠 מתודה חדשה לקריאה ל־GPT
// //   Future<String?> getGPTResponse(String userMessage, String threadId) async {
// //     // final apiKey = dotenv.env['API_KEY'];
// //     final apiKey = kIsWeb ? "YOUR_WEB_API_KEY_HERE" : dotenv.env['API_KEY'];
// //     final url = Uri.parse("https://api.openai.com/v1/chat/completions");

// //     if (!_conversationMap.containsKey(threadId)) {
// //       _initializeThread(threadId);
// //     }

// //     _conversationMap[threadId]!.add({'role': 'user', 'content': userMessage});
// //     _trimMessageHistory(_conversationMap[threadId]!);

// //     try {
// //       final response = await http.post(
// //         url,
// //         headers: {
// //           'Content-Type': 'application/json',
// //           'Authorization': 'Bearer $apiKey',
// //         },
// //         body: jsonEncode({
// //           'model': 'gpt-4',
// //           'messages': _conversationMap[threadId],
// //           'max_tokens': 1500,
// //           'temperature': 0.3,
// //           'top_p': 0.9,
// //         }),
// //       );

// //       print("📱 Response status: ${response.statusCode}");
// //       print("📩 Response body: ${response.body}");

// //       if (response.statusCode == 200) {
// //         final jsonResponse = jsonDecode(response.body);
// //         final gptResponse = _cleanText(
// //           jsonResponse['choices'][0]['message']['content'].trim(),
// //         );
// //         _conversationMap[threadId]!.add({'role': 'assistant', 'content': gptResponse});
// //         return gptResponse;
// //       } else if (response.statusCode == 403) {
// //         return "Access to the requested model is restricted. Please check your account.";
// //       } else {
// //         return "I'm having trouble responding right now.";
// //       }

// //     } catch (error) {
// //       print("❌ Error: $error");
// //       return "An error occurred. Please try again.";
// //     }
// // // 📄 קובץ: lib/home/screens/speech_service.dart

// // import 'dart:convert';
// // import 'package:flutter_dotenv/flutter_dotenv.dart';
// // import 'package:flutter_tts/flutter_tts.dart';
// // import 'package:http/http.dart' as http;
// // import 'package:flutter/foundation.dart';

// // class SpeechService {
// //   final FlutterTts _flutterTts = FlutterTts();

// //   Future<void> speak(String text) async {
// //     await _flutterTts.setLanguage("he-IL");
// //     await _flutterTts.setPitch(1.0);
// //     await _flutterTts.speak(text);
// //   }

// //   // 🧠 מתודה חדשה לקריאה ל־GPT
// //   Future<String?> getGPTResponse(String userMessage, String threadId) async {
// //     final apiKey = kIsWeb ? "YOUR_WEB_API_KEY_HERE" : dotenv.env['API_KEY'];
// //     final url = Uri.parse("https://api.openai.com/v1/chat/completions");

// //     if (!_conversationMap.containsKey(threadId)) {
// //       _initializeThread(threadId);
// //     }

// //     _conversationMap[threadId]!.add({'role': 'user', 'content': userMessage});
// //     _trimMessageHistory(_conversationMap[threadId]!);

// //     try {
// //       final response = await http.post(
// //         url,
// //         headers: {
// //           'Content-Type': 'application/json',
// //           'Authorization': 'Bearer $apiKey',
// //         },
// //         body: jsonEncode({
// //           'model': 'gpt-4',
// //           'messages': _conversationMap[threadId],
// //           'max_tokens': 1500,
// //           'temperature': 0.3,
// //           'top_p': 0.9,
// //         }),
// //       );

// //       if (response.statusCode == 200) {
// //         final jsonResponse = jsonDecode(response.body);
// //         final gptResponse = _cleanText(
// //           jsonResponse['choices'][0]['message']['content'].trim(),
// //         );
// //         _conversationMap[threadId]!.add({'role': 'assistant', 'content': gptResponse});
// //         return gptResponse;
// //       } else if (response.statusCode == 403) {
// //         return "Access to the requested model is restricted. Please check your account.";
// //       } else {
// //         return "I'm having trouble responding right now.";
// //       }
// //     } catch (error) {
// //       print("❌ Error: $error");
// //       return "An error occurred. Please try again.";
// //     }
// //   }

// //   // פונקציות עזר פרטיות
// //   final List<Map<String, String>> _baseSystemPrompt = [
// //     {
// //       'role': 'system',
// //       'content': '''
// // You are a helpful and friendly AI assistant. 
// // You are here to help users with any questions they may have. 
// // Be clear, kind, and informative in your responses.
// // If you don’t know the answer, just say you don’t know.
// // '''
// //     }
// //   ];

// //   final Map<String, List<Map<String, String>>> _conversationMap = {};

// //   void _initializeThread(String threadId, [List<Map<String, String>>? previousMessages]) {
// //     if (!_conversationMap.containsKey(threadId)) {
// //       _conversationMap[threadId] = List<Map<String, String>>.from(_baseSystemPrompt);
// //       if (previousMessages != null && previousMessages.isNotEmpty) {
// //         _conversationMap[threadId]!.addAll(previousMessages);
// //       }
// //     }
// //   }

// //   void _trimMessageHistory(List<Map<String, String>> messageHistory) {
// //     const maxMessages = 10;
// //     if (messageHistory.length > maxMessages) {
// //       messageHistory.removeRange(1, messageHistory.length - (maxMessages - 1));
// //     }
// //   }

// //   String _cleanText(String text) {
// //     return utf8.decode(text.runes.toList());
// //   }
// // }
// // // 📄 קובץ: lib/home/screens/speech_service.dart

// // import 'dart:convert';
// // import 'package:flutter_dotenv/flutter_dotenv.dart';
// // import 'package:flutter_tts/flutter_tts.dart';
// // import 'package:http/http.dart' as http;
// // import 'package:flutter/foundation.dart';

// // class SpeechService {
// //   final FlutterTts _flutterTts = FlutterTts();

// //   Future<void> speak(String text) async {
// //     await _flutterTts.setLanguage("he-IL");
// //     await _flutterTts.setPitch(1.0);
// //     await _flutterTts.speak(text);
// //   }

// //   // 🧠 מתודה חדשה לקריאה ל־GPT
// //   Future<String?> getGPTResponse(String userMessage, String threadId) async {
// //     final apiKey = kIsWeb ? "YOUR_WEB_API_KEY_HERE" : dotenv.env['API_KEY'];
// //     final url = Uri.parse("https://api.openai.com/v1/chat/completions");

// //     if (!_conversationMap.containsKey(threadId)) {
// //       _initializeThread(threadId);
// //     }

// //     _conversationMap[threadId]!.add({'role': 'user', 'content': userMessage});
// //     _trimMessageHistory(_conversationMap[threadId]!);

// //     try {
// //       final response = await http.post(
// //         url,
// //         headers: {
// //           'Content-Type': 'application/json',
// //           'Authorization': 'Bearer $apiKey',
// //         },
// //         body: jsonEncode({
// //           'model': 'gpt-4',
// //           'messages': _conversationMap[threadId],
// //           'max_tokens': 1500,
// //           'temperature': 0.3,
// //           'top_p': 0.9,
// //         }),
// //       );

// //       if (response.statusCode == 200) {
// //         final jsonResponse = jsonDecode(response.body);
// //         final gptResponse = _cleanText(
// //           jsonResponse['choices'][0]['message']['content'].trim(),
// //         );
// //         _conversationMap[threadId]!.add({'role': 'assistant', 'content': gptResponse});
// //         return gptResponse;
// //       } else if (response.statusCode == 403) {
// //         return "Access to the requested model is restricted. Please check your account.";
// //       } else {
// //         return "I'm having trouble responding right now.";
// //       }
// //     } catch (error) {
// //       print("❌ Error: $error");
// //       return "An error occurred. Please try again.";
// //     }
// //   }

// //   // פונקציות עזר פרטיות
// //   final List<Map<String, String>> _baseSystemPrompt = [
// //     {
// //       'role': 'system',
// //       'content': '''
// // You are a helpful and friendly AI assistant. 
// // You are here to help users with any questions they may have. 
// // Be clear, kind, and informative in your responses.
// // If you don’t know the answer, just say you don’t know.
// // '''
// //     }
// //   ];

// //   final Map<String, List<Map<String, String>>> _conversationMap = {};

// //   void _initializeThread(String threadId, [List<Map<String, String>>? previousMessages]) {
// //     if (!_conversationMap.containsKey(threadId)) {
// //       _conversationMap[threadId] = List<Map<String, String>>.from(_baseSystemPrompt);
// //       if (previousMessages != null && previousMessages.isNotEmpty) {
// //         _conversationMap[threadId]!.addAll(previousMessages);
// //       }
// //     }
// //   }

// //   void _trimMessageHistory(List<Map<String, String>> messageHistory) {
// //     const maxMessages = 10;
// //     if (messageHistory.length > maxMessages) {
// //       messageHistory.removeRange(1, messageHistory.length - (maxMessages - 1));
// //     }
// //   }

// //   String _cleanText(String text) {
// //     return utf8.decode(text.runes.toList());
// //   }
// // }
// //   }

// //   // פונקציות עזר פרטיות
// //   final List<Map<String, String>> _baseSystemPrompt = [
// //     {
// //       'role': 'system',
// //       'content': '''
// // You are a helpful and friendly AI assistant. 
// // You are here to help users with any questions they may have. 
// // Be clear, kind, and informative in your responses.
// // If you don’t know the answer, just say you don’t know.
// // '''
// //     }
// //   ];

// //   final Map<String, List<Map<String, String>>> _conversationMap = {};

// //   void _initializeThread(String threadId, [List<Map<String, String>>? previousMessages]) {
// //     if (!_conversationMap.containsKey(threadId)) {
// //       _conversationMap[threadId] = List<Map<String, String>>.from(_baseSystemPrompt);
// //       if (previousMessages != null && previousMessages.isNotEmpty) {
// //         _conversationMap[threadId]!.addAll(previousMessages);
// //       }
// //     }
// //   }

// //   void _trimMessageHistory(List<Map<String, String>> messageHistory) {
// //     const maxMessages = 10;
// //     if (messageHistory.length > maxMessages) {
// //       messageHistory.removeRange(1, messageHistory.length - (maxMessages - 1));
// //     }
// //   }

// //   String _cleanText(String text) {
// //     return utf8.decode(text.runes.toList());
// //   }
// // }

