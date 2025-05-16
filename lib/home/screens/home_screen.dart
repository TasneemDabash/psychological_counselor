
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
import 'package:flutter/foundation.dart'; 

import '../../ai_chat/provider/chat_provider.dart';
import '../../ai_chat/widgets/build_message.dart';
import '../../ai_chat/widgets/chat_text_field.dart';
import '../../ai_chat/widgets/send_button.dart';
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
