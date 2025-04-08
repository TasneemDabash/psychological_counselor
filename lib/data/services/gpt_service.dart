import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

// 1) Base system prompt to enforce psychiatry domain
final List<Map<String, String>> baseSystemPrompt = [
  {
    'role': 'system',
    'content': '''
You are a helpful and friendly AI assistant. 
You are here to help users with any questions they may have. 
Be clear, kind, and informative in your responses.
If you don’t know the answer, just say you don’t know.

'''
  }
];

final Map<String, List<Map<String, String>>> conversationMap = {};

void initializeThread(String threadId, [List<Map<String, String>>? previousMessages]) {
  if (!conversationMap.containsKey(threadId)) {
    conversationMap[threadId] = List<Map<String, String>>.from(baseSystemPrompt);

    if (previousMessages != null && previousMessages.isNotEmpty) {
      conversationMap[threadId]!.addAll(previousMessages);
    }
  }
}

Future<String?> getGPTResponse(String userMessage, String threadId) async {
  final apiKey = dotenv.env['API_KEY'];
  final url = Uri.parse("https://api.openai.com/v1/chat/completions");

  if (!conversationMap.containsKey(threadId)) {
    initializeThread(threadId);
  }

  conversationMap[threadId]!.add({'role': 'user', 'content': userMessage});
  trimMessageHistory(conversationMap[threadId]!);

  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-4',
        'messages': conversationMap[threadId],
        'max_tokens': 1500,
        'temperature': 0.3,
        'top_p': 0.9,
      }),
    );

    // ✅ הדפסות לזיהוי תקשורת עם OpenAI
    print("📱 Response status: \${response.statusCode}");
    print("📩 Response body: \${response.body}");

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final gptResponse = cleanText(
        jsonResponse['choices'][0]['message']['content'].trim(),
      );

      conversationMap[threadId]!.add({'role': 'assistant', 'content': gptResponse});

      return gptResponse;
    } else {
      if (response.statusCode == 403) {
        return "Access to the requested model is restricted. Please check your account.";
      }
      return "I'm having trouble responding right now.";
    }
  } catch (error) {
    print("❌ Error: \$error");
    return "An error occurred. Please try again.";
  }
}

// Limits stored messages to avoid exceeding token limits
void trimMessageHistory(List<Map<String, String>> messageHistory) {
  const maxMessages = 10;
  if (messageHistory.length > maxMessages) {
    messageHistory.removeRange(1, messageHistory.length - (maxMessages - 1));
  }
}

// Utility to clean text (handle any encoding issues)
String cleanText(String text) {
  return utf8.decode(text.runes.toList());
}
