import 'dart:math';
import 'package:flutter/material.dart';
import 'package:movie_proj/core/my_colors.dart';
import 'package:movie_proj/core/spacing.dart';
import 'package:movie_proj/feature/user_lists/service/user_lists_service.dart';
import 'package:movie_proj/feature/user_lists/model/saved_movie_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:movie_proj/core/my_styles.dart';
import 'package:movie_proj/feature/details/details_screen.dart';
import 'package:movie_proj/feature/home/model/movie_model.dart';

class ProfileMovies extends StatefulWidget {
  const ProfileMovies({super.key});

  @override
  State<ProfileMovies> createState() => _ProfileMoviesState();
}

class _ProfileMoviesState extends State<ProfileMovies>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  List<bool> _hoveredItems = [];
  List<SavedMovieModel> _collectionMovies = [];
  List<SavedMovieModel> _favoriteMovies = [];
  List<SavedMovieModel> _watchLaterMovies = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _loadUserCollection();
  }

  Future<void> _loadUserCollection() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Load both favorites and watch later lists
      final favorites = await UserListsService.getFavorites();
      final watchLater = await UserListsService.getWatchLater();

      // Combine both lists
      final combinedList = <SavedMovieModel>[];
      combinedList.addAll(favorites);
      combinedList.addAll(watchLater);

      // Remove duplicates based on movieId
      final uniqueMovies = <String, SavedMovieModel>{};
      for (final movie in combinedList) {
        uniqueMovies[movie.movieId] = movie;
      }

      final finalList = uniqueMovies.values.toList()
        ..sort(
            (a, b) => b.addedAt.compareTo(a.addedAt)); // Sort by newest first

      if (mounted) {
        setState(() {
          _collectionMovies = finalList;
          _favoriteMovies = favorites;
          _watchLaterMovies = watchLater;
          _hoveredItems = List.generate(finalList.length, (_) => false);
          _isLoading = false;
        });
        _controller.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load your collection';
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Helper method to determine if a movie is in favorites (prioritized) or watch later
  bool _isMovieInFavorites(SavedMovieModel movie) {
    return _favoriteMovies.any((fav) => fav.movieId == movie.movieId);
  }

  bool _isMovieInWatchLater(SavedMovieModel movie) {
    return _watchLaterMovies.any((watch) => watch.movieId == movie.movieId);
  }

  Widget _buildGridContent(BoxConstraints constraints, int crossAxisCount,
      double spacing, double childAspectRatio, bool isMediumScreen) {
    if (_isLoading) {
      return _buildLoadingGrid(
          constraints, crossAxisCount, spacing, childAspectRatio);
    }

    if (_errorMessage != null) {
      return _buildErrorWidget();
    }

    if (_collectionMovies.isEmpty) {
      return _buildEmptyWidget();
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: spacing,
        crossAxisSpacing: spacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: _collectionMovies.length,
      itemBuilder: (context, index) {
        final animation = CurvedAnimation(
          parent: _controller,
          curve: Interval(
            (index / _collectionMovies.length) * 0.5,
            min(((index + 1) / _collectionMovies.length) * 0.5 + 0.5, 1.0),
            curve: Curves.easeOutBack,
          ),
        );

        return MouseRegion(
          onEnter: (_) => setState(() => _hoveredItems[index] = true),
          onExit: (_) => setState(() => _hoveredItems[index] = false),
          child: AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              return Transform.scale(
                scale: animation.value,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  transform: _hoveredItems[index] && !isMediumScreen
                      ? (Matrix4.identity()..scale(1.03))
                      : Matrix4.identity(),
                  child: GestureDetector(
                    onTap: () =>
                        _navigateToMovieDetails(_collectionMovies[index]),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                            _getItemBorderRadius(constraints.maxWidth)),
                        boxShadow: [
                          BoxShadow(
                            color: (_hoveredItems[index] && !isMediumScreen)
                                ? Colors.black.withValues(alpha: 0.2)
                                : Colors.black.withValues(alpha: 0.1),
                            blurRadius:
                                (_hoveredItems[index] && !isMediumScreen)
                                    ? 12
                                    : 8,
                            offset: (_hoveredItems[index] && !isMediumScreen)
                                ? const Offset(0, 6)
                                : const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                            _getItemBorderRadius(constraints.maxWidth)),
                        child: Stack(
                          children: [
                            _buildSavedMovieInfo(index),
                            if (_hoveredItems[index] && !isMediumScreen)
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.black.withValues(alpha: 0),
                                        Colors.black.withValues(alpha: 0.7),
                                      ],
                                    ),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.play_circle_outline,
                                      color: Colors.white,
                                      size: _getPlayIconSize(
                                          constraints.maxWidth),
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
        );
      },
    );
  }

  Widget _buildLoadingGrid(BoxConstraints constraints, int crossAxisCount,
      double spacing, double childAspectRatio) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: spacing,
        crossAxisSpacing: spacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: 6, // Show 6 loading placeholders
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(
                _getItemBorderRadius(constraints.maxWidth)),
          ),
          child: const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.red.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Something went wrong',
              style: const TextStyle(
                color: Colors.red,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadUserCollection,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.movie_outlined,
              color: Colors.grey,
              size: 48,
            ),
            const SizedBox(height: 16),
            const Text(
              'No movies in your collection yet',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Add movies to your favorites or watch later list',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedMovieInfo(int index) {
    final movie = _collectionMovies[index];
    final screenWidth = MediaQuery.of(context).size.width;

    final isHovered =
        index < _hoveredItems.length ? _hoveredItems[index] : false;

    return GestureDetector(
      onTap: () => _navigateToMovieDetails(movie),
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              MyColors.secondaryColor.withValues(alpha: 0.8),
              MyColors.secondaryColor.withValues(alpha: 0.6),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: isHovered ? 20 : 12,
              offset: Offset(0, isHovered ? 8 : 4),
              spreadRadius: isHovered ? 2 : 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Movie Poster Section
            Expanded(
              flex: 7,
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Main Poster Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.grey.withValues(alpha: 0.2),
                              Colors.grey.withValues(alpha: 0.4),
                            ],
                          ),
                        ),
                        child: movie.posterUrl.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: movie.posterUrl,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.grey.withValues(alpha: 0.3),
                                        Colors.grey.withValues(alpha: 0.5),
                                      ],
                                    ),
                                  ),
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.grey.withValues(alpha: 0.3),
                                        Colors.grey.withValues(alpha: 0.5),
                                      ],
                                    ),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.movie_creation_outlined,
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                  ),
                                ),
                              )
                            : Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.grey.withValues(alpha: 0.3),
                                      Colors.grey.withValues(alpha: 0.5),
                                    ],
                                  ),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.movie_creation_outlined,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                ),
                              ),
                      ),
                    ),

                    // Gradient Overlay for better text readability
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.1),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Collection Badge (Top Right)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: _isMovieInFavorites(movie)
                                ? [
                                    Colors.red.withValues(alpha: 0.9),
                                    Colors.red.shade700.withValues(alpha: 0.9),
                                  ]
                                : [
                                    Colors.blue.withValues(alpha: 0.9),
                                    Colors.blue.shade700.withValues(alpha: 0.9),
                                  ],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          _isMovieInFavorites(movie)
                              ? Icons.favorite
                              : Icons.watch_later,
                          color: Colors.white,
                          size: screenWidth > 600 ? 16 : 14,
                        ),
                      ),
                    ),

                    // Rating Badge (Top Left)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.amber.withValues(alpha: 0.95),
                              Colors.orange.withValues(alpha: 0.95),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star,
                              color: Colors.white,
                              size: screenWidth > 600 ? 12 : 10,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              movie.voteAverage.toStringAsFixed(1),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: screenWidth > 600 ? 10 : 8,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withValues(alpha: 0.5),
                                    blurRadius: 2,
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

            // Movie Info Section
            Expanded(
              flex: 3,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Movie Title
                    Text(
                      movie.title,
                      style: MyStyles.title24White700.copyWith(
                        fontSize: screenWidth > 600 ? 14 : 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Year and Genre Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            movie.year,
                            style: MyStyles.title24White400.copyWith(
                              fontSize: screenWidth > 600 ? 10 : 8,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.blue.withValues(alpha: 0.3),
                                Colors.purple.withValues(alpha: 0.3),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            'Movie',
                            style: MyStyles.title24White400.copyWith(
                              fontSize: screenWidth > 600 ? 10 : 8,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
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

  void _navigateToMovieDetails(SavedMovieModel movie) {
    // Import the necessary classes
    // Convert SavedMovieModel to MovieModel for DetailsScreen
    try {
      final movieModel = _convertToMovieModel(movie);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetailsScreen(movie: movieModel),
        ),
      );
    } catch (e) {
      // Handle navigation error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to open movie details: ${movie.title}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  MovieModel _convertToMovieModel(SavedMovieModel movie) {
    // Convert SavedMovieModel to MovieModel
    return MovieModel(
      id: int.tryParse(movie.movieId) ?? movie.movieId.hashCode,
      title: movie.title,
      originalTitle: movie.originalTitle,
      posterPath: movie.posterPath,
      backdropPath: movie.backdropPath,
      releaseDate: movie.releaseDate,
      voteAverage: movie.voteAverage,
      voteCount: movie.voteCount,
      overview: movie.overview,
      genreIds: movie.genreIds,
      originalLanguage: movie.originalLanguage,
      popularity: movie.popularity,
      adult: false,
      video: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = _getCrossAxisCount(constraints.maxWidth);
        final spacing = _getSpacing(constraints.maxWidth);
        final padding = _getPadding(constraints.maxWidth);
        final childAspectRatio = _getChildAspectRatio(constraints.maxWidth);
        final isSmallScreen = constraints.maxWidth <= 400;
        final isMediumScreen = constraints.maxWidth <= 900;

        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: MyColors.secondaryColor,
            borderRadius:
                BorderRadius.circular(_getBorderRadius(constraints.maxWidth)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  left: padding / 2,
                  right: padding / 2,
                  bottom: padding,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'My Collection',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: _getTitleFontSize(constraints.maxWidth),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        if (!isSmallScreen) ...[
                          vSpace(padding / 4),
                          Text(
                            'Your favorite movies and TV shows',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize:
                                  _getSubtitleFontSize(constraints.maxWidth) *
                                      0.9,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: padding / 2,
                        vertical: padding / 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(padding / 2),
                        border: Border.all(
                          color: Colors.red.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.movie_outlined,
                            color: Colors.red,
                            size: _getSubtitleFontSize(constraints.maxWidth) *
                                1.2,
                          ),
                          hSpace(padding / 4),
                          Text(
                            '${_collectionMovies.length} items',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize:
                                  _getSubtitleFontSize(constraints.maxWidth),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              _buildGridContent(constraints, crossAxisCount, spacing,
                  childAspectRatio, isMediumScreen),
            ],
          ),
        );
      },
    );
  }

  double _getPlayIconSize(double width) {
    if (width <= 400) return 40;
    if (width <= 700) return 48;
    if (width <= 1000) return 56;
    return 64;
  }

  double _getItemBorderRadius(double width) {
    if (width <= 400) return 12;
    if (width <= 700) return 14;
    if (width <= 1000) return 16;
    return 18;
  }

  double _getChildAspectRatio(double width) {
    // Standard movie poster aspect ratio is 2:3 (width:height)
    // For the entire card including text, we'll use a slightly taller ratio
    // to accommodate the text content below the poster
    return 0.5; // This gives us roughly a 1:2 ratio which works well for movie posters with text
  }

  int _getCrossAxisCount(double width) {
    if (width <= 400) return 1;
    if (width <= 600) return 2;
    if (width <= 900) return 3;
    if (width <= 1200) return 4;
    if (width <= 1600) return 5;
    return 6; // Added 6 columns for very large screens
  }

  double _getSpacing(double width) {
    if (width <= 400) return 16;
    if (width <= 600) return 18;
    if (width <= 900) return 20;
    if (width <= 1200) return 24;
    if (width <= 1600) return 28;
    return 32; // Larger spacing for 6-column layout
  }

  double _getPadding(double width) {
    if (width <= 400) return 16;
    if (width <= 700) return 24;
    if (width <= 1000) return 32;
    return 40;
  }

  double _getBorderRadius(double width) {
    if (width <= 400) return 16;
    if (width <= 700) return 24;
    if (width <= 1000) return 28;
    return 32;
  }

  double _getTitleFontSize(double width) {
    if (width <= 400) return 20;
    if (width <= 700) return 22;
    if (width <= 1000) return 24;
    return 26;
  }

  double _getSubtitleFontSize(double width) {
    if (width <= 400) return 14;
    if (width <= 700) return 15;
    if (width <= 1000) return 16;
    return 17;
  }
}
