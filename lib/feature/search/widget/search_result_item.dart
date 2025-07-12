import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:movie_proj/core/my_colors.dart';
import 'package:movie_proj/core/my_styles.dart';
import 'package:movie_proj/feature/home/model/movie_model.dart';
import 'package:movie_proj/feature/details/details_screen.dart';

class SearchResultItem extends StatelessWidget {
  final MovieModel movie;

  const SearchResultItem({
    super.key,
    required this.movie,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToDetails(context),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: MyColors.secondaryColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Movie Poster
            _buildPoster(),
            
            // Movie Details
            Expanded(
              child: _buildMovieDetails(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPoster() {
    return Container(
      width: 100,
      height: 150,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          bottomLeft: Radius.circular(12),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          bottomLeft: Radius.circular(12),
        ),
        child: movie.posterUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: movie.posterUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[800],
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => _buildErrorPoster(),
              )
            : _buildErrorPoster(),
      ),
    );
  }

  Widget _buildErrorPoster() {
    return Container(
      color: Colors.grey[800],
      child: const Center(
        child: Icon(
          Icons.movie,
          color: Colors.grey,
          size: 32,
        ),
      ),
    );
  }

  Widget _buildMovieDetails() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            movie.displayTitle,
            style: MyStyles.title24White700.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: 4),
          
          // Year and Rating
          Row(
            children: [
              if (movie.year.isNotEmpty) ...[
                Icon(
                  Icons.calendar_today,
                  color: Colors.grey[400],
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  movie.year,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Icon(
                Icons.star,
                color: Colors.amber,
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                movie.rating,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Overview
          if (movie.overview != null && movie.overview!.isNotEmpty)
            Text(
              movie.overview!,
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: 12,
                height: 1.3,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          
          const SizedBox(height: 8),
          
          // Genres (if available)
          if (movie.genreIds != null && movie.genreIds!.isNotEmpty)
            Wrap(
              spacing: 4,
              children: movie.genreIds!.take(3).map((genreId) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: MyColors.primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getGenreName(genreId),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  void _navigateToDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailsScreen(movie: movie),
      ),
    );
  }

  String _getGenreName(int genreId) {
    // Basic genre mapping - you can expand this
    const genreMap = {
      28: 'Action',
      12: 'Adventure',
      16: 'Animation',
      35: 'Comedy',
      80: 'Crime',
      99: 'Documentary',
      18: 'Drama',
      10751: 'Family',
      14: 'Fantasy',
      36: 'History',
      27: 'Horror',
      10402: 'Music',
      9648: 'Mystery',
      10749: 'Romance',
      878: 'Sci-Fi',
      10770: 'TV Movie',
      53: 'Thriller',
      10752: 'War',
      37: 'Western',
    };
    
    return genreMap[genreId] ?? 'Unknown';
  }
}
