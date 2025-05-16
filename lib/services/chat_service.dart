import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_message.dart';
import 'ml_service.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final MLService _mlService = MLService();

  Future<void> sendMessage({
    required String userId,
    required String message,
  }) async {
    try {
      // First, save the message to Firestore
      final docRef = await _firestore.collection('messages').add({
        'userId': userId,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Get prediction from ML service
      final prediction = await _mlService.getPrediction(message, userId);

      // Update the document with the prediction
      await docRef.update({
        'predictionScore': prediction,
      });
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  Stream<List<ChatMessage>> getMessages(String userId) {
    return _firestore
        .collection('messages')
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