import 'package:flutter/material.dart';
import 'package:movie_proj/core/my_colors.dart';
import 'package:movie_proj/core/my_images.dart';
import 'package:movie_proj/core/my_styles.dart';
import 'package:movie_proj/core/my_text.dart';
import 'package:movie_proj/core/spacing.dart';
import 'package:movie_proj/feature/search/search_screen.dart';

class MovieAppBar extends StatelessWidget implements PreferredSizeWidget {
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
              isActive: currentIndex == 0,
            ),
            hSpace(20),
            _buildNavigationItem(
              text: MyText.suggest,
              index: 1,
              isActive: currentIndex == 1,
            ),
            hSpace(20),
            _buildNavigationItem(
              text: MyText.myList,
              index: 2,
              isActive: currentIndex == 2,
            ),
            hSpace(20),
            _buildNavigationItem(
              text: MyText.friends,
              index: 3,
              isActive: currentIndex == 3,
            ),
            const Spacer(),
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
              onTap: () => onNavigate(4), // Profile screen index
              child: const CircleAvatar(
                backgroundImage: AssetImage(MyImages.profilePic),
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
    return GestureDetector(
      onTap: () => onNavigate(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: isActive
            ? BoxDecoration(
                color: MyColors.btnColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              )
            : null,
        child: Text(
          text,
          style: isActive
              ? MyStyles.title24White700.copyWith(fontSize: 13)
              : MyStyles.title24White400.copyWith(fontSize: 13),
        ),
      ),
    );
  }
}
