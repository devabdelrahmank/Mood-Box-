import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:movie_proj/feature/chat/model/chat_message_model.dart';
import 'package:movie_proj/feature/myFriends/service/friends_service.dart';

class ChatService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get chat room ID (consistent for both users)
  static String getChatRoomId(String userId1, String userId2) {
    // Sort IDs to ensure consistent chat room ID
    final sortedIds = [userId1, userId2]..sort();
    return '${sortedIds[0]}_${sortedIds[1]}';
  }

  // Send a message
  static Future<void> sendMessage({
    required String receiverId,
    required String content,
  }) async {
    final currentUserId = FriendsService.currentUserId;
    if (currentUserId == null) return;

    final chatRoomId = getChatRoomId(currentUserId, receiverId);
    final messageId = _firestore
        .collection('chats')
        .doc(chatRoomId)
        .collection('messages')
        .doc()
        .id;

    final message = ChatMessage(
      messageId: messageId,
      senderId: currentUserId,
      receiverId: receiverId,
      content: content,
      timestamp: DateTime.now(),
    );

    await _firestore
        .collection('chats')
        .doc(chatRoomId)
        .collection('messages')
        .doc(messageId)
        .set(message.toMap());

    // Update last message in chat room
    await _firestore.collection('chats').doc(chatRoomId).set({
      'lastMessage': content,
      'lastMessageTime': DateTime.now().toIso8601String(),
      'participants': [currentUserId, receiverId],
    }, SetOptions(merge: true));
  }

  // Listen to messages in a chat room
  static Stream<List<ChatMessage>> getMessages(String receiverId) {
    final currentUserId = FriendsService.currentUserId;
    if (currentUserId == null) {
      return Stream.value([]);
    }

    final chatRoomId = getChatRoomId(currentUserId, receiverId);

    return _firestore
        .collection('chats')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ChatMessage.fromFirestore(doc))
          .toList();
    });
  }

  // Mark messages as read
  static Future<void> markMessagesAsRead(
      String chatRoomId, String senderId) async {
    final currentUserId = FriendsService.currentUserId;
    if (currentUserId == null) return;

    final messagesQuery = await _firestore
        .collection('chats')
        .doc(chatRoomId)
        .collection('messages')
        .where('senderId', isEqualTo: senderId)
        .where('receiverId', isEqualTo: currentUserId)
        .where('isRead', isEqualTo: false)
        .get();

    final batch = _firestore.batch();
    for (var doc in messagesQuery.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  // Get unread message count
  static Stream<int> getUnreadMessageCount(String chatRoomId) {
    final currentUserId = FriendsService.currentUserId;
    if (currentUserId == null) {
      return Stream.value(0);
    }

    return _firestore
        .collection('chats')
        .doc(chatRoomId)
        .collection('messages')
        .where('receiverId', isEqualTo: currentUserId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
}
