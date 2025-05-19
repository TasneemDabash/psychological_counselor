import 'dart:convert';
import 'package:http/http.dart' as http;

Future<bool> isRealEmail(String email) async {
  final apiKey = '2a31e8bff61647fdbb9f65c3aacf628d';
  final url = Uri.parse('https://emailvalidation.abstractapi.com/v1/?api_key=$apiKey&email=$email');

  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    print("Response: $data");

    return data['deliverability'] == 'DELIVERABLE' &&
           data['is_valid_format']['value'] == true &&
           data['is_disposable_email']['value'] == false &&
           data['is_smtp_valid']['value'] == true;
  } else {
    throw Exception('Failed to validate email');
  }
}
