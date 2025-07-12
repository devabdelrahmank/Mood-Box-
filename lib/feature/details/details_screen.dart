import 'package:flutter/material.dart';
import 'package:movie_proj/core/my_colors.dart';
import 'package:movie_proj/feature/details/widget/modern_details_body.dart';
import 'package:movie_proj/feature/home/model/movie_model.dart';

class DetailsScreen extends StatelessWidget {
  final MovieModel movie;

  const DetailsScreen({
    super.key,
    required this.movie,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.primaryColor,
      body: ModernDetailsBody(movie: movie),
    );
  }
}
