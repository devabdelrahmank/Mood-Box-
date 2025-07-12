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
    final screenWidth = MediaQuery.of(context).size.width;
    final containerHeight = screenWidth > 600 ? 500.0 : 400.0;

    return Column(
      children: [
        Center(
          child: Text(
            text,
            style: MyStyles.title24White400.copyWith(
              fontSize: screenWidth > 600 ? 24.0 : 20.0,
            ),
          ),
        ),
        vSpace(30),
        Padding(
          padding:
              EdgeInsets.symmetric(horizontal: screenWidth > 600 ? 20.0 : 10.0),
          child: Container(
            width: double.infinity,
            height: containerHeight,
            decoration: BoxDecoration(
              color: MyColors.secondaryColor,
              borderRadius: BorderRadius.circular(40),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  hSpace(20),
                  const FilmInfo(
                    filmPoster: MyImages.loki,
                    filmYear: MyText.usa2018,
                    filmName: MyText.spiderMan,
                    imdbRating: '84.0/100',
                    filmGenre1: MyText.animation,
                    filmGenre2: MyText.action,
                    filmGenre3: MyText.adventure,
                  ),
                  hSpace(20),
                  const FilmInfo(
                    filmPoster: MyImages.spiderMan,
                    filmYear: MyText.usa2018,
                    filmName: MyText.spiderMan,
                    imdbRating: '84.0/100',
                    filmGenre1: MyText.animation,
                    filmGenre2: MyText.action,
                    filmGenre3: MyText.adventure,
                  ),
                  hSpace(20),
                  const FilmInfo(
                    filmPoster: MyImages.spiderMan,
                    filmYear: MyText.usa2018,
                    filmName: MyText.spiderMan,
                    imdbRating: '84.0/100',
                    filmGenre1: MyText.animation,
                    filmGenre2: MyText.action,
                    filmGenre3: MyText.adventure,
                  ),
                  hSpace(20),
                  const FilmInfo(
                    filmPoster: MyImages.dunkirk,
                    filmYear: MyText.usa2017,
                    filmName: MyText.dunkirk,
                    imdbRating: '78.0/100',
                    filmGenre1: MyText.action,
                    filmGenre2: MyText.drama,
                    filmGenre3: MyText.history,
                  ),
                  hSpace(20),
                  const FilmInfo(
                    filmPoster: MyImages.batMan,
                    filmYear: MyText.usa2017,
                    filmName: MyText.batmanBegins,
                    imdbRating: '78.0/100',
                    filmGenre1: MyText.action,
                    filmGenre2: MyText.drama,
                    filmGenre3: MyText.history,
                  ),
                  hSpace(20),
                  const FilmInfo(
                    filmPoster: MyImages.genV,
                    filmYear: MyText.usa2017,
                    filmName: MyText.dunkirk,
                    imdbRating: '78.0/100',
                    filmGenre1: MyText.action,
                    filmGenre2: MyText.drama,
                    filmGenre3: MyText.history,
                  ),
                  hSpace(20),
                  const FilmInfo(
                    filmPoster: MyImages.fallMouseUsher,
                    filmYear: MyText.usa2017,
                    filmName: MyText.dunkirk,
                    imdbRating: '78.0/100',
                    filmGenre1: MyText.action,
                    filmGenre2: MyText.drama,
                    filmGenre3: MyText.history,
                  ),
                  hSpace(20),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
