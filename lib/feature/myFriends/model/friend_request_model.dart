import 'package:cloud_firestore/cloud_firestore.dart';

class FriendRequestModel {
  final String id;
  final String senderId;
  final String senderName;
  final String senderImage;
  final String receiverId;
  final String receiverName;
  final String receiverImage;
  final String status;
  final DateTime createdAt;

  FriendRequestModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderImage,
    required this.receiverId,
    required this.receiverName,
    required this.receiverImage,
    required this.status,
    required this.createdAt,
  });

  factory FriendRequestModel.fromJson(Map<String, dynamic> json) {
    return FriendRequestModel(
      id: json['id'] ?? '',
      senderId: json['senderId'] ?? '',
      senderName: json['senderName'] ?? '',
      senderImage: json['senderImage'] ?? '',
      receiverId: json['receiverId'] ?? '',
      receiverName: json['receiverName'] ?? '',
      receiverImage: json['receiverImage'] ?? '',
      status: json['status'] ?? 'pending',
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory FriendRequestModel.fromJsonWithId(
      Map<String, dynamic> json, String docId) {
    return FriendRequestModel(
      id: docId,
      senderId: json['senderId'] ?? '',
      senderName: json['senderName'] ?? '',
      senderImage: json['senderImage'] ?? '',
      receiverId: json['receiverId'] ?? '',
      receiverName: json['receiverName'] ?? '',
      receiverImage: json['receiverImage'] ?? '',
      status: json['status'] ?? 'pending',
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'senderImage': senderImage,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'receiverImage': receiverImage,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  FriendRequestModel copyWith({
    String? id,
    String? senderId,
    String? senderName,
    String? senderImage,
    String? receiverId,
    String? receiverName,
    String? receiverImage,
    String? status,
    DateTime? createdAt,
  }) {
    return FriendRequestModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderImage: senderImage ?? this.senderImage,
      receiverId: receiverId ?? this.receiverId,
      receiverName: receiverName ?? this.receiverName,
      receiverImage: receiverImage ?? this.receiverImage,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

enum FriendRequestStatus {
  pending,
  accepted,
  rejected,
}
