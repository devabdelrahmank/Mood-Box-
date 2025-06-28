import 'package:flutter/material.dart';
import 'package:movie_proj/core/my_colors.dart';
import 'package:movie_proj/core/my_images.dart';
import 'package:movie_proj/core/my_styles.dart';
import 'package:movie_proj/core/my_text.dart';
import 'package:movie_proj/core/spacing.dart';

class MyListBody extends StatelessWidget {
  const MyListBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          vSpace(30),
          Center(
            child: Text(
              MyText.myList,
              style: MyStyles.title24White700.copyWith(
                fontSize: MediaQuery.of(context).size.width <= 400 ? 24 : 28,
              ),
            ),
          ),
          vSpace(30),
          Container(
            margin: EdgeInsets.symmetric(
              horizontal:
                  _getHorizontalMargin(MediaQuery.of(context).size.width),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            width: double.infinity,
            decoration: BoxDecoration(
              color: MyColors.secondaryColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSection(
                        constraints, MyText.myFavorite, MyImages.dunkirk),
                    vSpace(24),
                    _buildSection(constraints, MyText.iWant, MyImages.dunkirk),
                    vSpace(24),
                    _buildSection(
                        constraints, MyText.myFavoriteActor, MyImages.dunkirk),
                  ],
                );
              },
            ),
          ),
          vSpace(30),
        ],
      ),
    );
  }

  double _getHorizontalMargin(double width) {
    if (width <= 400) return 16;
    if (width <= 700) return 24;
    return 30;
  }

  Widget _buildSection(
      BoxConstraints constraints, String title, String imagePath) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Text(
            title,
            style: MyStyles.title24White400.copyWith(
              fontSize: _getTitleFontSize(constraints.maxWidth),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        _buildPosterGrid(constraints, imagePath),
      ],
    );
  }

  double _getTitleFontSize(double width) {
    if (width <= 400) return 16;
    if (width <= 700) return 18;
    return 20;
  }

  Widget _buildPosterGrid(BoxConstraints constraints, String imagePath) {
    final crossAxisCount = _getCrossAxisCount(constraints.maxWidth);
    final spacing = _getSpacing(constraints.maxWidth);
    final posters = List.generate(
      crossAxisCount,
      (index) => _buildResponsivePoster(constraints.maxWidth, imagePath),
    );

    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      children: posters,
    );
  }

  int _getCrossAxisCount(double width) {
    if (width <= 400) return 2;
    if (width <= 700) return 3;
    return 4;
  }

  double _getSpacing(double width) {
    if (width <= 400) return 8;
    if (width <= 700) return 12;
    return 16;
  }

  Widget _buildResponsivePoster(double containerWidth, String imagePath) {
    final posterWidth = _getPosterWidth(containerWidth);
    final posterHeight = posterWidth * 1.5; // 3:2 aspect ratio

    return Container(
      width: posterWidth,
      height: posterHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.1),
            BlendMode.darken,
          ),
        ),
      ),
    );
  }

  double _getPosterWidth(double containerWidth) {
    final crossAxisCount = _getCrossAxisCount(containerWidth);
    final spacing = _getSpacing(containerWidth);
    return (containerWidth - (spacing * (crossAxisCount - 1))) / crossAxisCount;
  }
}
