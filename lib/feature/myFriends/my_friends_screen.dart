import 'package:flutter/material.dart';
import 'package:movie_proj/core/my_colors.dart';
import 'package:movie_proj/core/my_styles.dart';
import 'package:movie_proj/core/my_text.dart';
import 'package:movie_proj/core/spacing.dart';
import 'package:movie_proj/core/widget/movie_app_bar.dart';
import 'package:movie_proj/feature/myFriends/widget/my_friends_grid.dart';

class MyFriendsScreen extends StatelessWidget {
  final Function(int) onNavigate;

  const MyFriendsScreen({
    super.key,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = _getHorizontalPadding(screenWidth);
    final verticalSpacing = _getVerticalSpacing(screenWidth);

    return Scaffold(
      backgroundColor: MyColors.primaryColor,
      appBar: MovieAppBar(
        currentIndex: 3,
        onNavigate: onNavigate,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            vSpace(verticalSpacing),
            Center(
              child: Text(
                MyText.myFriends,
                style: MyStyles.title24White700.copyWith(
                  fontSize: _getTitleFontSize(screenWidth),
                ),
              ),
            ),
            vSpace(verticalSpacing),
            Container(
              margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
              width: double.infinity,
              constraints: BoxConstraints(
                maxWidth: _getMaxContainerWidth(screenWidth),
              ),
              decoration: BoxDecoration(
                color: MyColors.secondaryColor,
                borderRadius:
                    BorderRadius.circular(_getBorderRadius(screenWidth)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
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
                child: const MyFriendsGrid(),
              ),
            ),
            vSpace(verticalSpacing),
          ],
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

  double _getTitleFontSize(double width) {
    if (width <= 400) return 20;
    if (width <= 600) return 24;
    if (width <= 900) return 28;
    return 32;
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
}
