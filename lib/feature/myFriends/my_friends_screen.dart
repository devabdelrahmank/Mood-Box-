import 'package:flutter/material.dart';
import 'package:movie_proj/core/my_colors.dart';
import 'package:movie_proj/core/my_styles.dart';
import 'package:movie_proj/core/my_text.dart';
import 'package:movie_proj/core/spacing.dart';
import 'package:movie_proj/core/widget/movie_app_bar.dart';

import 'package:movie_proj/feature/myFriends/widget/my_friends_grid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyFriendsScreen extends StatefulWidget {
  final Function(int) onNavigate;

  const MyFriendsScreen({
    super.key,
    required this.onNavigate,
  });

  @override
  State<MyFriendsScreen> createState() => _MyFriendsScreenState();
}

class _MyFriendsScreenState extends State<MyFriendsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _debugCheckUsers();
  }

  Future<void> _debugCheckUsers() async {
    try {
      debugPrint('\n🔍 DEBUG INFORMATION');

      // Check current user
      final currentUser = FirebaseAuth.instance.currentUser;
      debugPrint('\n👤 Current User:');
      if (currentUser != null) {
        debugPrint('  - Email: ${currentUser.email}');
        debugPrint('  - UID: ${currentUser.uid}');
        debugPrint('  - Verified: ${currentUser.emailVerified}');
      } else {
        debugPrint('  ❌ No user is currently signed in!');
      }

      // Check users in Firebase
      debugPrint('\n📚 Users in Database:');
      final usersSnapshot =
          await FirebaseFirestore.instance.collection('users').get();

      debugPrint('📊 Found ${usersSnapshot.docs.length} users:');
      for (var doc in usersSnapshot.docs) {
        final data = doc.data();
        debugPrint('  - User: ${data['name']} (${data['uId']})');
        debugPrint('    Email: ${data['email']}');
        debugPrint('    Image: ${data['image']}');
        if (currentUser != null && data['uId'] == currentUser.uid) {
          debugPrint('    ⭐ This is the current user');
        }
      }

      debugPrint('\n=================================\n');
    } catch (e) {
      debugPrint('❌ Error in debug check: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = _getHorizontalPadding(screenWidth);
    final verticalSpacing = _getVerticalSpacing(screenWidth);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: MovieAppBar(
        currentIndex: 3,
        onNavigate: widget.onNavigate,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),

          const Text(
            'My Friends',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          // Tab Bar
          Container(
            margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
            constraints: BoxConstraints(
              maxWidth: _getMaxContainerWidth(screenWidth),
            ),
            decoration: BoxDecoration(
              color: MyColors.secondaryColor.withValues(alpha: 0.3),
              borderRadius:
                  BorderRadius.circular(_getBorderRadius(screenWidth)),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: MyColors.secondaryColor,
                borderRadius:
                    BorderRadius.circular(_getBorderRadius(screenWidth)),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              labelStyle: MyStyles.title24White700.copyWith(
                fontSize: _getTabFontSize(screenWidth),
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: MyStyles.title24White700.copyWith(
                fontSize: _getTabFontSize(screenWidth),
                fontWeight: FontWeight.w400,
              ),
              tabs: [
                Tab(
                  height: _getTabHeight(screenWidth),
                  text: MyText.findFriends,
                ),
                Tab(
                  height: _getTabHeight(screenWidth),
                  text: MyText.myFriends,
                ),
              ],
            ),
          ),
          vSpace(verticalSpacing),
          // Tab Bar View
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Add New Friends Tab
                _buildFriendsSection(
                  screenWidth: screenWidth,
                  horizontalPadding: horizontalPadding,
                  verticalSpacing: verticalSpacing,
                  mode: FriendsGridMode.addFriends,
                ),
                // My Friends Tab
                _buildFriendsSection(
                  screenWidth: screenWidth,
                  horizontalPadding: horizontalPadding,
                  verticalSpacing: verticalSpacing,
                  mode: FriendsGridMode.myFriends,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildFriendsSection({
    required double screenWidth,
    required double horizontalPadding,
    required double verticalSpacing,
    required FriendsGridMode mode,
  }) {
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
        width: double.infinity,
        constraints: BoxConstraints(
          maxWidth: _getMaxContainerWidth(screenWidth),
        ),
        decoration: BoxDecoration(
          color: MyColors.secondaryColor,
          borderRadius: BorderRadius.circular(_getBorderRadius(screenWidth)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: _getContentPadding(screenWidth),
            vertical: verticalSpacing,
          ),
          child: MyFriendsGrid(mode: mode),
        ),
      ),
    );
  }

  double _getHorizontalPadding(double width) {
    if (width <= 400) return 12;
    if (width <= 600) return 20;
    if (width <= 900) return 30;
    return 40;
  }

  double _getVerticalSpacing(double width) {
    if (width <= 400) return 24;
    if (width <= 600) return 30;
    if (width <= 900) return 40;
    return 50;
  }

  double _getContentPadding(double width) {
    if (width <= 400) return 16;
    if (width <= 600) return 24;
    if (width <= 900) return 32;
    return 50;
  }

  double _getBorderRadius(double width) {
    if (width <= 400) return 16;
    if (width <= 600) return 20;
    if (width <= 900) return 25;
    return 30;
  }

  double _getMaxContainerWidth(double width) {
    if (width <= 900) return width;
    return 1200;
  }

  double _getTabFontSize(double width) {
    if (width <= 400) return 14;
    if (width <= 600) return 16;
    if (width <= 900) return 18;
    return 20;
  }

  double _getTabHeight(double width) {
    if (width <= 400) return 40;
    if (width <= 600) return 45;
    if (width <= 900) return 50;
    return 55;
  }
}
