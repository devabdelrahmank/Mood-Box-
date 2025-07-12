import 'dart:async';
import 'package:flutter/material.dart';
import 'package:movie_proj/core/my_images.dart';
import 'package:movie_proj/core/my_styles.dart';
import 'package:movie_proj/core/my_text.dart';
import 'package:movie_proj/core/spacing.dart';
import 'package:movie_proj/feature/auth/widget/my_text_btns.dart';
import 'package:movie_proj/feature/chat/chat_screen.dart';
import 'package:movie_proj/feature/auth/model/user_model.dart';
import 'package:movie_proj/feature/myFriends/model/friend_request_model.dart';
import 'package:movie_proj/feature/myFriends/model/friendship_model.dart';
import 'package:movie_proj/feature/myFriends/service/friends_service.dart';

enum FriendsGridMode {
  addFriends,
  myFriends,
}

class MyFriendsGrid extends StatefulWidget {
  final FriendsGridMode mode;

  const MyFriendsGrid({
    super.key,
    required this.mode,
  });

  @override
  State<MyFriendsGrid> createState() => _MyFriendsGridState();
}

class _MyFriendsGridState extends State<MyFriendsGrid> {
  List<UserModel> _availableUsers = [];
  List<FriendshipModel> _friends = [];
  List<FriendRequestModel> _friendRequests = [];
  Map<String, FriendRequestStatus?> _requestStatuses = {};
  bool _isLoading = true;
  String? _error;
  StreamSubscription<Map<String, dynamic>>? _pageUpdatesSubscription;

  @override
  void initState() {
    super.initState();
    _setupPageUpdates();
  }

  void _setupPageUpdates() {
    _pageUpdatesSubscription =
        FriendsService.listenToFriendsPageUpdates().listen(
      (updates) {
        if (mounted) {
          setState(() {
            _friends = (updates['friends'] as List).map((item) {
              if (item is FriendshipModel) return item;
              return FriendshipModel.fromJson(
                  item as Map<String, dynamic>, item['id'] as String);
            }).toList();

            _friendRequests = (updates['requests'] as List).map((item) {
              if (item is FriendRequestModel) return item;
              return FriendRequestModel.fromJsonWithId(
                  item as Map<String, dynamic>, item['id'] as String);
            }).toList();

            _availableUsers = (updates['users'] as List).map((item) {
              if (item is UserModel) return item;
              return UserModel.fromJson(item as Map<String, dynamic>);
            }).toList();

            // Update request statuses
            final newStatuses = <String, FriendRequestStatus?>{};
            for (var request in _friendRequests) {
              final currentUserId = FriendsService.currentUserId;
              if (currentUserId == null) continue;

              if (request.senderId == currentUserId) {
                newStatuses[request.receiverId] =
                    _stringToFriendRequestStatus(request.status);
              } else if (request.receiverId == currentUserId) {
                newStatuses[request.senderId] =
                    _stringToFriendRequestStatus(request.status);
              }
            }
            _requestStatuses = newStatuses;
            _isLoading = false;
          });
        }
      },
      onError: (error) {
        debugPrint('Error in page updates: $error');
        if (mounted) {
          setState(() {
            _error = error.toString();
            _isLoading = false;
          });
        }
      },
    );
  }

  void _navigateToChat(BuildContext context, String friendName,
      String friendImage, String friendId) {
    if (friendId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot start chat: Invalid friend ID'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          friendName: friendName,
          friendImage: friendImage,
          friendId: friendId,
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required double buttonHeight,
    required FriendsGridMode mode,
    required BuildContext context,
    UserModel? user,
    FriendshipModel? friendship,
  }) {
    // First check if the user is already a friend
    if (user?.uId != null) {
      final isFriend =
          _friends.any((f) => f.user1Id == user!.uId || f.user2Id == user.uId);

      if (isFriend) {
        // Find the friendship model for this user
        final friendship = _friends.firstWhere(
          (f) => f.user1Id == user!.uId || f.user2Id == user.uId,
          orElse: () => FriendshipModel.empty(),
        );

        final currentUserId = FriendsService.currentUserId;
        if (currentUserId != null) {
          final friendInfo = friendship.getFriendInfo(currentUserId);
          return Container(
            height: buttonHeight,
            child: MyTextBtn(
              onTap: () => _navigateToChat(
                context,
                user?.name ?? friendInfo['name'] ?? 'Friend',
                user?.image ?? friendInfo['image'] ?? '',
                user?.uId ?? '',
              ),
              text: MyText.chat,
              color: Colors.green,
              textColor: Colors.white,
              radius: buttonHeight / 2,
            ),
          );
        }
      }
    }

    switch (mode) {
      case FriendsGridMode.addFriends:
        if (user?.uId == null) return Container();

        final requestStatus = _requestStatuses[user!.uId];
        final buttonHeight = MediaQuery.of(context).size.height * 0.05;

        if (requestStatus == FriendRequestStatus.pending) {
          return Container(
            height: buttonHeight,
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.8),
              borderRadius: BorderRadius.circular(buttonHeight / 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                MyText.pending,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          );
        } else if (requestStatus == FriendRequestStatus.rejected) {
          return Container(
            height: buttonHeight,
            child: MyTextBtn(
              onTap: () => _sendFriendRequest(user),
              text: MyText.sendAgain,
              color: Colors.blue,
              textColor: Colors.white,
              radius: buttonHeight / 2,
            ),
          );
        } else {
          return Container(
            height: buttonHeight,
            child: MyTextBtn(
              onTap: () => _sendFriendRequest(user),
              text: MyText.add,
              color: Colors.blue,
              textColor: Colors.white,
              radius: buttonHeight / 2,
            ),
          );
        }

      case FriendsGridMode.myFriends:
        if (friendship != null) {
          final currentUserId = FriendsService.currentUserId;
          if (currentUserId != null) {
            final friendInfo = friendship.getFriendInfo(currentUserId);
            final friendId = friendship.getFriendId(currentUserId) ?? '';
            return Container(
              height: buttonHeight,
              child: MyTextBtn(
                onTap: () => _navigateToChat(
                  context,
                  friendInfo['name'] ?? 'Friend',
                  friendInfo['image'] ?? '',
                  friendId,
                ),
                text: MyText.chat,
                color: Colors.green,
                textColor: Colors.white,
                radius: buttonHeight / 2,
              ),
            );
          }
        }
        return Container(
          height: buttonHeight,
          child: MyTextBtn(
            onTap: () {},
            text: MyText.chat,
            color: Colors.grey,
            textColor: Colors.white,
            radius: buttonHeight / 2,
          ),
        );
    }
  }

  Future<void> _sendFriendRequest(UserModel user) async {
    if (user.uId == null) return;

    // Optimistically update UI
    setState(() {
      _requestStatuses[user.uId!] = FriendRequestStatus.pending;
    });

    try {
      final success = await FriendsService.sendFriendRequest(user.uId!);
      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(MyText.friendRequestSent),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        // Revert status if request failed
        setState(() {
          _requestStatuses[user.uId!] = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to send friend request'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      // Revert status on error
      setState(() {
        _requestStatuses[user.uId!] = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void dispose() {
    _pageUpdatesSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (widget.mode == FriendsGridMode.addFriends && _availableUsers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: Colors.white.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              MyText.noUsersAvailable,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final items =
        widget.mode == FriendsGridMode.addFriends ? _availableUsers : _friends;

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = _getCrossAxisCount(constraints.maxWidth);
        final spacing = _getSpacing(constraints.maxWidth);
        final imageSize = _getImageSize(constraints.maxWidth);
        final fontSize = _getFontSize(constraints.maxWidth);
        final buttonHeight = _getButtonHeight(constraints.maxWidth);

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisExtent: _getCardHeight(constraints.maxWidth),
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
          ),
          itemBuilder: (context, index) {
            if (widget.mode == FriendsGridMode.addFriends) {
              final user = _availableUsers[index];
              return _buildUserCard(
                user: user,
                constraints: constraints,
                spacing: spacing,
                imageSize: imageSize,
                fontSize: fontSize,
                buttonHeight: buttonHeight,
              );
            } else {
              final friendship = _friends[index];
              final currentUserId = FriendsService.currentUserId;
              if (currentUserId != null) {
                final friendInfo = friendship.getFriendInfo(currentUserId);
                return _buildFriendCard(
                  friendship: friendship,
                  friendInfo: friendInfo,
                  constraints: constraints,
                  spacing: spacing,
                  imageSize: imageSize,
                  fontSize: fontSize,
                  buttonHeight: buttonHeight,
                );
              }
            }
            return const SizedBox.shrink();
          },
        );
      },
    );
  }

  Widget _buildUserCard({
    required UserModel user,
    required BoxConstraints constraints,
    required double spacing,
    required double imageSize,
    required double fontSize,
    required double buttonHeight,
  }) {
    return Container(
      padding: EdgeInsets.all(spacing / 2),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        borderRadius:
            BorderRadius.circular(_getBorderRadius(constraints.maxWidth)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(imageSize / 2),
            child: Image.asset(
              user.image?.isNotEmpty == true
                  ? user.image!
                  : MyImages.profilePic,
              width: imageSize,
              height: imageSize,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: imageSize,
                  height: imageSize,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(imageSize / 2),
                  ),
                  child: Icon(
                    Icons.person,
                    color: Colors.grey,
                    size: imageSize / 2,
                  ),
                );
              },
            ),
          ),
          hSpace(spacing),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name ?? 'Unknown User',
                  style: MyStyles.title24White400.copyWith(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                vSpace(spacing / 2),
                Text(
                  user.email ?? '',
                  style: MyStyles.title24White400.copyWith(
                    fontSize: fontSize * 0.8,
                    color: Colors.white70,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                vSpace(spacing / 2),
                SizedBox(
                  height: buttonHeight,
                  child: _buildActionButton(
                    buttonHeight: buttonHeight,
                    mode: widget.mode,
                    context: context,
                    user: user,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendCard({
    required FriendshipModel friendship,
    required Map<String, String> friendInfo,
    required BoxConstraints constraints,
    required double spacing,
    required double imageSize,
    required double fontSize,
    required double buttonHeight,
  }) {
    return InkWell(
      onTap: () => _navigateToChat(
        context,
        friendInfo['name'] ?? 'Friend',
        friendInfo['image'] ?? '',
        friendship.id!,
      ),
      child: Container(
        padding: EdgeInsets.all(spacing / 2),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.2),
          borderRadius:
              BorderRadius.circular(_getBorderRadius(constraints.maxWidth)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(imageSize / 2),
              child: Image.asset(
                friendInfo['image']?.isNotEmpty == true
                    ? friendInfo['image']!
                    : MyImages.profilePic,
                width: imageSize,
                height: imageSize,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: imageSize,
                    height: imageSize,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(imageSize / 2),
                    ),
                    child: Icon(
                      Icons.person,
                      color: Colors.grey,
                      size: imageSize / 2,
                    ),
                  );
                },
              ),
            ),
            hSpace(spacing),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    friendInfo['name'] ?? 'Friend',
                    style: MyStyles.title24White400.copyWith(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  vSpace(spacing / 2),
                  Text(
                    '${MyText.friendsSince} ${_formatDate(friendship.createdAt)}',
                    style: MyStyles.title24White400.copyWith(
                      fontSize: fontSize * 0.8,
                      color: Colors.white70,
                    ),
                  ),
                  vSpace(spacing / 2),
                  SizedBox(
                    height: buttonHeight,
                    child: _buildActionButton(
                      buttonHeight: buttonHeight,
                      mode: widget.mode,
                      context: context,
                      friendship: friendship,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} year${(difference.inDays / 365).floor() > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} month${(difference.inDays / 30).floor() > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else {
      return 'Today';
    }
  }

  int _getCrossAxisCount(double width) {
    if (width <= 400) return 1;
    if (width <= 700) return 2;
    return 3;
  }

  double _getSpacing(double width) {
    if (width <= 400) return 8;
    if (width <= 700) return 12;
    return 16;
  }

  double _getImageSize(double width) {
    if (width <= 400) return 48;
    if (width <= 700) return 56;
    return 64;
  }

  double _getFontSize(double width) {
    if (width <= 400) return 14;
    if (width <= 700) return 16;
    return 18;
  }

  double _getButtonHeight(double width) {
    if (width <= 400) return 28;
    if (width <= 700) return 32;
    return 36;
  }

  double _getBorderRadius(double width) {
    if (width <= 400) return 8;
    if (width <= 700) return 12;
    return 16;
  }

  double _getCardHeight(double width) {
    if (width <= 400) return 120;
    if (width <= 700) return 160;
    return 200;
  }

  FriendRequestStatus _stringToFriendRequestStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return FriendRequestStatus.pending;
      case 'accepted':
        return FriendRequestStatus.accepted;
      case 'rejected':
        return FriendRequestStatus.rejected;
      default:
        return FriendRequestStatus.pending;
    }
  }
}
