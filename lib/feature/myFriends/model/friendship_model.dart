import 'package:cloud_firestore/cloud_firestore.dart';

class FriendshipModel {
  final String? id;
  final String user1Id;
  final String user2Id;
  final String user1Name;
  final String user2Name;
  final String user1Image;
  final String user2Image;
  final DateTime createdAt;

  FriendshipModel({
    this.id,
    required this.user1Id,
    required this.user2Id,
    required this.user1Name,
    required this.user2Name,
    required this.user1Image,
    required this.user2Image,
    required this.createdAt,
  });

  // Empty constructor for default values
  FriendshipModel.empty()
      : id = '',
        user1Id = '',
        user2Id = '',
        user1Name = '',
        user2Name = '',
        user1Image = '',
        user2Image = '',
        createdAt = DateTime.now();

  factory FriendshipModel.fromJson(Map<String, dynamic> json, String id) {
    return FriendshipModel(
      id: id,
      user1Id: json['user1Id'] ?? '',
      user1Name: json['user1Name'] ?? '',
      user1Image: json['user1Image'] ?? '',
      user2Id: json['user2Id'] ?? '',
      user2Name: json['user2Name'] ?? '',
      user2Image: json['user2Image'] ?? '',
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, String> getFriendInfo(String currentUserId) {
    if (currentUserId == user1Id) {
      return {
        'id': user2Id,
        'name': user2Name,
        'image': user2Image,
      };
    } else {
      return {
        'id': user1Id,
        'name': user1Name,
        'image': user1Image,
      };
    }
  }

  String? getFriendId(String currentUserId) {
    if (currentUserId == user1Id) {
      return user2Id;
    } else if (currentUserId == user2Id) {
      return user1Id;
    }
    return null;
  }

  factory FriendshipModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FriendshipModel(
      id: doc.id,
      user1Id: data['user1Id'] ?? '',
      user2Id: data['user2Id'] ?? '',
      user1Name: data['user1Name'] ?? '',
      user2Name: data['user2Name'] ?? '',
      user1Image: data['user1Image'] ?? '',
      user2Image: data['user2Image'] ?? '',
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user1Id': user1Id,
      'user2Id': user2Id,
      'user1Name': user1Name,
      'user2Name': user2Name,
      'user1Image': user1Image,
      'user2Image': user2Image,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
