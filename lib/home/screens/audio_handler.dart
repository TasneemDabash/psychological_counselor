// // 📄 קובץ: lib/home/screens/audio_handler.dart

// import 'dart:convert';
// import 'dart:io';
// import 'dart:html' as html;
// import 'package:record/record.dart';
// import 'package:flutter/foundation.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:http/http.dart' as http;
// import 'package:path/path.dart' as p;
// import 'dart:async';

// class AudioHandler {
//   final Record _recorder = Record();
//   html.MediaRecorder? _mediaRecorder;
//   List<html.Blob> _audioChunks = [];

//   Future<void> startRecording() async {
//     import 'dart:html' as html;

// Future<void> startRecording() async {
      
//     if (kIsWeb) {
//       final mediaDevices = html.window.navigator.mediaDevices;
//       if (mediaDevices != null) {
//           try {
//             print('🔊 Requesting microphone access...');
//             final stream = await mediaDevices.getUserMedia({'audio': true});
//             _stream = stream;
//             _mediaRecorder = html.MediaRecorder(stream);
//             _audioChunks = [];

//             _mediaRecorder.addEventListener('dataavailable', (event) {
//               final blob = (event as html.BlobEvent).data;
//               if (blob != null) _audioChunks.add(blob);
//             });

//             _mediaRecorder.start();
//             print('🎙️ Recording started.');
//           } catch (e) {
//             print('🎤 Microphone access error: $e');
//           }
//         } else {
//           print('⚠️ mediaDevices is not supported in this browser');
//         }
//     } 
//     else {
//       final dir = await getApplicationDocumentsDirectory();
//       final path = p.join(dir.path, 'audio_${DateTime.now().millisecondsSinceEpoch}.m4a');
//       await _recorder.start(path: path);
//     }
//   }

//   Future<String> stopAndTranscribe(bool isWeb) async {
//     if (isWeb) {
//       final completer = Completer<html.Blob>();
//       _mediaRecorder?.addEventListener('stop', (_) {
//         completer.complete(html.Blob(_audioChunks));
//       });
//       _mediaRecorder?.stop();
//       final blob = await completer.future;
//       final reader = html.FileReader();
//       reader.readAsArrayBuffer(blob);
//       await reader.onLoad.first;
//       final bytes = reader.result as List<int>;
//       return await _transcribeAudio(base64Encode(bytes));
//     } else {
//       final path = await _recorder.stop();
//       final bytes = await File(path!).readAsBytes();
//       return await _transcribeAudio(base64Encode(bytes));
//     }
//   }

//   Future<String> _transcribeAudio(String base64Audio) async {
//     final response = await http.post(
//       Uri.parse('https://speech.googleapis.com/v1/speech:recognize?key=YOUR_GOOGLE_API_KEY'),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({
//         "config": {
//           "encoding": "WEBM_OPUS",
//           "sampleRateHertz": 48000,
//           "languageCode": "he-IL"
//         },
//         "audio": {"content": base64Audio}
//       }),
//     );

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       if (data['results'] != null && data['results'].isNotEmpty) {
//         return data['results'][0]['alternatives'][0]['transcript'];
//       } else {
//         return "לא זוהתה הודעה קולית.";
//       }
//     } else {
//       return "שגיאה בהמרת קול לטקסט.";
//     }
//   }
// }



import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'dart:async';

// // Conditional import
// export 'audio_handler_web.dart'
//   if (dart.library.io) 'audio_handler_mobile.dart';

