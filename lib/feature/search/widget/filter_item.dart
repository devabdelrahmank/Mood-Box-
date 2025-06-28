import 'package:flutter/material.dart';
import 'package:movie_proj/core/my_styles.dart';

class FilterItem extends StatelessWidget {
  final String text;
  final void Function() onPress;
  const FilterItem({super.key, required this.text, required this.onPress});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          text,
          style: MyStyles.title24White700.copyWith(
            fontSize: 16,
            color: const Color(0xffC3C3C3),
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: onPress,
          icon: const Icon(
            Icons.arrow_drop_down,
            color: Color(0xffC3C3C3),
          ),
        ),
      ],
    );
  }
}
