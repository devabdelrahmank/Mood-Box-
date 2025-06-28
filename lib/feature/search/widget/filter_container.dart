import 'package:flutter/material.dart';
import 'package:movie_proj/core/my_colors.dart';
import 'package:movie_proj/core/my_styles.dart';
import 'package:movie_proj/core/my_text.dart';
import 'package:movie_proj/core/spacing.dart';
import 'package:movie_proj/feature/search/widget/filter_item.dart';

class ContainerFilter extends StatelessWidget {
  const ContainerFilter({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      height: size.height - 150,
      width: size.width / 5,
      color: MyColors.secondaryColor,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    MyText.filters,
                    style: MyStyles.title24White700.copyWith(
                      fontSize: 18,
                      color: const Color(0xff797979),
                    ),
                  ),
                  hSpace(5),
                  const Icon(
                    Icons.filter_list,
                    color: const Color(0xff797979),
                  ),
                ],
              ),
              vSpace(30),
              FilterItem(text: MyText.genres, onPress: () {}),
              vSpace(20),
              FilterItem(text: MyText.titleType, onPress: () {}),
              vSpace(20),
              FilterItem(text: MyText.releaseYear, onPress: () {}),
              vSpace(20),
              FilterItem(text: MyText.imdbRating, onPress: () {}),
              vSpace(20),
              FilterItem(text: MyText.youAnd, onPress: () {}),
              vSpace(20),
              FilterItem(text: MyText.keywords, onPress: () {}),
            ],
          ),
        ),
      ),
    );
  }
}
