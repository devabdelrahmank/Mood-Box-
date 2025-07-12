import 'package:flutter/material.dart';
import 'package:movie_proj/core/my_colors.dart';
import 'package:movie_proj/core/my_styles.dart';
import 'package:movie_proj/core/my_text.dart';
import 'package:movie_proj/feature/search/widget/search_screen_body.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.primaryColor,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
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
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
        ),
      ),
      body: const SearchScreenBody(),
    );
  }
}
