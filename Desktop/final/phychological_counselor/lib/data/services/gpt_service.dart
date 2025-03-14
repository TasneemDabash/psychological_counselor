import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

// 1) Base system prompt to enforce psychiatry domain
final List<Map<String, String>> baseSystemPrompt = [
  {
    'role': 'system',
    'content': '''
You are Psychiatric AI , an AI assistant specialized in psychiatry and mental health. 
- You will answer only psychiatry/mental-health-related questions. 
- If the user asks about something outside these topics, politely decline by saying: "I’m sorry, I can only answer psychiatry/mental-health-related questions."
- Always provide well-structured, complete, and helpful answers related to psychiatry.
- End your answers with a concluding sentence that summarizes all points.
- If you don’t know the answer, clearly state that.
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
    // 4) Send the entire conversation to OpenAI
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

    // 5) Check if successful
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final gptResponse = cleanText(
        jsonResponse['choices'][0]['message']['content'].trim(),
      );

      // 6) Add assistant response to conversation
      conversationMap[threadId]!.add({'role': 'assistant', 'content': gptResponse});

      return gptResponse;
    } else {
      // Model restricted or some other issue
      if (response.statusCode == 403) {
        return "Access to the requested model is restricted. Please check your account.";
      }
      return "I'm having trouble responding right now.";
    }
  } catch (error) {
    return "An error occurred. Please try again.";
  }
}

// Limits stored messages to avoid exceeding token limits
void trimMessageHistory(List<Map<String, String>> messageHistory) {
  const maxMessages = 10;
  // Keep the system prompt at index 0, then trim others if exceeding
  if (messageHistory.length > maxMessages) {
    // This removes everything except the system message (index 0) and the last (maxMessages - 1) messages
    messageHistory.removeRange(1, messageHistory.length - (maxMessages - 1));
  }
}

// Utility to clean text (handle any encoding issues)
String cleanText(String text) {
  return utf8.decode(text.runes.toList());
}
