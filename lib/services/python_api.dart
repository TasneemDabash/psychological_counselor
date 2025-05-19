import 'package:http/http.dart' as http;
import 'dart:convert';

class PythonAPI {
  static const String baseUrl = 'http://127.0.0.1:8080';

  static Future<String> sendEcho(String message) async {
    final url = Uri.parse('$baseUrl/process_message');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'messageId': DateTime.now().millisecondsSinceEpoch.toString(),
        'userId': 'test_user', // You should replace this with the actual user ID
        'text': message
      }),
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('❌ Failed to connect to Python server: ${response.statusCode}');
    }
  }
}
