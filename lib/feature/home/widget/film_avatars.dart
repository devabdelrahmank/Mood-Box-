import 'package:flutter/material.dart';
import 'package:movie_proj/core/my_styles.dart';
import 'package:movie_proj/core/my_text.dart';
import 'package:movie_proj/core/spacing.dart';

class FilmAvatars extends StatelessWidget {
  const FilmAvatars({super.key});

  @override
  Widget build(BuildContext context) {
    const List<String> avatarImages = [
      'assets/images/avatar1.png',
      'assets/images/avatar2.png',
      'assets/images/avatar3.png',
      'assets/images/avatar4.png',
      'assets/images/avatar5.png',
      'assets/images/avatar6.png',
      'assets/images/avatar7.png',
      'assets/images/avatar8.png',
      'assets/images/avatar9.png',
    ];

    return Column(
      children: [
        const Center(
          child: Text(MyText.meetOthers, style: MyStyles.title24White400),
        ),
        vSpace(50),
        SizedBox(
          width: double.infinity,
          height: 130,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 9,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 30),
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(avatarImages[index]),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
