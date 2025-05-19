import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import '../models/chat_message.dart';
import 'ml_service.dart';

class ChatService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final MLService _mlService = MLService();

  // ML API endpoint
  static const String apiUrl = 'http://127.0.0.1:8080/process_message';

  Future<void> sendMessage(String message) async {

    if (message.trim().isEmpty) return;

    final String currentUserId = _auth.currentUser!.uid;
    final Timestamp timestamp = Timestamp.now();

    try {
      // First, store the message in messages collection
      DocumentReference messageRef = await _firestore.collection('messages').add({
        'text': message,
        'sender': 'user',
        'userId': currentUserId,
        'timestamp': timestamp,
        'predictionScore': null,
        'processedAt': null,
        'status': 'pending'
      });

      print('✅ Message saved to Firestore with ID: ${messageRef.id}');

      // Prepare the request body
      final requestBody = {
        'messageId': messageRef.id,
        'userId': currentUserId,
      };
      
      print('📤 Sending to ML API:');
      print('URL: $apiUrl');
      print('Body: ${jsonEncode(requestBody)}');
      
      // Send message ID to ML API for processing
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      print('📥 Response from ML API:');
      print('Status Code: ${response.statusCode}');
      print('Headers: ${response.headers}');
      print('Body: ${response.body}');

      if (response.statusCode == 200) {
        final prediction = jsonDecode(response.body);
        print('🎯 Prediction received: ${prediction['prediction']}');
        
        // Update the original message with prediction
        await messageRef.update({
          'predictionScore': prediction['prediction'],
          'processedAt': Timestamp.now(),
          'status': 'completed'
        });
        
        print('✅ Updated original message with prediction');

        // Add prediction response to messages collection
        await _firestore.collection('messages').add({
          'text': 'Prediction Score: ${prediction['prediction']}',
          'sender': 'system',
          'userId': currentUserId,
          'timestamp': Timestamp.now(),
          'isPredictionResponse': true,
          'originalMessageId': messageRef.id,
          'status': 'completed'
        });
        
        print('✅ Added prediction response message');
      } else {
        print('❌ Failed to process message:');
        print('Status Code: ${response.statusCode}');
        print('Error Body: ${response.body}');
        
        // Update original message with error status
        await messageRef.update({
          'status': 'error',
          'error': response.body
        });
        
        // Add error message to messages collection
        await _firestore.collection('messages').add({
          'text': 'Failed to process message. Please try again.',
          'sender': 'system',
          'userId': currentUserId,
          'timestamp': Timestamp.now(),
          'isError': true,
          'originalMessageId': messageRef.id,
          'status': 'error'
        });
      }
    } catch (e) {
      print('❌ Error in sendMessage:');
      print('Error: $e');
      print('Stack Trace: ${StackTrace.current}');
      
      // Add error message to messages collection
      await _firestore.collection('messages').add({
        'text': 'An error occurred while processing your message.',
        'sender': 'system',
        'userId': currentUserId,
        'timestamp': Timestamp.now(),
        'isError': true,
        'status': 'error',
        'error': e.toString()
      });
    }
  }

  Stream<QuerySnapshot> getMessages() {
    final String currentUserId = _auth.currentUser!.uid;
    return _firestore
        .collection('messages')
        .where('userId', isEqualTo: currentUserId)
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  Future<void> sendMessageToUser({
    required String userId,
    required String message,
  }) async {
    try {
      final timestamp = Timestamp.now();
      final prediction = await _mlService.getPrediction(message, userId);

      await _firestore.collection('user_predictions').add({
        'userId': userId,
        'text': message,
        'predictedScore': prediction,
        'timestamp': timestamp,
        'sender': 'user',
      });
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  Stream<List<ChatMessage>> getMessagesForUser(String userId) {
    return _firestore
        .collection('user_predictions')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ChatMessage.fromFirestore(doc))
          .toList();
    });
  }
}