import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<String?> getGPTResponse(String userMessage, String userId) async {
  final apiKey = dotenv.env['OPENAI_API_KEY'];
  if (apiKey == null) {
    print("🔴 API key is missing!");
    return null;
  }

  final response = await http.post(
    Uri.parse('https://api.openai.com/v1/chat/completions'),
    headers: {
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'model': 'gpt-3.5-turbo',
      'messages': [
        {'role': 'system', 'content': "Hi {NAME}, I'm Hewar, an AI-based assistant designed to help you deeply understand and process the negative events and situations you encounter in daily life. In our conversations, we'll try to break down and analyze these situations and identify thinking patterns in a way that helps you expand your perspective on negative life experiences."},
        {'role': 'user', 'content': userMessage}
      ],
    }),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['choices'][0]['message']['content'];
  } else {
    print("🔴 Error: ${response.body}");
    return null;
  }
}
