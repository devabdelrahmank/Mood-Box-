import 'package:flutter/material.dart';
import 'package:movie_proj/core/my_styles.dart';
import 'package:movie_proj/core/spacing.dart';

class SocialBtn extends StatelessWidget {
  final Color color;
  final Color textColor;
  final String imagePath;
  final double radius;
  final double width;
  final String text;

  const SocialBtn(
      {super.key,
      required this.color,
      required this.textColor,
      required this.imagePath,
      required this.radius,
      required this.width,
      required this.text});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Container(
        width: width,
        height: 35,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(radius),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ImageIcon(
              size: 20,
              AssetImage(imagePath),
              color: Colors.white,
            ),
            hSpace(5),
            Text(
              text,
              style: MyStyles.title24White400.copyWith(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
