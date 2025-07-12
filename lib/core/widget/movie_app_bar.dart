import 'dart:async';
import 'package:flutter/material.dart';
import 'package:movie_proj/core/my_colors.dart';
import 'package:movie_proj/core/my_styles.dart';
import 'package:movie_proj/core/my_text.dart';
import 'package:movie_proj/core/spacing.dart';
import 'package:movie_proj/feature/search/search_screen.dart';
import 'package:movie_proj/feature/myFriends/model/friend_request_model.dart';
import 'package:movie_proj/feature/myFriends/service/friends_service.dart';
import 'package:movie_proj/feature/myFriends/widget/friend_request_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MovieAppBar extends StatefulWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  final int currentIndex;
  final Function(int) onNavigate;

  const MovieAppBar({
    super.key,
    required this.currentIndex,
    required this.onNavigate,
  });

  @override
  State<MovieAppBar> createState() => _MovieAppBarState();
}

class _MovieAppBarState extends State<MovieAppBar>
    with SingleTickerProviderStateMixin {
  List<FriendRequestModel> _friendRequests = [];
  StreamSubscription<List<FriendRequestModel>>? _requestsSubscription;
  late AnimationController _bellController;
  late Animation<double> _bellAnimation;
  int _previousRequestCount = 0;
  String? _currentUserImage;
  StreamSubscription<DocumentSnapshot>? _userSubscription;

  @override
  void initState() {
    super.initState();
    _setupBellAnimation();
    _setupRequestsListener();
    _setupUserImageListener();
  }

  void _setupBellAnimation() {
    _bellController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _bellAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 0.25)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 25.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.25, end: -0.25)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -0.25, end: 0.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 25.0,
      ),
    ]).animate(_bellController);

    _bellController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _bellController.reset();
      }
    });
  }

  void _setupRequestsListener() {
    _requestsSubscription?.cancel();
    _requestsSubscription =
        FriendsService.listenToPendingFriendRequests().listen(
      (requests) {
        if (mounted) {
          setState(() {
            if (requests.length > _previousRequestCount) {
              _bellController.forward();
            }
            _previousRequestCount = _friendRequests.length;
            _friendRequests = requests;
          });
        }
      },
      onError: (error) {
        debugPrint('Error listening to friend requests: $error');
      },
    );
  }

  void _setupUserImageListener() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      _userSubscription = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .snapshots()
          .listen((snapshot) {
        if (mounted && snapshot.exists) {
          setState(() {
            _currentUserImage = snapshot.data()?['image'];
          });
        }
      }, onError: (error) {
        debugPrint('Error listening to user image: $error');
      });
    }
  }

  @override
  void dispose() {
    _requestsSubscription?.cancel();
    _userSubscription?.cancel();
    _bellController.dispose();
    super.dispose();
  }

  void _showFriendRequestsDialog() {
    showDialog(
      context: context,
      builder: (context) => FriendRequestDialog(
        friendRequests: _friendRequests,
        onRequestHandled: () {
          // No need to manually refresh since we're using a stream
          setState(() {}); // Just trigger a rebuild to update the UI
        },
      ),
    );
  }

  // Debug function to create a test friendship
  Future<void> _createTestFriendship() async {
    final success = await FriendsService.createTestFriendship();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? '🤝 Test friendship created! Check "My Friends" tab'
                : '❌ Failed to create test friendship',
          ),
          backgroundColor: success ? Colors.blue : Colors.red,
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: MyColors.primaryColor,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  MyText.mood,
                  style: MyStyles.title13Redw700,
                ),
                Text(
                  MyText.box,
                  style: MyStyles.title24White700.copyWith(fontSize: 20),
                ),
              ],
            ),
            hSpace(20),
            _buildNavigationItem(
              text: MyText.home,
              index: 0,
              isActive: widget.currentIndex == 0,
            ),
            hSpace(20),
            _buildNavigationItem(
              text: MyText.suggest,
              index: 1,
              isActive: widget.currentIndex == 1,
            ),
            hSpace(20),
            _buildNavigationItem(
              text: MyText.myList,
              index: 2,
              isActive: widget.currentIndex == 2,
            ),
            hSpace(20),
            _buildNavigationItem(
              text: MyText.friends,
              index: 3,
              isActive: widget.currentIndex == 3,
            ),
            const Spacer(),
            // Notification Icon for Friend Requests
            GestureDetector(
              onTap: _showFriendRequestsDialog,
              onLongPress: () async {
                // Create test users first
                final usersCreated = await FriendsService.createTestUsers();
                if (usersCreated && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Test users created successfully!'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
                // Then create a test friend request
                final requestCreated =
                    await FriendsService.createTestFriendRequest();
                if (requestCreated && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('🎉 Test friend request created!'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              onDoubleTap: _createTestFriendship,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedBuilder(
                    animation: _bellAnimation,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _bellAnimation.value,
                        child: Icon(
                          _friendRequests.isNotEmpty
                              ? Icons.notifications_active
                              : Icons.notifications_outlined,
                          color: _friendRequests.isNotEmpty
                              ? Colors.orange
                              : Colors.white,
                          size: 26,
                        ),
                      );
                    },
                  ),
                  if (_friendRequests.isNotEmpty)
                    Positioned(
                      right: -5,
                      top: -5,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: MyColors.primaryColor,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          _friendRequests.length.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            hSpace(15),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SearchScreen(),
                  ),
                );
              },
              icon: const Icon(
                Icons.search,
                color: Colors.white,
              ),
            ),
            hSpace(15),
            GestureDetector(
              onTap: () => widget.onNavigate(4), // Profile screen index
              child: CircleAvatar(
                backgroundImage:
                    _currentUserImage != null && _currentUserImage!.isNotEmpty
                        ? NetworkImage(_currentUserImage!) as ImageProvider
                        : null,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationItem({
    required String text,
    required int index,
    required bool isActive,
  }) {
    return InkWell(
      onTap: () => widget.onNavigate(index),
      child: Text(
        text,
        style: MyStyles.title24White700.copyWith(
          fontSize: 16,
          color: isActive ? Colors.white : Colors.white.withOpacity(0.5),
        ),
      ),
    );
  }
}
