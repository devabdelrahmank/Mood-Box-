import 'package:flutter/material.dart';
import 'package:movie_proj/core/my_colors.dart';
import 'package:movie_proj/core/my_images.dart';
import 'package:movie_proj/core/my_styles.dart';
import 'package:movie_proj/core/my_text.dart';
import 'package:movie_proj/core/spacing.dart';
import 'package:movie_proj/feature/auth/widget/my_text_btns.dart';
import 'package:movie_proj/feature/myFriends/model/friend_request_model.dart';
import 'package:movie_proj/feature/myFriends/service/friends_service.dart';

class FriendRequestDialog extends StatefulWidget {
  final List<FriendRequestModel> friendRequests;
  final VoidCallback onRequestHandled;

  const FriendRequestDialog({
    super.key,
    required this.friendRequests,
    required this.onRequestHandled,
  });

  @override
  State<FriendRequestDialog> createState() => _FriendRequestDialogState();
}

class _FriendRequestDialogState extends State<FriendRequestDialog> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth <= 600;

    return Dialog(
      backgroundColor: MyColors.secondaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: isSmallScreen ? screenWidth * 0.9 : 500,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  MyText.friendRequests,
                  style: MyStyles.title24White700.copyWith(
                    fontSize: isSmallScreen ? 18 : 20,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            vSpace(16),

            // Friend Requests List
            if (widget.friendRequests.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 64,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                    vSpace(16),
                    Text(
                      MyText.noFriendRequests,
                      style: MyStyles.title24White400.copyWith(
                        fontSize: 16,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: widget.friendRequests.length,
                  separatorBuilder: (context, index) => vSpace(12),
                  itemBuilder: (context, index) {
                    final request = widget.friendRequests[index];
                    return _buildFriendRequestItem(request, isSmallScreen);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFriendRequestItem(
      FriendRequestModel request, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Profile Image
          ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: Image.asset(
              request.senderImage.isNotEmpty
                  ? request.senderImage
                  : MyImages.profilePic,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.grey,
                    size: 25,
                  ),
                );
              },
            ),
          ),
          hSpace(12),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.senderName,
                  style: MyStyles.title24White700.copyWith(
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                vSpace(4),
                Text(
                  MyText.wantsToBeYourFriend,
                  style: MyStyles.title24White400.copyWith(
                    fontSize: isSmallScreen ? 12 : 14,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),

          // Action Buttons
          if (!_isLoading) ...[
            hSpace(8),
            SizedBox(
              width: isSmallScreen ? 60 : 70,
              height: isSmallScreen ? 32 : 36,
              child: MyTextBtn(
                onTap: () => _handleFriendRequest(request, true),
                text: MyText.accept,
                color: Colors.green,
                textColor: Colors.white,
                radius: 18,
              ),
            ),
            hSpace(8),
            SizedBox(
              width: isSmallScreen ? 60 : 70,
              height: isSmallScreen ? 32 : 36,
              child: MyTextBtn(
                onTap: () => _handleFriendRequest(request, false),
                text: MyText.reject,
                color: Colors.red,
                textColor: Colors.white,
                radius: 18,
              ),
            ),
          ] else
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _handleFriendRequest(
      FriendRequestModel request, bool accept) async {
    setState(() {
      _isLoading = true;
    });

    try {
      bool success;
      if (accept) {
        success = await FriendsService.acceptFriendRequest(request);
      } else {
        success = await FriendsService.rejectFriendRequest(request);
      }

      if (success) {
        widget.onRequestHandled();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                accept
                    ? '🎉 ${MyText.friendRequestAccepted} - Check "My Friends" tab!'
                    : '⚠️ ${MyText.friendRequestRejected}',
              ),
              backgroundColor: accept ? Colors.green : Colors.orange,
              duration: const Duration(seconds: 4),
              action: SnackBarAction(
                label: 'OK',
                textColor: Colors.white,
                onPressed: () {},
              ),
            ),
          );

          // Close dialog after successful action
          Navigator.of(context).pop();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to process friend request'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
