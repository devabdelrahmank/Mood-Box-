import 'package:flutter/material.dart';
import 'package:movie_proj/core/my_colors.dart';
import 'package:movie_proj/core/my_styles.dart';
import 'package:movie_proj/core/my_text.dart';
import 'package:movie_proj/core/spacing.dart';
import 'package:movie_proj/feature/auth/widget/my_text_btns.dart';
import 'package:movie_proj/feature/search/search_screen.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
              Text(
                MyText.home,
                style: MyStyles.title24White400.copyWith(fontSize: 13),
              ),
              hSpace(20),
              Text(
                MyText.suggest,
                style: MyStyles.title24White400.copyWith(fontSize: 13),
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
              MyTextBtn(
                onTap: () {},
                text: MyText.signup,
                color: MyColors.btnColor,
                textColor: Colors.white,
                radius: 20,
              ),
              hSpace(15),
              MyTextBtn(
                onTap: () {},
                text: MyText.login,
                color: Colors.white,
                textColor: MyColors.btnColor,
                radius: 20,
              )
            ],
          ),
        ),
      ),
    );
  }
}
