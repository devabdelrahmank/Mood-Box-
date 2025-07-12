import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_proj/core/my_colors.dart';
import 'package:movie_proj/core/my_styles.dart';
import 'package:movie_proj/feature/home/model/movie_model.dart';
import 'package:movie_proj/feature/home/model/cast_model.dart';
import 'package:movie_proj/feature/details/widget/reviews_section.dart';
import 'package:movie_proj/core/service/review_service.dart';
import 'package:movie_proj/feature/home/manage/popular_movies_cubit.dart';
import 'package:movie_proj/feature/details/widget/all_cast_screen.dart';
import 'package:movie_proj/feature/details/widget/all_photos_screen.dart';
import 'package:movie_proj/feature/details/details_screen.dart';
import 'package:movie_proj/feature/user_lists/service/user_lists_service.dart';
import 'package:movie_proj/feature/user_lists/model/saved_movie_model.dart';
import 'package:movie_proj/core/service/service.dart';
import 'package:movie_proj/core/service/enums.dart';
import 'dart:math';

class ModernDetailsBody extends StatefulWidget {
  final MovieModel movie;

  const ModernDetailsBody({
    super.key,
    required this.movie,
  });

  @override
  State<ModernDetailsBody> createState() => _ModernDetailsBodyState();
}

class _ModernDetailsBodyState extends State<ModernDetailsBody> {
  bool _isInFavorites = false;
  bool _isInWatchLater = false;
  List<CastModel> _castList = [];
  bool _isLoadingCast = true;
  String? _castError;

  @override
  void initState() {
    super.initState();
    // Load popular movies when the screen initializes
    context.read<PopularMoviesCubit>().loadPopularMovies();
    _checkMovieStatus();
    _loadCastData();
  }

  Future<void> _loadCastData() async {
    if (widget.movie.id == null) {
      setState(() {
        _isLoadingCast = false;
        _castError = 'Movie ID not available';
      });
      return;
    }

    try {
      setState(() {
        _isLoadingCast = true;
        _castError = null;
      });

      final service = ApiService();
      final castList =
          await service.getCastlist(widget.movie.id!, ProgramType.movie);

      if (mounted) {
        setState(() {
          _castList = castList;
          _isLoadingCast = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingCast = false;
          _castError = 'Failed to load cast: $e';
          // Fallback to empty list
          _castList = [];
        });
      }
    }
  }

  Future<void> _checkMovieStatus() async {
    try {
      final movieId =
          widget.movie.id?.toString() ?? widget.movie.title.hashCode.toString();

      final inFavorites = await UserListsService.isInFavorites(movieId);
      final inWatchLater = await UserListsService.isInWatchLater(movieId);

      if (mounted) {
        setState(() {
          _isInFavorites = inFavorites;
          _isInWatchLater = inWatchLater;
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  void _navigateToMovieDetails(
      BuildContext context, Map<String, String> movieData) {
    // Try to extract ID from the movie data or generate a meaningful one
    int? movieId;

    // Check if this is from popular movies (which should have real IDs)
    if (movieData.containsKey('tmdb_id')) {
      movieId = int.tryParse(movieData['tmdb_id']!);
    } else {
      // For static similar movies, we'll use a hash of the title
      // This won't work for cast data, but at least navigation will work
      movieId = movieData['title']?.hashCode;
    }

    final movieModel = MovieModel(
      id: movieId,
      title: movieData['title'] ?? 'Unknown Title',
      originalTitle: movieData['title'] ?? 'Unknown Title',
      posterPath: _extractPosterPath(movieData['poster']),
      backdropPath: null,
      releaseDate: movieData['year'] ?? '2024',
      voteAverage: double.tryParse(movieData['rating'] ?? '0.0') ?? 0.0,
      voteCount: 1000,
      overview:
          'Discover more about ${movieData['title'] ?? 'this movie'} in this exciting film.',
      adult: false,
      genreIds: [],
      originalLanguage: 'en',
      popularity: 50.0,
      video: false,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailsScreen(movie: movieModel),
      ),
    );
  }

  String? _extractPosterPath(String? posterUrl) {
    // If it's already a TMDb path, extract just the path part
    if (posterUrl != null && posterUrl.contains('image.tmdb.org')) {
      final uri = Uri.parse(posterUrl);
      final pathSegments = uri.pathSegments;
      if (pathSegments.length >= 3) {
        return '/${pathSegments.last}';
      }
    }
    return null;
  }

  void _toggleFavorites() async {
    try {
      final movieId =
          widget.movie.id?.toString() ?? widget.movie.title.hashCode.toString();

      bool success;
      String message;
      Color backgroundColor;
      IconData icon;

      if (_isInFavorites) {
        // Remove from favorites
        success = await UserListsService.removeFromFavorites(movieId);
        message = success
            ? 'Removed from favorites!'
            : 'Failed to remove from favorites.';
        backgroundColor = success ? Colors.orange : Colors.red;
        icon = success ? Icons.favorite_border : Icons.error;
      } else {
        // Add to favorites
        final savedMovie = SavedMovieModel.fromMovieModel(widget.movie);
        success = await UserListsService.addToFavorites(savedMovie);
        message = success
            ? 'Added to favorites!'
            : 'Movie is already in your favorites!';
        backgroundColor = success ? Colors.green : Colors.orange;
        icon = success ? Icons.favorite : Icons.info;
      }

      if (!mounted) return;

      if (success) {
        setState(() {
          _isInFavorites = !_isInFavorites;
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: backgroundColor,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.error,
                color: Colors.white,
                size: 20,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Failed to update favorites. Please try again.',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _toggleWatchLater() async {
    try {
      final movieId =
          widget.movie.id?.toString() ?? widget.movie.title.hashCode.toString();

      bool success;
      String message;
      Color backgroundColor;
      IconData icon;

      if (_isInWatchLater) {
        // Remove from watch later
        success = await UserListsService.removeFromWatchLater(movieId);
        message = success
            ? 'Removed from watch later!'
            : 'Failed to remove from watch later.';
        backgroundColor = success ? Colors.orange : Colors.red;
        icon = success ? Icons.watch_later_outlined : Icons.error;
      } else {
        // Add to watch later
        final savedMovie = SavedMovieModel.fromMovieModel(widget.movie);
        success = await UserListsService.addToWatchLater(savedMovie);
        message = success
            ? 'Added to watch later!'
            : 'Movie is already in watch later!';
        backgroundColor = success ? Colors.green : Colors.orange;
        icon = success ? Icons.watch_later : Icons.info;
      }

      if (!mounted) return;

      if (success) {
        setState(() {
          _isInWatchLater = !_isInWatchLater;
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: backgroundColor,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.error,
                color: Colors.white,
                size: 20,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Failed to update watch later. Please try again.',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return CustomScrollView(
      slivers: [
        // Modern App Bar with backdrop image
        SliverAppBar(
          expandedHeight: screenHeight * 0.6,
          pinned: true,
          backgroundColor: MyColors.primaryColor,
          leading: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ),
          actions: [
            Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _isInFavorites
                    ? Colors.red.withValues(alpha: 0.9)
                    : Colors.black.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: IconButton(
                    icon: Icon(
                      _isInFavorites ? Icons.favorite : Icons.favorite_border,
                      color: Colors.white,
                    ),
                    onPressed: () => _toggleFavorites(),
                  ),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _isInWatchLater
                    ? MyColors.primaryColor.withValues(alpha: 0.9)
                    : Colors.black.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: IconButton(
                    icon: Icon(
                      _isInWatchLater
                          ? Icons.watch_later
                          : Icons.watch_later_outlined,
                      color: Colors.white,
                    ),
                    onPressed: () => _toggleWatchLater(),
                  ),
                ),
              ),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                // Backdrop image
                Image.network(
                  _getBackdropUrl(),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[900],
                      child: const Center(
                        child: Icon(Icons.movie, color: Colors.grey, size: 64),
                      ),
                    );
                  },
                ),
                // Gradient overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.3),
                        Colors.black.withValues(alpha: 0.7),
                        MyColors.primaryColor,
                      ],
                      stops: const [0.0, 0.4, 0.7, 1.0],
                    ),
                  ),
                ),
                // Play button
                // Center(
                //   child: Container(
                //     width: 80,
                //     height: 80,
                //     decoration: BoxDecoration(
                //       color: Colors.black.withValues(alpha: 0.4),
                //       shape: BoxShape.circle,
                //     ),
                //     child: ClipOval(
                //       child: BackdropFilter(
                //         filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                //         child: Container(
                //           decoration: BoxDecoration(
                //             color: Colors.white.withValues(alpha: 0.1),
                //             shape: BoxShape.circle,
                //             border: Border.all(
                //               color: Colors.white.withValues(alpha: 0.3),
                //               width: 2,
                //             ),
                //           ),
                //           child: const Icon(
                //             Icons.play_arrow,
                //             color: Colors.white,
                //             size: 40,
                //           ),
                //         ),
                //       ),
                //     ),
                //   ),
                // ),
                // Movie info at bottom
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Movie poster
                        Container(
                          width: 120,
                          height: 180,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.5),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              widget.movie.posterUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[800],
                                  child: const Icon(
                                    Icons.movie,
                                    color: Colors.grey,
                                    size: 48,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Movie details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.movie.displayTitle,
                                style: MyStyles.heading1.copyWith(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.5),
                                      offset: const Offset(0, 2),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 12),
                              // Movie info chips
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _buildInfoChip(widget.movie.year),
                                  _buildRatingChip(widget.movie.rating),
                                  _buildInfoChip(
                                      '${widget.movie.voteCount ?? 0} votes'),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // Movie genres
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: _getMovieGenres()
                                    .map((genre) => _buildGenreChip(genre))
                                    .toList(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Content
        SliverToBoxAdapter(
          child: Container(
            color: MyColors.primaryColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // Overview section
                if (widget.movie.overview != null &&
                    widget.movie.overview!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Overview',
                          style:
                              MyStyles.heading2.copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.1),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            widget.movie.overview!,
                            style: MyStyles.body.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                              height: 1.6,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Details',
                        style: MyStyles.heading2.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      _buildDetailRow('Date: ', _formatReleaseDate()),
                      _buildDetailRow('Rating: ', '${widget.movie.rating}/10'),
                      _buildDetailRow('Popularity : ',
                          widget.movie.popularity?.toStringAsFixed(1) ?? 'N/A'),
                      _buildDetailRow(
                          'Language : ',
                          widget.movie.originalLanguage?.toUpperCase() ??
                              'N/A'),
                      if (widget.movie.adult == true)
                        _buildDetailRow('Content', 'Adult'),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                // Cast section
                _buildCastSection(),
                const SizedBox(height: 30),
                // Photos section
                _buildPhotosSection(),
                const SizedBox(height: 30),

                // Reviews section
                _buildReviewsSection(),
                const SizedBox(height: 30),

                // Similar movies section
                _buildSimilarMoviesSection(),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _getBackdropUrl() {
    if (widget.movie.backdropPath != null &&
        widget.movie.backdropPath!.isNotEmpty) {
      return 'https://image.tmdb.org/t/p/w1280${widget.movie.backdropPath}';
    }
    return widget.movie.posterUrl; // Fallback to poster
  }

  String _formatReleaseDate() {
    if (widget.movie.releaseDate != null &&
        widget.movie.releaseDate!.isNotEmpty) {
      try {
        final date = DateTime.parse(widget.movie.releaseDate!);
        final months = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec'
        ];
        return '${months[date.month - 1]} ${date.day}, ${date.year}';
      } catch (e) {
        return widget.movie.releaseDate!;
      }
    }
    return 'Unknown';
  }

  Widget _buildInfoChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: MyStyles.caption.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildRatingChip(String rating) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: MyColors.secondaryColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: MyColors.secondaryColor.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, color: Colors.white, size: 14),
          const SizedBox(width: 4),
          Text(
            rating,
            style: MyStyles.caption.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: MyStyles.body.copyWith(
                color: MyColors.btnColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: MyStyles.body.copyWith(
                color: Colors.white,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenreChip(String genre) {
    // Get color based on genre
    Color genreColor = _getGenreColor(genre);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: genreColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: genreColor.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Text(
        genre,
        style: MyStyles.caption.copyWith(
          color: genreColor,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Color _getGenreColor(String genre) {
    switch (genre.toLowerCase()) {
      case 'action':
        return Colors.red;
      case 'adventure':
        return Colors.orange;
      case 'comedy':
        return Colors.yellow;
      case 'drama':
        return Colors.blue;
      case 'horror':
        return Colors.purple;
      case 'sci-fi':
        return Colors.cyan;
      case 'thriller':
        return Colors.deepOrange;
      case 'romance':
        return Colors.pink;
      case 'fantasy':
        return Colors.indigo;
      case 'crime':
        return Colors.grey;
      case 'animation':
        return Colors.green;
      case 'documentary':
        return Colors.brown;
      case 'family':
        return Colors.lightGreen;
      case 'mystery':
        return Colors.deepPurple;
      case 'war':
        return Colors.blueGrey;
      case 'western':
        return Colors.amber;
      case 'music':
        return Colors.teal;
      case 'history':
        return Colors.lime;
      default:
        return MyColors.secondaryColor;
    }
  }

  Widget _buildCastSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.people,
                    color: MyColors.secondaryColor,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Cast',
                    style: MyStyles.heading2.copyWith(color: Colors.white),
                  ),
                ],
              ),
              if (!_isLoadingCast && _castList.isNotEmpty)
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AllCastScreen(
                          castList: _castList,
                          movieTitle: widget.movie.displayTitle,
                        ),
                      ),
                    );
                  },
                  child: Text(
                    'See all ${_castList.length}',
                    style:
                        MyStyles.body.copyWith(color: MyColors.secondaryColor),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          _buildCastContent(),
        ],
      ),
    );
  }

  Widget _buildCastContent() {
    if (_isLoadingCast) {
      return const SizedBox(
        height: 140,
        child: Center(
          child: CircularProgressIndicator(
            color: MyColors.secondaryColor,
          ),
        ),
      );
    }

    if (_castError != null || _castList.isEmpty) {
      return Container(
        height: 140,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              color: Colors.grey[600],
              size: 48,
            ),
            const SizedBox(height: 8),
            Text(
              _castError ?? 'No cast information available',
              style: MyStyles.body.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _castList.length > 10
            ? 10
            : _castList.length, // Show max 10 cast members
        itemBuilder: (context, index) {
          final castMember = _castList[index];
          return GestureDetector(
            onTap: () {
              // Show cast member details
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      '${castMember.displayName} as ${castMember.displayCharacter}'),
                  backgroundColor: MyColors.secondaryColor,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: Container(
              width: 90,
              margin: EdgeInsets.only(
                right:
                    index < (_castList.length > 10 ? 9 : _castList.length - 1)
                        ? 16
                        : 0,
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          MyColors.secondaryColor.withValues(alpha: 0.3),
                          Colors.transparent,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: MyColors.secondaryColor.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: ClipOval(
                        child: Image.network(
                          castMember.characterImagePath,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade800,
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: MyColors.secondaryColor,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade800,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 32,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.person_4,
                        color: MyColors.secondaryColor,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          castMember.displayCharacter,
                          style: MyStyles.caption.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    castMember.displayName,
                    style: MyStyles.caption.copyWith(
                      color: MyColors.secondaryColor.withValues(alpha: 0.8),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPhotosSection() {
    // Real photos based on the movie
    final realPhotos = _getRealPhotosData();

    return Builder(
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Photos',
                    style: MyStyles.heading2.copyWith(color: Colors.white),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => AllPhotosScreen(
                            photos: realPhotos,
                            movieTitle: widget.movie.displayTitle,
                          ),
                        ),
                      );
                    },
                    child: Text(
                      'See all ${realPhotos.length}',
                      style: MyStyles.body
                          .copyWith(color: MyColors.secondaryColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: realPhotos.length,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 320,
                      margin: EdgeInsets.only(
                        right: index < realPhotos.length - 1 ? 16 : 0,
                      ),
                      child: GestureDetector(
                        onTap: () =>
                            _showPhotoViewer(context, realPhotos, index),
                        child: Hero(
                          tag: 'photo_$index',
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Stack(
                                children: [
                                  Image.network(
                                    realPhotos[index],
                                    width: 320,
                                    height: 200,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 320,
                                        height: 200,
                                        color: Colors.grey[800],
                                        child: const Center(
                                          child: Icon(
                                            Icons.broken_image,
                                            color: Colors.grey,
                                            size: 48,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  if (realPhotos.length > 1)
                                    Positioned(
                                      top: 12,
                                      right: 12,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.black
                                              .withValues(alpha: 0.6),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          '${index + 1}/${realPhotos.length}',
                                          style: MyStyles.caption.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSimilarMoviesSection() {
    return BlocBuilder<PopularMoviesCubit, PopularMoviesState>(
      builder: (context, state) {
        // Get real similar movies based on the current movie
        final similarMovies = _getRealSimilarMovies();

        // Combine similar movies with popular movies
        List<Map<String, String>> allMovies = List.from(similarMovies);

        // Add popular movies if available
        if (state is PopularMoviesLoaded && state.movies.isNotEmpty) {
          // Convert popular movies to the same format and add them
          final popularMoviesFormatted = state.movies
              .take(10)
              .map((movie) => {
                    'title': movie.displayTitle,
                    'poster': movie.posterUrl,
                    'rating': movie.rating,
                    'year': movie.year,
                    'tmdb_id': movie.id?.toString() ??
                        '', // Include TMDb ID for proper cast loading
                  })
              .toList();

          allMovies.addAll(popularMoviesFormatted);
        }

        // Shuffle the combined list for variety
        allMovies.shuffle(Random());

        // Take up to 15 movies for display
        final displayMovies = allMovies.take(15).toList();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Similar Movies',
                    style: MyStyles.heading2.copyWith(color: Colors.white),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'See all',
                      style: MyStyles.body
                          .copyWith(color: MyColors.secondaryColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 300,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: displayMovies.length,
                  itemBuilder: (context, index) {
                    final movie = displayMovies[index];
                    return Container(
                      width: 140,
                      margin: EdgeInsets.only(
                        right: index < displayMovies.length - 1 ? 16 : 0,
                      ),
                      child: GestureDetector(
                        onTap: () {
                          _navigateToMovieDetails(context, movie);
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 210,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Stack(
                                  children: [
                                    Image.network(
                                      movie['poster']!,
                                      width: 140,
                                      height: 210,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Container(
                                          width: 140,
                                          height: 210,
                                          color: Colors.grey[800],
                                          child: const Center(
                                            child: Icon(
                                              Icons.movie,
                                              color: Colors.grey,
                                              size: 32,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    // Rating badge
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: MyColors.secondaryColor,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.star,
                                              color: Colors.white,
                                              size: 12,
                                            ),
                                            const SizedBox(width: 2),
                                            Text(
                                              movie['rating']!,
                                              style: MyStyles.caption.copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 10,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    movie['title']!,
                                    style: MyStyles.body.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    movie['year']!,
                                    style: MyStyles.caption.copyWith(
                                      color:
                                          Colors.white.withValues(alpha: 0.6),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPhotoViewer(
      BuildContext context, List<String> photos, int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PhotoViewerScreen(
          photos: photos,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  // Get real photos data based on the movie
  List<String> _getRealPhotosData() {
    List<String> photos = [];

    // Add backdrop image if available
    if (widget.movie.backdropPath != null &&
        widget.movie.backdropPath!.isNotEmpty) {
      photos.add('https://image.tmdb.org/t/p/w780${widget.movie.backdropPath}');
    }

    // Add poster image if available
    if (widget.movie.posterPath != null &&
        widget.movie.posterPath!.isNotEmpty) {
      photos.add('https://image.tmdb.org/t/p/w780${widget.movie.posterPath}');
    }

    // Add additional photos based on movie
    if (widget.movie.title?.toLowerCase().contains('dune') == true ||
        widget.movie.originalTitle?.toLowerCase().contains('dune') == true) {
      photos.addAll([
        'https://image.tmdb.org/t/p/w780/xtqxdXnwd8F8XZuGWp3xSDFtymd.jpg',
        'https://image.tmdb.org/t/p/w780/czembW0Rk1Ke7lCJGahbOhdCuhV.jpg',
        'https://image.tmdb.org/t/p/w780/xOMo8BRK7PfcJv9JCnx7s5hj0PX.jpg',
      ]);
    }

    // If no photos, add a default
    if (photos.isEmpty) {
      photos.add('https://image.tmdb.org/t/p/w780/default_backdrop.jpg');
    }

    return photos;
  }

  Widget _buildReviewsSection() {
    // Generate random reviews each time the details screen is opened
    final reviews = ReviewService().getRandomReviews(count: 2);

    return ReviewsSection(
      reviews: reviews,
      onSeeAllReviews: () {
        // TODO: Navigate to all reviews screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('See all reviews feature coming soon!'),
            backgroundColor: Colors.blue,
          ),
        );
      },
    );
  }

  // Get real similar movies based on the current movie
  List<Map<String, String>> _getRealSimilarMovies() {
    // Check if current movie is sci-fi/adventure based on genre IDs
    bool isSciFi = widget.movie.genreIds?.contains(878) == true; // Sci-Fi
    bool isAdventure = widget.movie.genreIds?.contains(12) == true; // Adventure
    bool isAction = widget.movie.genreIds?.contains(28) == true; // Action

    if (isSciFi || isAdventure) {
      return [
        {
          'title': 'Blade Runner 2049',
          'poster':
              'https://image.tmdb.org/t/p/w342/gajva2L0rPYkEWjzgFlBXCAVBE5.jpg',
          'rating': '8.0',
          'year': '2017',
        },
        {
          'title': 'Arrival',
          'poster':
              'https://image.tmdb.org/t/p/w342/yImmxRokQ48PD49ughXdpKTAsAU.jpg',
          'rating': '7.9',
          'year': '2016',
        },
        {
          'title': 'Interstellar',
          'poster':
              'https://image.tmdb.org/t/p/w342/gEU2QniE6E77NI6lCU6MxlNBvIx.jpg',
          'rating': '8.6',
          'year': '2014',
        },
        {
          'title': 'Mad Max: Fury Road',
          'poster':
              'https://image.tmdb.org/t/p/w342/hA2ple9q4qnwxp3hKVNhroipsir.jpg',
          'rating': '8.1',
          'year': '2015',
        },
      ];
    } else if (isAction) {
      return [
        {
          'title': 'John Wick',
          'poster':
              'https://image.tmdb.org/t/p/w342/fZPSd91yGE9fCcCe6OoQr6E3Bev.jpg',
          'rating': '7.4',
          'year': '2014',
        },
        {
          'title': 'The Dark Knight',
          'poster':
              'https://image.tmdb.org/t/p/w342/qJ2tW6WMUDux911r6m7haRef0WH.jpg',
          'rating': '9.0',
          'year': '2008',
        },
        {
          'title': 'Inception',
          'poster':
              'https://image.tmdb.org/t/p/w342/9gk7adHYeDvHkCSEqAvQNLV5Uge.jpg',
          'rating': '8.8',
          'year': '2010',
        },
        {
          'title': 'The Matrix',
          'poster':
              'https://image.tmdb.org/t/p/w342/f89U3ADr1oiB1s9GkdPOEpXUk5H.jpg',
          'rating': '8.7',
          'year': '1999',
        },
      ];
    }

    // Default similar movies
    return [
      {
        'title': 'The Shawshank Redemption',
        'poster':
            'https://image.tmdb.org/t/p/w342/q6y0Go1tsGEsmtFryDOJo3dEmqu.jpg',
        'rating': '9.3',
        'year': '1994',
      },
      {
        'title': 'The Godfather',
        'poster':
            'https://image.tmdb.org/t/p/w342/3bhkrj58Vtu7enYsRolD1fZdja1.jpg',
        'rating': '9.2',
        'year': '1972',
      },
      {
        'title': 'Pulp Fiction',
        'poster':
            'https://image.tmdb.org/t/p/w342/d5iIlFn5s0ImszYzBPb8JPIfbXD.jpg',
        'rating': '8.9',
        'year': '1994',
      },
      {
        'title': 'Forrest Gump',
        'poster':
            'https://image.tmdb.org/t/p/w342/arw2vcBveWOVZr6pxd9XTd1TdQa.jpg',
        'rating': '8.8',
        'year': '1994',
      },
    ];
  }

  // Get movie genres based on genre IDs
  List<String> _getMovieGenres() {
    if (widget.movie.genreIds == null || widget.movie.genreIds!.isEmpty) {
      return ['Drama']; // Default genre
    }

    // Genre mapping from TMDB genre IDs to names
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

    return widget.movie.genreIds!
        .map((id) => genreMap[id])
        .where((genre) => genre != null)
        .cast<String>()
        .take(3) // Limit to 3 genres to avoid overcrowding
        .toList();
  }
}

class PhotoViewerScreen extends StatefulWidget {
  final List<String> photos;
  final int initialIndex;

  const PhotoViewerScreen({
    super.key,
    required this.photos,
    required this.initialIndex,
  });

  @override
  State<PhotoViewerScreen> createState() => _PhotoViewerScreenState();
}

class _PhotoViewerScreenState extends State<PhotoViewerScreen> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${_currentIndex + 1} of ${widget.photos.length}',
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemCount: widget.photos.length,
        itemBuilder: (context, index) {
          return Center(
            child: Hero(
              tag: 'photo_$index',
              child: InteractiveViewer(
                child: Image.network(
                  widget.photos[index],
                  fit: BoxFit.contain,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class PhotoGallerySheet extends StatelessWidget {
  final List<String> photos;

  const PhotoGallerySheet({
    super.key,
    required this.photos,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: MyColors.primaryColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'All Photos (${photos.length})',
                  style: MyStyles.heading2.copyWith(color: Colors.white),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 16 / 9,
              ),
              itemCount: photos.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PhotoViewerScreen(
                          photos: photos,
                          initialIndex: index,
                        ),
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      photos[index],
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _toggleFavorite(
      BuildContext context, Map<String, String> movieData) async {
    try {
      // Convert movie data to SavedMovieModel
      final savedMovie = SavedMovieModel.fromMap(movieData);

      // Add to favorites
      final success = await UserListsService.addToFavorites(savedMovie);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.favorite,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Added "${movieData['title']}" to favorites!',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: MyColors.secondaryColor,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.info,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '"${movieData['title']}" is already in favorites!',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.error,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Failed to add to favorites. Please try again.',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void _addToWatchLater(
      BuildContext context, Map<String, String> movieData) async {
    try {
      // Convert movie data to SavedMovieModel
      final savedMovie = SavedMovieModel.fromMap(movieData);

      // Add to watch later
      final success = await UserListsService.addToWatchLater(savedMovie);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.watch_later,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Added "${movieData['title']}" to watch later!',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: MyColors.primaryColor,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.info,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '"${movieData['title']}" is already in watch later!',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.error,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Failed to add to watch later. Please try again.',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }
}
