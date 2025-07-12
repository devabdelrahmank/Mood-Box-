import 'package:flutter/material.dart';
import 'package:movie_proj/core/my_colors.dart';
import 'package:movie_proj/core/my_images.dart';
import 'package:movie_proj/core/my_styles.dart';
import 'package:movie_proj/core/spacing.dart';
import 'package:movie_proj/feature/auth/model/user_model.dart';

import 'package:movie_proj/feature/myFriends/service/friends_service.dart';

class AvailableUsersGrid extends StatelessWidget {
  const AvailableUsersGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<UserModel>>(
      stream: FriendsService.getAllUsersStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        if (snapshot.hasError) {
          debugPrint('Error in stream: ${snapshot.error}');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                vSpace(16),
                Text(
                  'Error loading users',
                  style: MyStyles.title24White400.copyWith(
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          );
        }

        final users = snapshot.data ?? [];
        debugPrint('Found ${users.length} users');

        if (users.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.people_outline,
                  size: 64,
                  color: Colors.white.withOpacity(0.5),
                ),
                vSpace(16),
                Text(
                  'No users found',
                  style: MyStyles.title24White400.copyWith(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.8,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            debugPrint('Building card for user: ${user.name} (${user.uId})');
            return _buildUserCard(context, user);
          },
        );
      },
    );
  }

  Widget _buildUserCard(BuildContext context, UserModel user) {
    return FutureBuilder<UserStatus>(
      future: _getUserStatus(user.uId!),
      builder: (context, snapshot) {
        final status = snapshot.data ?? UserStatus.available;

        return Container(
          decoration: BoxDecoration(
            color: MyColors.secondaryColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage(
                      user.image?.isNotEmpty == true
                          ? user.image!
                          : MyImages.profilePic,
                    ),
                  ),
                  if (status != UserStatus.available)
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(status),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: MyColors.secondaryColor,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        _getStatusIcon(status),
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                ],
              ),
              vSpace(12),
              Text(
                user.name ?? 'Unknown User',
                style: MyStyles.title24White700.copyWith(
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              vSpace(8),
              _buildActionButton(context, user, status),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButton(
      BuildContext context, UserModel user, UserStatus status) {
    switch (status) {
      case UserStatus.friend:
        return ElevatedButton.icon(
          onPressed: null,
          icon: const Icon(Icons.check_circle),
          label: const Text('Friend'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.withOpacity(0.3),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        );
      case UserStatus.pendingSent:
        return ElevatedButton.icon(
          onPressed: null,
          icon: const Icon(Icons.hourglass_empty),
          label: const Text('Pending'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange.withOpacity(0.3),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        );
      case UserStatus.pendingReceived:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () => _acceptFriendRequest(context, user),
              icon: const Icon(Icons.check, color: Colors.green),
              tooltip: 'Accept',
            ),
            IconButton(
              onPressed: () => _rejectFriendRequest(context, user),
              icon: const Icon(Icons.close, color: Colors.red),
              tooltip: 'Reject',
            ),
          ],
        );
      case UserStatus.available:
        return ElevatedButton(
          onPressed: () => _sendFriendRequest(context, user),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Text('Add Friend'),
        );
    }
  }

  Color _getStatusColor(UserStatus status) {
    switch (status) {
      case UserStatus.friend:
        return Colors.green;
      case UserStatus.pendingSent:
        return Colors.orange;
      case UserStatus.pendingReceived:
        return Colors.blue;
      case UserStatus.available:
        return Colors.transparent;
    }
  }

  IconData _getStatusIcon(UserStatus status) {
    switch (status) {
      case UserStatus.friend:
        return Icons.check;
      case UserStatus.pendingSent:
        return Icons.hourglass_empty;
      case UserStatus.pendingReceived:
        return Icons.person_add;
      case UserStatus.available:
        return Icons.person_outline;
    }
  }

  Future<UserStatus> _getUserStatus(String userId) async {
    try {
      // Check if they're already friends
      final friends = await FriendsService.getFriends();
      final isFriend = friends.any((friendship) =>
          friendship.user1Id == userId || friendship.user2Id == userId);
      if (isFriend) return UserStatus.friend;

      // Check pending requests
      final sentRequests = await FriendsService.getSentFriendRequests();
      final receivedRequests = await FriendsService.getPendingFriendRequests();

      if (sentRequests.any((request) => request.receiverId == userId)) {
        return UserStatus.pendingSent;
      }

      if (receivedRequests.any((request) => request.senderId == userId)) {
        return UserStatus.pendingReceived;
      }

      return UserStatus.available;
    } catch (e) {
      debugPrint('Error getting user status: $e');
      return UserStatus.available;
    }
  }

  Future<void> _sendFriendRequest(BuildContext context, UserModel user) async {
    try {
      final success = await FriendsService.sendFriendRequest(user.uId!);

      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Friend request sent to ${user.name}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to send friend request'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _acceptFriendRequest(
      BuildContext context, UserModel user) async {
    try {
      final requests = await FriendsService.getPendingFriendRequests();
      final request = requests.firstWhere((r) => r.senderId == user.uId);
      final success = await FriendsService.acceptFriendRequest(request);

      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Accepted friend request from ${user.name}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to accept friend request'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _rejectFriendRequest(
      BuildContext context, UserModel user) async {
    try {
      final requests = await FriendsService.getPendingFriendRequests();
      final request = requests.firstWhere((r) => r.senderId == user.uId);
      final success = await FriendsService.rejectFriendRequest(request);

      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Rejected friend request from ${user.name}'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to reject friend request'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }
}

enum UserStatus {
  available,
  friend,
  pendingSent,
  pendingReceived,
}
