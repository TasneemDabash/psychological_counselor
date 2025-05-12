// <<<<<<< HEAD
// // 📄 קובץ: home_screen.dart

// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
// import 'dart:html' as html;

// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:model_viewer_plus/model_viewer_plus.dart';
// import 'package:provider/provider.dart';
// import 'package:record/record.dart';
// import 'package:http/http.dart' as http;
// import 'package:path_provider/path_provider.dart';
// import 'package:path/path.dart' as p;

// import '../../../data/services/gpt_service.dart';
// =======
// 📄 קובץ: lib/home/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:phychological_counselor/data/services/gpt_service.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:phychological_counselor/home/screens/audio_handler.dart';
import 'package:phychological_counselor/home/screens/firestore_service.dart';
import 'package:phychological_counselor/home/screens/speech_service.dart';
import 'package:flutter/foundation.dart'; // <-- בשביל kIsWeb

import '../../ai_chat/provider/chat_provider.dart';
import '../../ai_chat/widgets/build_message.dart';
import '../../ai_chat/widgets/chat_text_field.dart';
import '../../ai_chat/widgets/send_button.dart';
// <<<<<<< HEAD
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../../frontend/settings_panel.dart';

// import 'package:flutter_tts/flutter_tts.dart'; // 🆕 להמרת טקסט לקול
// =======
import '../../frontend/settings_panel.dart';
import '../../ai_chat/widgets/chat_history_sidebar.dart';
// import 'package:phychological_counselor/services/python_api.dart'; // ← יבוא השירות
// import 'package:phychological_counselor/backend/python_ml_api.dart';


import 'tts_service.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  bool _isRecording = false;
// <<<<<<< HEAD
//   final Record _audioRecorder = Record();
//   final FlutterTts _flutterTts = FlutterTts(); // 🆕 Text to Speech

//   html.MediaRecorder? _mediaRecorder;
//   List<html.Blob> _audioChunks = [];
//   bool _lastInputWasVoice = false; // 🆕 לדעת איך המשתמש שלח את ההודעה

//   Future<void> _toggleRecording() async {
//     print("🔴 כפתור ההקלטה נלחץ");

//     if (kIsWeb) {
//       if (_isRecording) {
//         setState(() => _isRecording = false);
//         final transcript = await stopWebRecordingAndConvertToText();
//         await _saveMessageToFirestore(transcript);
//         _lastInputWasVoice = true;
//         _sendMessage(transcript);
//       } else {
//         await startWebRecording();
//         setState(() => _isRecording = true);
//       }
//       return;
//     }

//     if (_isRecording) {
//       String? path = await _audioRecorder.stop();
//       setState(() => _isRecording = false);
//       if (path != null) {
//         String transcript = await convertAudioToText(path);
//         await _saveMessageToFirestore(transcript);
//         _lastInputWasVoice = true;
//         _sendMessage(transcript);
//       }
//     } else {
//       final dir = await getApplicationDocumentsDirectory();
//       final filePath = p.join(
//         dir.path,
//         'recorded_audio_\${DateTime.now().millisecondsSinceEpoch}.m4a',
//       );
//       await _audioRecorder.start(
//         path: filePath,
//         bitRate: 128000,
//         samplingRate: 44100,
//       );
//       setState(() => _isRecording = true);
//     }
//   }

//   Future<void> startWebRecording() async {
//     final stream = await html.window.navigator.mediaDevices!.getUserMedia({'audio': true});
//     _mediaRecorder = html.MediaRecorder(stream);
//     _audioChunks = [];

//     _mediaRecorder!.addEventListener('dataavailable', (event) {
//       final blob = (event as html.BlobEvent).data;
//       if (blob != null) {
//         _audioChunks.add(blob);
//       }
//     });

//     _mediaRecorder!.start();
//     print("🎙️ הקלטה התחילה בדפדפן");
//   }

//   Future<String> stopWebRecordingAndConvertToText() async {
//     final completer = Completer<html.Blob>();

//     _mediaRecorder!.addEventListener('stop', (_) {
//       final fullBlob = html.Blob(_audioChunks);
//       completer.complete(fullBlob);
//     });

//     _mediaRecorder!.stop();
//     final blob = await completer.future;
//     final reader = html.FileReader();
//     reader.readAsArrayBuffer(blob);
//     await reader.onLoad.first;
//     final audioBytes = reader.result as List<int>;
//     final base64Audio = base64Encode(audioBytes);
//     return await convertAudioToTextFromWeb(base64Audio);
//   }

//   Future<void> _saveMessageToFirestore(String text) async {
//     try {
//       await FirebaseFirestore.instance.collection('messages').add({
//         'text': text,
//         'sender': 'user',
//         'timestamp': FieldValue.serverTimestamp(),
//       });
//       print("✅ ההודעה נשמרה ב־Firebase: \$text");
//     } catch (e) {
//       print("❌ שגיאה בשמירה ל־Firebase: \$e");
//     }
//   }

//   Future<void> _speak(String text) async {
//     await _flutterTts.setLanguage("he-IL");
//     await _flutterTts.setPitch(1);
//     await _flutterTts.speak(text);
//   }

//   Future<String> convertAudioToText(String filePath) async {
//     final bytes = await File(filePath).readAsBytes();
//     final base64Audio = base64Encode(bytes);

//     final response = await http.post(
//       Uri.parse('https://speech.googleapis.com/v1/speech:recognize?key=AIzaSyAXP9fkCQUuWTcvMVHsSnz7rDQS7jxLoNg'),
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

//   Future<String> convertAudioToTextFromWeb(String base64Audio) async {
//     final response = await http.post(
//       Uri.parse('https://speech.googleapis.com/v1/speech:recognize?key=AIzaSyAXP9fkCQUuWTcvMVHsSnz7rDQS7jxLoNg'),
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

//     print("📡 קיבלנו תגובה מהשרת: \${response.statusCode}");
//     print("📨 גוף התגובה: \${response.body}");

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

//   Future<void> _sendMessage(String message) async {
//     if (message.trim().isEmpty) return;
//     final chatProvider = Provider.of<ChatProvider>(context, listen: false);
//     chatProvider.addMessage("user", message);

//     await _saveMessageToFirestore(message);

//     setState(() => _isLoading = true);
//     _controller.clear();
//     _scrollToBottom();

//     final response = await getGPTResponse(message, '23');
//     if (response != null) {
//       chatProvider.addMessage("gpt", response);
//       if (_lastInputWasVoice) {
//         await _speak(response); // 🗣️ לקרוא בקול את התשובה
//       }
//     }

//     setState(() => _isLoading = false);
//     _scrollToBottom();
//   }
// =======
  bool _showAvatar = false;
  String? _userId; // ← משתנה גלובלי בתוך ה־State

  final _audioHandler = AudioHandler();
  final _ttsService = TtsService();
  // final _speechService = SpeechService();

  late SpeechService _speechService;

  // String? _userId;
  String? _currentSessionId;
  bool _lastInputWasVoice = false;

  @override
void initState() {
  super.initState();

  print("⚙️ initState started");

  // Assuming _userId is already available at this point:
  _userId = FirebaseAuth.instance.currentUser?.uid;
  if (_userId != null) {
    _speechService = SpeechService();
  }

  FirebaseAuth.instance.authStateChanges().listen((User? user) {
    print("📡 Firebase auth listener activated");

    if (user != null) {
      print("🟢 Logged in as: ${user.email}");
      setState(() {
_userId = user.uid;
      });
        _startNewSession();

      Future.delayed(Duration(seconds: 1), () {
        Provider.of<ChatProvider>(context, listen: false)
            .addMessage("gpt", "ברוך הבא! איך אפשר לעזור?");
      });
    } else {
      print("❌ אין משתמש מחובר כרגע, לא ניתן להתחיל סשן.");
    }
  });
}

  Future<void> _startNewSession() async {
   final newDoc = await FirebaseFirestore.instance
    .collection('chat_sessions')
    .add({
  'userId': _userId, // נוסיף גם מזהה משתמש לשאילתות עתידיות

      'title': 'שיחה חדשה - ${DateTime.now().toLocal()}',
      'createdAt': FieldValue.serverTimestamp(),
    });
    setState(() => _currentSessionId = newDoc.id);
  }

  Future<void> _toggleRecording() async {
    setState(() => _isRecording = !_isRecording);
    if (_isRecording) {
      await _audioHandler.startRecording();
    } else {
      final transcript = await _audioHandler.stopAndTranscribe(kIsWeb);
      await FirestoreService.saveMessage(_userId!, "user", transcript);
      _lastInputWasVoice = true;
      _sendMessage(transcript);
    }
  }

Future<void> _sendMessage(String message) async {
  if (message.trim().isEmpty) return;

  final chatProvider = Provider.of<ChatProvider>(context, listen: false);
  chatProvider.addMessage("user", message);
  await FirestoreService.saveMessage(_userId!, "user", message);

  setState(() => _isLoading = true);
  _controller.clear();
  _scrollToBottom();

  try {
    final response = await getGPTResponse(message, _userId!);
    final reply = response ?? "❌ לא התקבלה תשובה מה-GPT";

    chatProvider.addMessage("gpt", reply);
    if (_lastInputWasVoice) await _ttsService.speak(reply);

    } catch (e) {
      chatProvider.addMessage("gpt", "❌ שגיאה בקבלת תשובה מה-GPT");
    }

    setState(() => _isLoading = false);
    _scrollToBottom();
  }


  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _loadChatFromHistory(String sessionId) async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.clearMessages();

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(_userId!)
        .collection('chat_sessions')
        .doc(sessionId)
        .collection('messages')
        .orderBy('timestamp')
        .get();

    for (var doc in snapshot.docs) {
      chatProvider.addMessage(doc['sender'], doc['text']);
    }

    setState(() => _currentSessionId = sessionId);
    _scrollToBottom();

  }

  Widget _buildInputField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: ChatTextField(
              controller: _controller,
              onSubmitted: _sendMessage,
            ),
          ),
          IconButton(
            icon: Icon(Icons.camera_alt, color: Colors.grey[700]),
            onPressed: () => setState(() => _showAvatar = !_showAvatar),
          ),

          IconButton(
            icon: Icon(
              _isRecording ? Icons.stop : Icons.mic,
              color: _isRecording ? Colors.red : Colors.blue,
            ),
            onPressed: _toggleRecording,
          ),
          SendButton(
            path: 'send',
            onTap: () {
              if (_controller.text.isNotEmpty) {
                FocusScope.of(context).unfocus();
                _lastInputWasVoice = false;
                _sendMessage(_controller.text);
              }
            },
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_userId == null) return Center(child: CircularProgressIndicator());

    final chatProvider = Provider.of<ChatProvider>(context);

    return Scaffold(
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.grey[200],
              child: Column(
                children: [
                  const SettingsPanel(),
                  Expanded(
                    child: ChatHistorySidebar(
                      onSessionSelected: _loadChatFromHistory,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Column(
              children: [
                SizedBox(height: 40.h),
                if (_showAvatar)
                  SizedBox(
                    height: 250,
                    child: ModelViewer(
                      backgroundColor: Colors.white,
                      src: 'assets/avatars/avatar.glb',
                      alt: '3D Avatar',
                      autoRotate: false,
                      iosSrc: 'assets/avatars/avatar.glb',
                      disableZoom: true,
                      disablePan: true,
                      disableTap: true,
                      cameraOrbit: "0deg 90deg 0m",
                      cameraTarget: "0m 1.5m 0m",
                      fieldOfView: "15deg",
                    ),
                  ),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount: chatProvider.messages.length,
                          itemBuilder: (context, index) =>
                              buildMessage(chatProvider.messages[index], context),
                        ),
                      ),
                      _buildInputField(),
                      // ElevatedButton(
                        // onPressed: () async {
                        //   try {
                        //     final result = await PythonAPI.sendEcho("שלום מהצ'אט");
                        //     print("✅ תשובה מהשרת: $result");
                        //     ScaffoldMessenger.of(context).showSnackBar(
                        //       SnackBar(content: Text("שרת ענה: $result")),
                        //     );
                        //   } catch (e) {
                        //     print("❌ שגיאה: $e");
                        //     ScaffoldMessenger.of(context).showSnackBar(
                        //       SnackBar(content: Text("שגיאה בחיבור לשרת")),
                        //     );
                        //   }
                        // },
                        // child: Text("בדוק חיבור לשרת Python"),
                      // ),

                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ],

            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
