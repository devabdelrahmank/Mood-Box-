import 'package:flutter/material.dart';
import 'package:movie_proj/core/my_colors.dart';
import 'package:movie_proj/core/my_styles.dart';
import 'package:movie_proj/core/spacing.dart';
import 'package:movie_proj/feature/chat/model/chat_message_model.dart';
import 'package:movie_proj/feature/chat/service/chat_service.dart';
import 'package:movie_proj/feature/myFriends/service/friends_service.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  final String friendName;
  final String friendImage;
  final String friendId;

  const ChatScreen({
    Key? key,
    required this.friendName,
    required this.friendImage,
    required this.friendId,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  String? _currentUserImage;

  @override
  void initState() {
    super.initState();
    _markMessagesAsRead();
    _loadCurrentUserImage();
  }

  Future<void> _loadCurrentUserImage() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();
        if (userDoc.exists) {
          setState(() {
            _currentUserImage = userDoc.data()?['image'];
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading user image: $e');
    }
  }

  void _markMessagesAsRead() {
    final chatRoomId = ChatService.getChatRoomId(
      FriendsService.currentUserId ?? '',
      widget.friendId,
    );
    ChatService.markMessagesAsRead(chatRoomId, widget.friendId);
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    setState(() => _isLoading = true);

    try {
      await ChatService.sendMessage(
        receiverId: widget.friendId,
        content: _messageController.text.trim(),
      );
      _messageController.clear();

      // Scroll to bottom after sending
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.primaryColor,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: widget.friendImage.isNotEmpty
                  ? NetworkImage(widget.friendImage) as ImageProvider
                  : const AssetImage('assets/images/profile.png'),
            ),
            hSpace(10),
            Text(
              widget.friendName,
              style: MyStyles.title24White700.copyWith(fontSize: 18),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: ChatService.getMessages(widget.friendId),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!;
                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe =
                        message.senderId == FriendsService.currentUserId;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisAlignment: isMe
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        children: [
                          if (!isMe) ...[
                            CircleAvatar(
                              radius: 16,
                              backgroundImage: widget.friendImage.isNotEmpty
                                  ? NetworkImage(widget.friendImage)
                                  : const AssetImage(
                                          'assets/images/profile.png')
                                      as ImageProvider,
                            ),
                            hSpace(8),
                          ],
                          Container(
                            constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.65,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isMe
                                  ? MyColors.primaryColor
                                  : Colors.grey[300],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              crossAxisAlignment: isMe
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                Text(
                                  message.content,
                                  style: TextStyle(
                                    color: isMe ? Colors.white : Colors.black,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  DateFormat('HH:mm').format(message.timestamp),
                                  style: TextStyle(
                                    color:
                                        isMe ? Colors.white70 : Colors.black54,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isMe) ...[
                            hSpace(8),
                            CircleAvatar(
                              radius: 16,
                              backgroundImage: _currentUserImage != null &&
                                      _currentUserImage!.isNotEmpty
                                  ? NetworkImage(_currentUserImage!)
                                      as ImageProvider
                                  : const AssetImage(
                                      'assets/images/profile.png'),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                hSpace(8),
                Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: MyColors.primaryColor,
                  ),
                  child: IconButton(
                    onPressed: _isLoading ? null : _sendMessage,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(
                            Icons.send,
                            color: Colors.white,
                          ),
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
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
