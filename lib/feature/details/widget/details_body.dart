import 'package:flutter/material.dart';
import 'package:movie_proj/core/my_colors.dart';
import 'package:movie_proj/core/my_styles.dart';
import 'package:movie_proj/core/spacing.dart';
import 'package:movie_proj/feature/details/model/movie_model.dart';
import 'package:movie_proj/feature/details/widget/cast_section.dart';
import 'package:movie_proj/feature/details/widget/movie_header.dart';
import 'package:movie_proj/feature/details/widget/photos_section.dart';
import 'package:movie_proj/feature/details/widget/similar_movies_section.dart';
import 'package:movie_proj/feature/details/widget/user_reviews_section.dart';

class DetailsBody extends StatelessWidget {
  final MovieModel movie;

  const DetailsBody({
    super.key,
    required this.movie,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MovieHeader(movie: movie),
          Padding(
            padding: const EdgeInsets.all(Spacing.medium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Plot',
                  style: MyStyles.heading2.copyWith(color: Colors.white),
                ),
                const SizedBox(height: Spacing.small),
                Text(
                  movie.plot,
                  style: MyStyles.body.copyWith(
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: Spacing.large),
                _buildInfoRow('Director', movie.director),
                _buildInfoRow('Stars', movie.stars),
                _buildInfoRow('Reviews', movie.reviews),
                const SizedBox(height: Spacing.large),
                PhotosSection(photos: movie.photos),
                const SizedBox(height: Spacing.large),
                CastSection(cast: movie.cast),
                const SizedBox(height: Spacing.large),
                const UserReviewsSection(),
                const SizedBox(height: Spacing.large),
                const SimilarMoviesSection(),
                const SizedBox(height: Spacing.medium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.small),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: MyStyles.body.copyWith(color: MyColors.secondaryColor),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: MyStyles.body.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
