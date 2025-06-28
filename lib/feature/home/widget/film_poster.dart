import 'package:flutter/material.dart';
import 'package:movie_proj/core/my_styles.dart';

class FilmPoster extends StatelessWidget {
  final String imagePath;
  final String title;
  const FilmPoster({super.key, required this.imagePath, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 200,
          height: 300,
          padding: const EdgeInsets.only(top: 255),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(imagePath),
              fit: BoxFit.cover,
            ),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style:
                MyStyles.title24White400.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
