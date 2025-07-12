import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:movie_proj/feature/auth/model/user_model.dart';
import 'package:movie_proj/feature/myFriends/model/friend_request_model.dart';
import 'package:movie_proj/feature/myFriends/model/friendship_model.dart';

class FriendsService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  static String? get currentUserId => _auth.currentUser?.uid;

  // Collections
  static CollectionReference get _usersCollection =>
      _firestore.collection('users');
  static CollectionReference get _friendRequestsCollection =>
      _firestore.collection('friendRequests');
  static CollectionReference get _friendshipsCollection =>
      _firestore.collection('friendships');

  // Get all users except current user
  static Future<List<UserModel>> getAvailableUsers() async {
    try {
      final currentUser = currentUserId;
      if (currentUser == null) return [];

      if (kDebugMode) {
        debugPrint('\n🔍 === GETTING ALL USERS ===');
        debugPrint('👤 Current user: $currentUser');
      }

      // Get all users except current user - NO OTHER FILTERING
      final QuerySnapshot<Map<String, dynamic>> usersSnapshot =
          await _usersCollection.where('uId', isNotEqualTo: currentUser).get()
              as QuerySnapshot<Map<String, dynamic>>;

      final availableUsers = usersSnapshot.docs.map((doc) {
        final data = doc.data();
        final user = UserModel.fromJson(data);

        if (kDebugMode) {
          debugPrint('📄 Found user: ${user.name} (${user.uId})');
        }

        return user;
      }).toList();

      if (kDebugMode) {
        debugPrint('\n✅ Total users found: ${availableUsers.length}');
        for (var user in availableUsers) {
          debugPrint('   - ${user.name} (${user.uId})');
        }
        debugPrint('=================================\n');
      }

      return availableUsers;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error getting available users: $e');
      }
      return [];
    }
  }

  // Get available users as a stream
  static Stream<List<UserModel>> getAvailableUsersStream() {
    final currentUser = currentUserId;
    if (currentUser == null) return Stream.value([]);

    return _usersCollection
        .where('uId', isNotEqualTo: currentUser)
        .snapshots()
        .map((snapshot) {
      final users = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return UserModel.fromJson(data);
      }).toList();

      if (kDebugMode) {
        debugPrint('\n🔄 Stream update: ${users.length} users found');
        for (var user in users) {
          debugPrint('   - ${user.name} (${user.uId})');
        }
      }

      return users;
    });
  }

  // Get user's friends
  static Future<List<FriendshipModel>> getFriends() async {
    try {
      final currentUser = currentUserId;
      if (currentUser == null) return [];

      final friendshipsSnapshot1 = await _friendshipsCollection
          .where('user1Id', isEqualTo: currentUser)
          .get();

      final friendshipsSnapshot2 = await _friendshipsCollection
          .where('user2Id', isEqualTo: currentUser)
          .get();

      final allFriendships = [
        ...friendshipsSnapshot1.docs,
        ...friendshipsSnapshot2.docs,
      ];

      return allFriendships.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return FriendshipModel.fromJson(data, doc.id);
      }).toList();
    } catch (e) {
      debugPrint('Error getting friends: $e');
      return [];
    }
  }

  // Get friend requests sent by current user
  static Future<List<FriendRequestModel>> getSentFriendRequests() async {
    try {
      final currentUser = currentUserId;
      if (currentUser == null) return [];

      final snapshot = await _friendRequestsCollection
          .where('senderId', isEqualTo: currentUser)
          .where('status', isEqualTo: 'pending')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => FriendRequestModel.fromJsonWithId(
              doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error getting sent friend requests: $e');
      return [];
    }
  }

  // Get pending friend requests (received by current user)
  static Future<List<FriendRequestModel>> getPendingFriendRequests() async {
    try {
      final currentUser = currentUserId;
      if (currentUser == null) return [];

      final snapshot = await _friendRequestsCollection
          .where('receiverId', isEqualTo: currentUser)
          .where('status', isEqualTo: 'pending')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => FriendRequestModel.fromJsonWithId(
              doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error getting pending friend requests: $e');
      return [];
    }
  }

  /// Sends a friend request to another user
  static Future<bool> sendFriendRequest(String receiverId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return false;

      // Get sender's user data
      final senderDoc =
          await _firestore.collection('users').doc(currentUser.uid).get();

      // Get receiver's user data
      final receiverDoc =
          await _firestore.collection('users').doc(receiverId).get();

      if (!senderDoc.exists || !receiverDoc.exists) return false;

      final senderData = senderDoc.data()!;
      final receiverData = receiverDoc.data()!;

      // Create friend request
      final request = FriendRequestModel(
        id: '', // Will be set after creation
        senderId: currentUser.uid,
        senderName: senderData['name'] ?? '',
        senderImage: senderData['image'] ?? '',
        receiverId: receiverId,
        receiverName: receiverData['name'] ?? '',
        receiverImage: receiverData['image'] ?? '',
        status: 'pending',
        createdAt: DateTime.now(),
      );

      // Save to Firestore
      final docRef =
          await _firestore.collection('friendRequests').add(request.toJson());

      // Update the request with the generated ID
      await docRef.update({'id': docRef.id});

      return true;
    } catch (e) {
      debugPrint('Error sending friend request: $e');
      return false;
    }
  }

  /// Accept a friend request
  static Future<bool> acceptFriendRequest(FriendRequestModel request) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return false;

      // Update request status
      await _firestore
          .collection('friendRequests')
          .doc(request.id)
          .update({'status': 'accepted'});

      // Create friendship document
      await _firestore.collection('friendships').add({
        'user1Id': request.senderId,
        'user1Name': request.senderName,
        'user1Image': request.senderImage,
        'user2Id': request.receiverId,
        'user2Name': request.receiverName,
        'user2Image': request.receiverImage,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      debugPrint('Error accepting friend request: $e');
      return false;
    }
  }

  /// Reject a friend request
  static Future<bool> rejectFriendRequest(FriendRequestModel request) async {
    try {
      await _firestore
          .collection('friendRequests')
          .doc(request.id)
          .update({'status': 'rejected'});
      return true;
    } catch (e) {
      debugPrint('Error rejecting friend request: $e');
      return false;
    }
  }

  // Stream of pending friend requests for the current user
  static Stream<List<FriendRequestModel>> listenToPendingFriendRequests() {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return Stream.value([]);

    return _firestore
        .collection('friendRequests')
        .where('receiverId', isEqualTo: currentUserId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => FriendRequestModel.fromJsonWithId(
              doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }

  // Debug method to create test users
  static Future<bool> createTestUsers() async {
    try {
      final currentUser = currentUserId;
      if (currentUser == null) return false;

      final testUsers = [
        {
          'uId': 'test_user_1',
          'name': 'Alice Smith',
          'email': 'alice@test.com',
          'image': 'assets/images/avatar1.png',
        },
        {
          'uId': 'test_user_2',
          'name': 'Bob Johnson',
          'email': 'bob@test.com',
          'image': 'assets/images/avatar2.png',
        },
        {
          'uId': 'test_user_3',
          'name': 'Carol Wilson',
          'email': 'carol@test.com',
          'image': 'assets/images/avatar3.png',
        }
      ];

      for (var userData in testUsers) {
        final userDoc = await _usersCollection.doc(userData['uId']).get();
        if (!userDoc.exists) {
          await _usersCollection.doc(userData['uId']).set(userData);
          debugPrint('Created test user: ${userData['name']}');
        }
      }

      return true;
    } catch (e) {
      debugPrint('Error creating test users: $e');
      return false;
    }
  }

  // Debug method to create a test friend request
  static Future<bool> createTestFriendRequest() async {
    try {
      final currentUser = currentUserId;
      if (currentUser == null) return false;

      await _friendRequestsCollection.add({
        'senderId': 'test_user_123',
        'senderName': 'Test User',
        'senderImage': '',
        'receiverId': currentUser,
        'receiverName': 'Current User',
        'receiverImage': '',
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      debugPrint('Error creating test friend request: $e');
      return false;
    }
  }

  // Debug method to create a test friendship
  static Future<bool> createTestFriendship() async {
    try {
      final currentUser = currentUserId;
      if (currentUser == null) return false;

      await _friendshipsCollection.add({
        'user1Id': currentUser,
        'user1Name': 'Current User',
        'user1Image': '',
        'user2Id': 'test_friend_123',
        'user2Name': 'Test Friend',
        'user2Image': '',
        'createdAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      debugPrint('Error creating test friendship: $e');
      return false;
    }
  }

  // Get all users stream (except current user)
  static Stream<List<UserModel>> getAllUsersStream() {
    final currentUser = currentUserId;
    if (currentUser == null) return Stream.value([]);

    return _usersCollection
        .where('uId', isNotEqualTo: currentUser)
        .snapshots()
        .map((snapshot) {
      final users = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final user = UserModel.fromJson(data);
        debugPrint('Found user: ${user.name} (${user.uId})');
        return user;
      }).toList();

      debugPrint('Total users found: ${users.length}');
      return users;
    });
  }

  // Combined stream for friends page real-time updates
  static Stream<Map<String, dynamic>> listenToFriendsPageUpdates() {
    final currentUser = currentUserId;
    if (currentUser == null)
      return Stream.value({
        'friends': <FriendshipModel>[],
        'requests': <FriendRequestModel>[],
        'users': <UserModel>[],
      });

    // Create a stream controller to combine updates
    final controller = StreamController<Map<String, dynamic>>();
    Map<String, dynamic> latestData = {
      'friends': <FriendshipModel>[],
      'requests': <FriendRequestModel>[],
      'users': <UserModel>[],
    };

    // Listen to friends list
    _friendshipsCollection
        .where(Filter.or(
          Filter('user1Id', isEqualTo: currentUser),
          Filter('user2Id', isEqualTo: currentUser),
        ))
        .snapshots()
        .listen((friendsSnapshot) {
      final friends = friendsSnapshot.docs
          .map((doc) => FriendshipModel.fromJson(
              doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      latestData = {
        ...latestData,
        'friends': friends,
      };
      controller.add(latestData);
    });

    // Listen to friend requests
    _friendRequestsCollection
        .where(Filter.or(
          Filter('senderId', isEqualTo: currentUser),
          Filter('receiverId', isEqualTo: currentUser),
        ))
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .listen((requestsSnapshot) {
      final requests = requestsSnapshot.docs
          .map((doc) => FriendRequestModel.fromJsonWithId(
              doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      latestData = {
        ...latestData,
        'requests': requests,
      };
      controller.add(latestData);
    });

    // Listen to all users
    _usersCollection
        .where('uId', isNotEqualTo: currentUser)
        .snapshots()
        .listen((usersSnapshot) {
      final users = usersSnapshot.docs
          .map((doc) => UserModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      latestData = {
        ...latestData,
        'users': users,
      };
      controller.add(latestData);
    });

    // Return the stream and handle cleanup
    return controller.stream.asBroadcastStream()
      ..listen(null, onDone: () => controller.close());
  }
}
