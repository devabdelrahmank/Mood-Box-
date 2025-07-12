import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String messageId;
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime timestamp;
  final bool isRead;

  ChatMessage({
    required this.messageId,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.timestamp,
    this.isRead = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'messageId': messageId,
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      messageId: map['messageId'] ?? '',
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      content: map['content'] ?? '',
      timestamp:
          DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
      isRead: map['isRead'] ?? false,
    );
  }

  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatMessage.fromMap({
      ...data,
      'messageId': doc.id,
    });
  }
}
