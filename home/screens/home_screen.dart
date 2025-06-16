
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:provider/provider.dart';
// import 'package:model_viewer_plus/model_viewer_plus.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:phychological_counselor/data/services/gpt_service.dart';

// import 'package:http/http.dart' as http;
// import 'dart:convert';

// import 'package:phychological_counselor/home/screens/audio_handler.dart';
// import 'package:phychological_counselor/home/screens/firestore_service.dart';
// import 'package:phychological_counselor/home/screens/speech_service.dart';
// import 'package:flutter/foundation.dart'; 
// import 'package:phychological_counselor/frontend/home_screenDesign2.dart';
// import 'package:phychological_counselor/frontend/chat_side_panel.dart';

// import '../../ai_chat/provider/chat_provider.dart';
// import '../../ai_chat/widgets/build_message.dart';
// import '../../ai_chat/widgets/chat_text_field.dart';
// import '../../ai_chat/widgets/send_button.dart';
// //import '../../frontend/settings_panel.dart';
// import '../../ai_chat/widgets/chat_history_sidebar.dart';
// import 'package:phychological_counselor/frontend/home_screenDesign.dart';


// import 'tts_service.dart';


// class HomeScreen extends StatefulWidget {
//   const HomeScreen({Key? key}) : super(key: key);

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   final TextEditingController _controller = TextEditingController();
//   final ScrollController _scrollController = ScrollController();
//   bool _isLoading = false;
//   bool _isRecording = false;
//   bool _showAvatar = false;
//   String? _userId; // ← משתנה גלובלי בתוך ה־State
// //bool _showSettings = false;
//   bool _showSidePanel = false;

//   final _audioHandler = AudioHandler();
//   final _ttsService = TtsService();
//   // final _speechService = SpeechService();

//   late SpeechService _speechService;

//   // String? _userId;
//   String? _currentSessionId;
//   bool _lastInputWasVoice = false;

//   @override
// void initState() {
//   super.initState();

//   print("⚙️ initState started");

//   // Assuming _userId is already available at this point:
//   _userId = FirebaseAuth.instance.currentUser?.uid;
//   if (_userId != null) {
//     _speechService = SpeechService();
//   }

//   FirebaseAuth.instance.authStateChanges().listen((User? user) {
//     print("📡 Firebase auth listener activated");

//     if (user != null) {
//       print("🟢 Logged in as: ${user.email}");
//       setState(() {
// _userId = user.uid;
//       });
//         _startNewSession();

//       Future.delayed(Duration(seconds: 1), () {
//     //    Provider.of<ChatProvider>(context, listen: false)
//           //  .addMessage("gpt", "ברוך הבא! איך אפשר לעזור?");
//       });
//     } else {
//       print("❌ אין משתמש מחובר כרגע, לא ניתן להתחיל סשן.");
//     }
//   });
// }

//   Future<void> _startNewSession() async {
//    final newDoc = await FirebaseFirestore.instance
//     .collection('chat_sessions')
//     .add({
//   'userId': _userId, // נוסיף גם מזהה משתמש לשאילתות עתידיות

//       'title': 'שיחה חדשה - ${DateTime.now().toLocal()}',
//       'createdAt': FieldValue.serverTimestamp(),
//     });
//     setState(() => _currentSessionId = newDoc.id);
//   }

//   Future<void> _toggleRecording() async {
//     setState(() => _isRecording = !_isRecording);
//     if (_isRecording) {
//       await _audioHandler.startRecording();
//     } else {
//       final transcript = await _audioHandler.stopAndTranscribe(kIsWeb);
//       setState(() => _isRecording = false); // 🟢 כאן חשוב לעדכן את ה־UI!

//       await FirestoreService.saveMessage(_userId!, "user", transcript);
//       _lastInputWasVoice = true;
//       _sendMessage(transcript);
//     }
//   }

// Future<void> _sendMessage(String message) async {
//   if (message.trim().isEmpty) return;
// if (_isRecording) {
//     // אם המשתמש התחיל להקליט ואז שלח טקסט → עוצרים את ההקלטה
//     final transcript = await _audioHandler.stopAndTranscribe(kIsWeb);
//     setState(() => _isRecording = false);
//     await FirestoreService.saveMessage(_userId!, "user", transcript);
//     Provider.of<ChatProvider>(context, listen: false).addMessage("user", transcript);
//   }
//   final chatProvider = Provider.of<ChatProvider>(context, listen: false);
//   chatProvider.addMessage("user", message);
//   await FirestoreService.saveMessage(_userId!, "user", message);

//   setState(() => _isLoading = true);
//   _controller.clear();
//   _scrollToBottom();

//   try {
//     final response = await getGPTResponse(message, _userId!);
//     final reply = response ?? "❌ לא התקבלה תשובה מה-GPT";

//     chatProvider.addMessage("gpt", reply);
//     await FirestoreService.saveMessage(_userId!, "gpt", reply);

//     if (_lastInputWasVoice) await _ttsService.speak(reply);

//     } catch (e) {
//       chatProvider.addMessage("gpt", "❌ שגיאה בקבלת תשובה מה-GPT");
//     }

//     setState(() => _isLoading = false);
//     _scrollToBottom();
//   }


//   void _scrollToBottom() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (_scrollController.hasClients) {
//         _scrollController.animateTo(
//           _scrollController.position.maxScrollExtent,
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeOut,
//         );
//       }
//     });
//   }

//   void _loadChatFromHistory(String sessionId) async {
//     final chatProvider = Provider.of<ChatProvider>(context, listen: false);
//     chatProvider.clearMessages();

//     final snapshot = await FirebaseFirestore.instance
//         .collection('users')
//         .doc(_userId!)
//         .collection('chat_sessions')
//         .doc(sessionId)
//         .collection('messages')
//         .orderBy('timestamp')
//         .get();

//     for (var doc in snapshot.docs) {
//       chatProvider.addMessage(doc['sender'], doc['text']);
//     }

//     setState(() => _currentSessionId = sessionId);
//     _scrollToBottom();

//   }

//   Widget _buildInputField() {
//   return Padding(
//     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//     child: Container(
//                   height: 40, // כאן קבענו גובה קבוע של 50 פיקסלים – אפשר לנסות ערכים אחרים

//       padding: const EdgeInsets.symmetric(horizontal: 12),
//       decoration: BoxDecoration(
//     color: Colors.grey[100],               // רקע בהיר לתיבה
//     borderRadius: BorderRadius.circular(30), // פינות עגולות
//     border: Border.all(color: Colors.grey.shade400), // מסגרת דקה אפורה
//       ),
//        // padding: const EdgeInsets.symmetric(horizontal: 16),

//       child: Row(
//         children: [
//         Expanded(
//   child: TextField(
//     controller: _controller,
//     enabled: !_isRecording,
//     onSubmitted: _sendMessage,
//     decoration: InputDecoration(
//       hintText: "Type your message...",
//       hintStyle: TextStyle(
//         fontSize: 14,             // גופן קטן יותר ל-hint
//         color: Colors.grey[600],  // צבע מעט חלש יותר
//       ),
//       border: InputBorder.none,
//       isDense: true,
//       contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
//     ),
//     style: const TextStyle(fontSize: 18),  // גודל גופן רגיל כשכותבים
//   ),
// ),

//           IconButton(
//             icon: const Icon(Icons.camera_alt, size: 20),
//             onPressed: () => setState(() => _showAvatar = !_showAvatar),
//             tooltip: "Toggle Avatar",
//           ),
//           // IconButton(
//           //   icon: Icon(_isRecording ? Icons.stop : Icons.mic,
//           //       size: 20, color: _isRecording ? Colors.red : Colors.blue),
//           //   onPressed: _toggleRecording,
//           //   tooltip: "Record Voice",
//           // ),
//           IconButton(
//             icon: const Icon(Icons.send, size: 20),
//             onPressed: () {
//                   if (_isRecording || _isLoading) return; // ✅ הוספה חשובה כאן

//               if (_controller.text.isNotEmpty) {
//                 FocusScope.of(context).unfocus();
//                 _lastInputWasVoice = false;
//                 _sendMessage(_controller.text);
//               }
//             },
//             tooltip: "Send Message",
//           ),
//         ],
//       ),
//     ),
//   );
// }


//   @override
//   Widget build(BuildContext context) {
//     if (_userId == null) return Center(child: CircularProgressIndicator());

//     final chatProvider = Provider.of<ChatProvider>(context);

//     return Scaffold(
//   body: Stack(
//     children: [
//       // 👈 זה ה־Row הקיים שלך – אל תשכחי לשים כאן את כל הקוד של Row כמו שיש לך
//    Row(
//   children: [
//     Expanded(
//       flex: 1, // כעת זה היחיד, יתפוס 100% מהרגש
//       child: Column(
//         children: [
//           SizedBox(height: 40.h),
//           if (_showAvatar)
//             SizedBox(
//               height: 250,
//               child: ModelViewer(
//                 backgroundColor: Colors.white,
//                 src: 'assets/avatars/avatar.glb',
//                 alt: '3D Avatar',
//                 autoRotate: false,
//                 iosSrc: 'assets/avatars/avatar.glb',
//                 disableZoom: true,
//                 disablePan: true,
//                 disableTap: true,
//                 cameraOrbit: "0deg 90deg 0m",
//                 cameraTarget: "0m 1.5m 0m",
//                 fieldOfView: "15deg",
//               ),
//             ),
//           Expanded(
//             child: Column(
//               children: [
//                 Expanded(
//                   child: chatProvider.messages.isEmpty
//                       ? const Center(
//                           child: Text(
//                             "Welcome! How can I help?",
//                             style: TextStyle(
//                               fontSize: 22,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.black87,
//                             ),
//                             textAlign: TextAlign.center,
//                           ),
//                         )
//                       : ListView.builder(
//                           controller: _scrollController,
//                           padding: EdgeInsets.only(
//                             top: 60.0,
//                             right: 16.0,
//                             bottom: 16.0,
//                             left: 16,
//                           ),
//                           itemCount: chatProvider.messages.length,
//                           itemBuilder: (context, index) =>
//                               buildMessage(
//                                   chatProvider.messages[index], context),
//                         ),
//                 ),
//                 _buildInputField(),
//                 SizedBox(height: 20.h),
//               ],
//             ),
//           ),
//         ],
//       ),
//     ),
//   ],
// ),
// ChatSidePanel(
//           isOpen: _showSidePanel,
//           onClose: () {
//             setState(() {
//               _showSidePanel = false;
//             });
//           },
//           onNewConversation: () {
//             // לחיצה על "New Conversation" – יוצרת סשן חדש וסוגרת את הלוח:
//             _startNewSession();
//             setState(() {
//               _showSidePanel = false;
//             });
//           },
//           onSearch: () {
//             // לחיצה על "Search"
//             print('Search clicked!');
//             setState(() {
//               _showSidePanel = false;
//             });
//           },
//         ),

//         // =============================================
//         // 4. לחצן ה־Hamburger (שלוש פסים) שמוצב בפינת המסך
//         Positioned(
//           top: 12,
//           left: 12,
//           child: SafeArea(
//             child: IconButton(
//               icon: const Icon(Icons.menu, size: 28, color: Colors.black87),
//               onPressed: () {
//                 setState(() {
//                   _showSidePanel = !_showSidePanel;
//                 });
//               },
//             //  tooltip: 'Toggle Chat Panel',
//             ),
//           ),
//         ),

//                 const HomeScreenDesign(),
//                   const HomeScreenDesign2(),

//     ],
//   ),
// );
//   } 
//   @override
//   void dispose() {
//     _scrollController.dispose();
//     super.dispose();

//   }
//   void _showProfileDialog() {
//   showDialog(
//     context: context,
//     builder: (context) => AlertDialog(
//       title: const Text("👤 My Profile"),
//       content: const Text("כאן יופיע פרופיל המשתמש..."),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.of(context).pop(),
//           child: const Text("סגור"),
//           ),
//         ],
//       ),
//     );
//   }
// }

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
import 'package:phychological_counselor/frontend/home_screenDesign2.dart';
import 'package:phychological_counselor/frontend/chat_side_panel.dart';

import '../../ai_chat/provider/chat_provider.dart';
import '../../ai_chat/widgets/build_message.dart';
import '../../ai_chat/widgets/chat_text_field.dart';
import '../../ai_chat/widgets/send_button.dart';
//import '../../frontend/settings_panel.dart';
import '../../ai_chat/widgets/chat_history_sidebar.dart';
import 'package:phychological_counselor/frontend/home_screenDesign.dart';


import 'tts_service.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
  const double kHeaderHeight = 64.0;

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  bool _isRecording = false;
  bool _showAvatar = false;
  String? _userId; // ← משתנה גלובלי בתוך ה־State
//bool _showSettings = false;
  bool _showSidePanel = false;

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
    //    Provider.of<ChatProvider>(context, listen: false)
          //  .addMessage("gpt", "ברוך הבא! איך אפשר לעזור?");
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
      setState(() => _isRecording = false); // 🟢 כאן חשוב לעדכן את ה־UI!

      await FirestoreService.saveMessage(_userId!, "user", transcript);
      _lastInputWasVoice = true;
      _sendMessage(transcript);
    }
  }

Future<void> _sendMessage(String message) async {
  if (message.trim().isEmpty) return;
if (_isRecording) {
    // אם המשתמש התחיל להקליט ואז שלח טקסט → עוצרים את ההקלטה
    final transcript = await _audioHandler.stopAndTranscribe(kIsWeb);
    setState(() => _isRecording = false);
    await FirestoreService.saveMessage(_userId!, "user", transcript);
    Provider.of<ChatProvider>(context, listen: false).addMessage("user", transcript);
  }
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
    await FirestoreService.saveMessage(_userId!, "gpt", reply);

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

//   Widget _buildInputField() {
//   return Padding(
//     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//      child: ConstrainedBox(
//       // נגדיר כאן תנאי גובה מינימלי ומקסימלי לשורת ההודעות
//       constraints: BoxConstraints(
//         minHeight: 48.0,   // גובה מינימלי בשורות בודדות (לדוגמה 1 שורה)
//         maxHeight: 150.0,  // גובה מקסימלי (ללא אינסוף גלילה; לדוגמה עד 5-6 שורות)
//       ),
//     child: Container(
// //                  height: 40, // כאן קבענו גובה קבוע של 50 פיקסלים – אפשר לנסות ערכים אחרים

//       padding: const EdgeInsets.symmetric(horizontal: 12),
//       decoration: BoxDecoration(
//     color: Colors.grey[100],               // רקע בהיר לתיבה
//     borderRadius: BorderRadius.circular(30), // פינות עגולות
//     border: Border.all(color: Colors.grey.shade400), // מסגרת דקה אפורה
//       ),
//        // padding: const EdgeInsets.symmetric(horizontal: 16),

//       child: Row(
//          crossAxisAlignment: CrossAxisAlignment.end,

//         children: [
//         Expanded(
//   child: TextField(
//     controller: _controller,
//     enabled: !_isRecording,
//     keyboardType: TextInputType.multiline,
//                 textInputAction: TextInputAction.newline,
//                 minLines: 1,           // לפחות שורה אחת
//                 maxLines: null,        // אפשר להתרחב עד הגבלת ה־maxHeight שב־ConstrainedBox
//     onSubmitted: _sendMessage,
//   },
//     decoration: const InputDecoration(
//                   hintText: "Type your message...",
                   
//       hintStyle: TextStyle(
//         fontSize: 14,             // גופן קטן יותר ל-hint
//         color: Colors.grey[600],  // צבע מעט חלש יותר
//       ),
//       border: InputBorder.none,
//       isDense: true,
//       contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
//     ),
//     style: const TextStyle(fontSize: 18),  // גודל גופן רגיל כשכותבים
//   ),
// ),

//           IconButton(
//             icon: const Icon(Icons.camera_alt, size: 20),
//             onPressed: () => setState(() => _showAvatar = !_showAvatar),
//             tooltip: "Toggle Avatar",
//           ),
//           // IconButton(
//           //   icon: Icon(_isRecording ? Icons.stop : Icons.mic,
//           //       size: 20, color: _isRecording ? Colors.red : Colors.blue),
//           //   onPressed: _toggleRecording,
//           //   tooltip: "Record Voice",
//           // ),
//           IconButton(
//             icon: const Icon(Icons.send, size: 20),
//             onPressed: () {
//                   if (_isRecording || _isLoading) return; // ✅ הוספה חשובה כאן

//               if (_controller.text.isNotEmpty) {
//                 FocusScope.of(context).unfocus();
//                 _lastInputWasVoice = false;
//                 _sendMessage(_controller.text);
//               }
//             },
//             tooltip: "Send Message",
//          ),
//           ],
//         ),
//       ),
//     ),
//   );
// }
// Widget _buildInputField() {
//       padding: const EdgeInsets.symmetric(vertical: 12),

//   return Padding(
//     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//     child: ConstrainedBox(
//       // נגדיר כאן תנאי גובה מינימלי ומקסימלי לשורת ההודעות
//       constraints: const BoxConstraints(
//         minHeight: 48.0,   // גובה מינימלי (1 שורה)
//         maxHeight: 150.0,  // גובה מקסימלי (עד כ־4–5 שורות)
//       ),
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 12),
//         decoration: BoxDecoration(
//           color: Colors.grey[100],                // רקע בהיר לתיבה
//           borderRadius: BorderRadius.circular(30),// פינות עגולות
//           border: Border.all(color: Colors.grey.shade400), // מסגרת דקה אפורה
//         ),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.end, // התאמת האייקונים לתחתית
//           children: [
//             Expanded(
//               child: TextField(
//                 controller: _controller,
//                 enabled: !_isRecording,
//                 keyboardType: TextInputType.multiline,
//                 textInputAction: TextInputAction.newline,
//                 minLines: 1,           // לפחות שורה אחת
//                 maxLines: null,        // יוכל להתרועע עד גבול ה־maxHeight ב־ConstrainedBox
//                 onSubmitted: (text) {
//                   // בשימוש בסמל ה־Send ברור שה־Enter יוריד שורה, 
//                   // אם רוצים שה־Enter ישלח, יש לשנות ל־TextInputAction.send
//                   _sendMessage(text);
//                 },
//                 decoration: const InputDecoration(
//                   hintText: "Type your message...",
//                   hintStyle: TextStyle(
//                     fontSize: 14,             // גופן קטן ל־hint
//                     color: Colors.grey,       // צבע מעט חלש יותר
//                   ),
//                   border: InputBorder.none,
//                   isDense: true,
//                   contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
//                 ),
//                 style: const TextStyle(fontSize: 18),  // גודל גופן רגיל כשכותבים
//               ),
//             ),

//             // כפתור מצלמה (Toggle Avatar לדוגמה)
//             IconButton(
//               icon: const Icon(Icons.camera_alt, size: 20),
//               onPressed: () => setState(() => _showAvatar = !_showAvatar),
//               tooltip: "Toggle Avatar",
//             ),

//             // כפתור “שליחה”
//             IconButton(
//               icon: const Icon(Icons.send, size: 20),
//               onPressed: () {
//                 if (_isRecording || _isLoading) return; 
//                 final text = _controller.text.trim();
//                 if (text.isNotEmpty) {
//                   FocusScope.of(context).unfocus();
//                   _lastInputWasVoice = false;
//                   _sendMessage(text);
//                 }
//               },
//               tooltip: "Send Message",
//             ),
//           ],
//         ),
//       ),
//     ),
//   );
// }

Widget _buildInputField() {
  // נגדיר כאן רוחב מקסימלי לשורת ההודעות – למשל 80% מרוחב המסך
  final double maxWidth = MediaQuery.of(context).size.width * 0.8;

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Align(
      alignment: Alignment.center, 
      // אפשר לשנות ל־Alignment.centerRight/centerLeft אם רוצים למקם לצד מסוים
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: 48.0,
          maxHeight: 150.0,
          maxWidth: maxWidth,  // ☆ כאן אנחנו מגבילים את הרוחב
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.grey.shade400),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  enabled: !_isRecording,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  minLines: 1,
                  maxLines: null,
                  onSubmitted: (text) {
                    _sendMessage(text);
                  },
                  decoration: const InputDecoration(
                    hintText: "Type your message...",
                    hintStyle: TextStyle(
                      fontSize: 20,
                      color: Colors.grey,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  ),
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.camera_alt, size: 20),
                onPressed: () => setState(() => _showAvatar = !_showAvatar),
                tooltip: "Toggle Avatar",
              ),
              IconButton(
                icon: const Icon(Icons.send, size: 20),
                onPressed: () {
                  if (_isRecording || _isLoading) return;
                  final text = _controller.text.trim();
                  if (text.isNotEmpty) {
                    FocusScope.of(context).unfocus();
                    _lastInputWasVoice = false;
                    _sendMessage(text);
                  }
                },
                tooltip: "Send Message",
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    if (_userId == null) return Center(child: CircularProgressIndicator());

    final chatProvider = Provider.of<ChatProvider>(context);
    const double sidePanelWidth = 250.0;

    return Scaffold(
            body: SafeArea( // ← עטיפת כל התוכן ב־SafeArea

  child: Stack(
    children: [
       AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
          //    height:80.h,
              left: _showSidePanel ? sidePanelWidth : 0, // אם פתוח → מתחילים ב־240px, אחרת 0
              right: 0, // תמיד נשמור על הקצה הימני ב־0, כדי שהתיבה לא תהייה מתחת לפאנל
              top: 0,
              bottom: 0,
                     child: Column(
                children: [
              SizedBox(height: kHeaderHeight),

              Expanded(
                child: Row(
  children: [
    Expanded(
    //  flex: 1, // כעת זה היחיד, יתפוס 100% מהרגש
      child: Column(
        children: [
        //  SizedBox(height: 40.h),
    //    SizedBox(height: MediaQuery.of(context).padding.top),

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
                  child: chatProvider.messages.isEmpty
                      ? const Center(
                          child: Text(
                          "Welcome! How can I help?",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
padding: const EdgeInsets.only(
    left: 16.0,
    right: 16.0,   // ← הריווח הימני הנוסף למניעת חפיפה
    bottom: 16.0,
  ),
                          itemCount: chatProvider.messages.length,
                          itemBuilder: (context, index) =>
                              buildMessage(
                                  chatProvider.messages[index], context),
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
                ),
              ],
            ),
            ),
ChatSidePanel(
          isOpen: _showSidePanel,
          onClose: () {
            setState(() {
              _showSidePanel = false;
            });
          },
          onNewConversation: () {
            // לחיצה על "New Conversation" – יוצרת סשן חדש וסוגרת את הלוח:
            _startNewSession();
            setState(() {
              _showSidePanel = false;
            });
          },
          onSearch: () {
            // לחיצה על "Search"
            print('Search clicked!');
            setState(() {
              _showSidePanel = false;
            });
          },
        ),

        // =============================================
        // 4. לחצן ה־Hamburger (שלוש פסים) שמוצב בפינת המסך
        Positioned(
          top: 0,
          left: 0,
           child: SizedBox(
              height: kHeaderHeight,
          child: SafeArea(
            child: IconButton(
              icon: const Icon(Icons.menu, size: 28, color: Colors.black87),
              onPressed: () {
                setState(() {
                  _showSidePanel = !_showSidePanel;
                });
              },
            //  tooltip: 'Toggle Chat Panel',
            ),
          ),
        ),
      ),
        Positioned(
            top: 0,
            right: 48, // הרחקנו טיפה שמאלה כדי שיהיה מרווח מהפרופיל
            child: SizedBox(
              height: kHeaderHeight,
              child: SafeArea(
                child: Row(
                  children: [
                    // הכפתור של “שלוש הנקודות”
                    // IconButton(
                    //   icon: const Icon(Icons.more_vert, color: Colors.black87),
                    //   onPressed: () {
                    //     // … פעולה כלשהי …
                    //   },
                    // ),
                    const SizedBox(width: 8),
                    // האייקון של הפרופיל
                    // Icon(
                    //   Icons.account_circle,
                    //   size: 28,
                    //   color: Colors.indigo,
                    // ),
                                   const SizedBox(width: 16),
                  ],
                ),
              ),
            ),
          ),

                const HomeScreenDesign(),
                  const HomeScreenDesign2(),

    ],
      ),
    ),
  );
  }
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();

  }
  void _showProfileDialog() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("👤 My Profile"),
      content: const Text("כאן יופיע פרופיל המשתמש..."),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("סגור"),
          ),
        ],
      ),
    );
  }
}
