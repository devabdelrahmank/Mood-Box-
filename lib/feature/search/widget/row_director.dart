import 'package:flutter/material.dart';
import 'package:movie_proj/core/my_styles.dart';
import 'package:movie_proj/core/spacing.dart';

class RowDirector extends StatelessWidget {
  final String text1;
  final String text2;
  const RowDirector({
    super.key,
    required this.text1,
    required this.text2,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          text1,
          style: MyStyles.title13Redw700.copyWith(
            color: const Color(0xffC3C3C3),
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
        ),
        hSpace(5),
        Text(
          text2,
          style: MyStyles.title13Redw700.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
