import 'package:flutter/material.dart';
import 'package:movie_proj/core/my_images.dart';
import 'package:movie_proj/core/my_styles.dart';
import 'package:movie_proj/core/my_text.dart';
import 'package:movie_proj/core/spacing.dart';
import 'package:movie_proj/feature/auth/widget/my_text_btns.dart';
import 'package:movie_proj/feature/auth/widget/social_btn.dart';

class HomeMostWatched extends StatelessWidget {
  const HomeMostWatched({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.asset(
          MyImages.background,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
        Positioned(
          top: 150,
          child: Container(
            padding: const EdgeInsets.only(left: 30),
            width: 350,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  MyText.johnWick,
                  style: MyStyles.title24White700.copyWith(fontSize: 48),
                ),
                vSpace(15),
                Text(
                  MyText.johnWickCaption,
                  style: MyStyles.title24White400.copyWith(fontSize: 14),
                ),
                vSpace(20),
                Row(
                  children: [
                    Image.asset(MyImages.imdb, width: 50),
                    hSpace(10),
                    Text(
                      '86.0/100',
                      style: MyStyles.title24White400.copyWith(fontSize: 14),
                    ),
                  ],
                ),
                vSpace(20),
                Row(
                  children: [
                    MyTextBtn(
                      onTap: () {},
                      text: MyText.addToPlaylist,
                      color: Colors.white,
                      textColor: Colors.black,
                      radius: 5,
                      width: 120,
                    ),
                    hSpace(10),
                    const SocialBtn(
                      color: Color(0xff6D6D6E),
                      textColor: Colors.white,
                      imagePath: MyImages.iconError,
                      radius: 5,
                      width: 120,
                      text: MyText.moreInfo,
                    )
                  ],
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}
