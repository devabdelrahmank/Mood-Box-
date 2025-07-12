import 'package:flutter/material.dart';
import 'package:movie_proj/core/my_styles.dart';
import 'package:movie_proj/core/spacing.dart';
import 'package:movie_proj/feature/details/details_screen.dart';
import 'package:movie_proj/feature/home/model/movie_model.dart';

class SimilarMoviesSection extends StatelessWidget {
  const SimilarMoviesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with navigation arrows
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.medium),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'More like this',
                style: MyStyles.heading2.copyWith(color: Colors.white),
              ),
              Row(
                children: [
                  _buildNavigationButton(Icons.chevron_left),
                  const SizedBox(width: 8),
                  _buildNavigationButton(Icons.chevron_right),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: Spacing.medium),
        // Movies list
        SizedBox(
          height: 320,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: Spacing.medium),
            child: Row(
              children: List.generate(
                5,
                (index) => Padding(
                  padding: EdgeInsets.only(
                    right: index < 4 ? Spacing.medium : 0,
                  ),
                  child: _buildMovieCard(getMovieData(index)),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationButton(IconData icon) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }

  Widget _buildMovieCard(Map<String, dynamic> movie) {
    return GestureDetector(
      onTap: () {
        // Create a MovieModel from the static data
        final movieModel = MovieModel(
          title: movie['title'] ?? 'Unknown Title',
          originalTitle: movie['title'] ?? 'Unknown Title',
          posterPath: null, // Static assets don't have TMDB paths
          backdropPath: null,
          releaseDate: '2024-01-01',
          voteAverage: double.tryParse(movie['rating'] ?? '0.0') ?? 0.0,
          voteCount: 1000,
          overview:
              'Discover more about ${movie['title'] ?? 'this movie'} in this exciting film.',
          id: movie['title'].hashCode,
          adult: false,
          genreIds: [],
          originalLanguage: 'en',
          popularity: 50.0,
          video: false,
        );

        // Note: This navigation won't work in this context as we don't have BuildContext
        // This is a stateless widget without access to Navigator
        // The main implementation in modern_details_body.dart is the correct one
      },
      child: Container(
        width: 180,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Movie poster
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.asset(
                    movie['posterUrl'],
                    width: 180,
                    height: 240,
                    fit: BoxFit.cover,
                  ),
                ),
                // Add to list button
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Rating row
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          movie['rating'],
                          style: MyStyles.body.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Rate',
                            style: MyStyles.caption.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Movie title
                    Expanded(
                      child: Text(
                        movie['title'],
                        style: MyStyles.body.copyWith(color: Colors.white),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> getMovieData(int index) {
    final movies = [
      {
        'title': 'Star Wars: Episode V',
        'rating': '8.7',
        'posterUrl': 'assets/images/152.png',
      },
      {
        'title': 'Spider-Man: Across the Spider-Verse',
        'rating': '8.6',
        'posterUrl': 'assets/images/spiderMan.png',
      },
      {
        'title': 'Interstellar',
        'rating': '8.7',
        'posterUrl': 'assets/images/dunkirk.png',
      },
      {
        'title': 'Arrival',
        'rating': '7.9',
        'posterUrl': 'assets/images/rectangle 24.png',
      },
      {
        'title': 'Inception',
        'rating': '8.8',
        'posterUrl': 'assets/images/rectangle 25.png',
      },
      {
        'title': 'Inception',
        'rating': '8.8',
        'posterUrl': 'assets/images/rectangle 27.png',
      },
      {
        'title': 'Inception',
        'rating': '8.8',
        'posterUrl': 'assets/images/rectangle 29.png',
      },
      {
        'title': 'Inception',
        'rating': '8.8',
        'posterUrl': 'assets/images/rectangle 30.png',
      },
    ];
    return movies[index];
  }
}
