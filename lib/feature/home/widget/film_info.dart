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
  const FilmInfo({
    super.key,
    required this.filmPoster,
    required this.filmYear,
    required this.filmName,
    required this.imdbRating,
    required this.filmGenre1,
    required this.filmGenre2,
    required this.filmGenre3,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final posterWidth = screenWidth > 600 ? 200.0 : 150.0;
    final posterHeight = screenWidth > 600 ? 350.0 : 260.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          children: [
            Container(
              width: posterWidth,
              height: posterHeight,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(filmPoster),
                  fit: BoxFit.fill,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                width: screenWidth > 600 ? 25 : 20,
                height: screenWidth > 600 ? 25 : 20,
                decoration: const BoxDecoration(
                  color: Colors.white70,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.favorite,
                  color: Colors.white,
                  size: screenWidth > 600 ? 20 : 16,
                ),
              ),
            ),
          ],
        ),
        vSpace(5),
        Text(
          filmYear,
          style: MyStyles.title24White400.copyWith(
            fontSize: screenWidth > 600 ? 12 : 10,
          ),
        ),
        vSpace(5),
        Text(
          filmName,
          style: MyStyles.title24White400.copyWith(
            fontSize: screenWidth > 600 ? 18 : 14,
          ),
          textAlign: TextAlign.center,
        ),
        vSpace(5),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              MyImages.imdb,
              width: screenWidth > 600 ? 50 : 40,
            ),
            hSpace(10),
            Text(
              imdbRating,
              style: MyStyles.title24White400.copyWith(
                fontSize: screenWidth > 600 ? 14 : 12,
              ),
            ),
          ],
        ),
        vSpace(15),
        Text(
          '$filmGenre1 $filmGenre2 $filmGenre3',
          style: MyStyles.title24White400.copyWith(
            fontSize: screenWidth > 600 ? 12 : 10,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
