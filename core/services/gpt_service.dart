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
        {'role': 'system', 'content': 'You are a helpful and optimistic therapist bot. Always transform negative thinking into hopeful messages.'},
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
