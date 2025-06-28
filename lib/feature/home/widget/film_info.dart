import 'package:flutter/material.dart';
import 'package:movie_proj/core/my_images.dart';
import 'package:movie_proj/core/my_styles.dart';
import 'package:movie_proj/core/spacing.dart';

class FilmInfo extends StatelessWidget {
  final String filmPoster;
  final String filmYear;
  final String filmName;
  final String imdbRating;
  final String filmGenre1;
  final String filmGenre2;
  final String filmGenre3;
  const FilmInfo(
      {super.key,
      required this.filmPoster,
      required this.filmYear,
      required this.filmName,
      required this.imdbRating,
      required this.filmGenre1,
      required this.filmGenre2,
      required this.filmGenre3});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          children: [
            Container(
              width: 200,
              height: 350,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(filmPoster),
                  fit: BoxFit.fill,
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                width: 25,
                height: 25,
                decoration: const BoxDecoration(
                  color: Colors.white70,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.favorite,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
        vSpace(5),
        Text(
          filmYear,
          style: MyStyles.title24White400.copyWith(fontSize: 12),
        ),
        vSpace(5),
        Text(
          filmName,
          style: MyStyles.title24White400.copyWith(fontSize: 18),
        ),
        vSpace(5),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              MyImages.imdb,
              width: 50,
            ),
            hSpace(10),
            Text(
              imdbRating,
              style: MyStyles.title24White400.copyWith(fontSize: 14),
            ),
          ],
        ),
        vSpace(15),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$filmGenre1 $filmGenre2 $filmGenre3',
              style: MyStyles.title24White400.copyWith(fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }
}
