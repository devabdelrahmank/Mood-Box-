import 'package:flutter/material.dart';
import 'package:movie_proj/core/my_colors.dart';
import 'package:movie_proj/core/my_images.dart';
import 'package:movie_proj/core/my_styles.dart';
import 'package:movie_proj/core/my_text.dart';
import 'package:movie_proj/core/spacing.dart';
import 'package:movie_proj/feature/home/widget/film_info.dart';

class FilmInfoWidget extends StatelessWidget {
  final String text;
  const FilmInfoWidget({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Text(text, style: MyStyles.title24White400),
        ),
        vSpace(30),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            width: double.infinity,
            height: 500,
            decoration: BoxDecoration(
              color: MyColors.secondaryColor,
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FilmInfo(
                  filmPoster: MyImages.spiderMan,
                  filmYear: MyText.usa2018,
                  filmName: MyText.spiderMan,
                  imdbRating: '84.0/100',
                  filmGenre1: MyText.animation,
                  filmGenre2: MyText.action,
                  filmGenre3: MyText.adventure,
                ),
                FilmInfo(
                  filmPoster: MyImages.spiderMan,
                  filmYear: MyText.usa2018,
                  filmName: MyText.spiderMan,
                  imdbRating: '84.0/100',
                  filmGenre1: MyText.animation,
                  filmGenre2: MyText.action,
                  filmGenre3: MyText.adventure,
                ),
                FilmInfo(
                  filmPoster: MyImages.spiderMan,
                  filmYear: MyText.usa2018,
                  filmName: MyText.spiderMan,
                  imdbRating: '84.0/100',
                  filmGenre1: MyText.animation,
                  filmGenre2: MyText.action,
                  filmGenre3: MyText.adventure,
                ),
                FilmInfo(
                  filmPoster: MyImages.dunkirk,
                  filmYear: MyText.usa2017,
                  filmName: MyText.dunkirk,
                  imdbRating: '78.0/100',
                  filmGenre1: MyText.action,
                  filmGenre2: MyText.drama,
                  filmGenre3: MyText.history,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
