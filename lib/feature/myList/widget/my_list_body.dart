import 'package:flutter/material.dart';
import 'package:movie_proj/core/my_colors.dart';
import 'package:movie_proj/core/my_images.dart';
import 'package:movie_proj/core/my_styles.dart';
import 'package:movie_proj/core/my_text.dart';
import 'package:movie_proj/core/spacing.dart';
import 'package:movie_proj/feature/user_lists/service/user_lists_service.dart';
import 'package:movie_proj/feature/user_lists/model/saved_movie_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:movie_proj/feature/details/details_screen.dart';
import 'package:movie_proj/feature/home/model/movie_model.dart';

class MyListBody extends StatefulWidget {
  const MyListBody({super.key});

  @override
  State<MyListBody> createState() => _MyListBodyState();
}

class _MyListBodyState extends State<MyListBody> {
  List<SavedMovieModel> favoriteMovies = [];
  List<SavedMovieModel> watchLaterMovies = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserLists();
  }

  Future<void> _loadUserLists() async {
    try {
      final favorites = await UserListsService.getFavorites();
      final watchLater = await UserListsService.getWatchLater();

      if (mounted) {
        setState(() {
          favoriteMovies = favorites;
          watchLaterMovies = watchLater;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

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
                    _buildSection(constraints, MyText.myFavorite, 'favorites'),
                    vSpace(24),
                    _buildSection(constraints, MyText.iWant, 'watchLater'),
                    vSpace(24),
                    // _buildSection(
                    //     constraints, MyText.myFavoriteActor, 'actors'),
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
      BoxConstraints constraints, String title, String sectionType) {
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
        _buildPosterGrid(constraints, sectionType),
      ],
    );
  }

  double _getTitleFontSize(double width) {
    if (width <= 400) return 16;
    if (width <= 700) return 18;
    return 20;
  }

  Widget _buildPosterGrid(BoxConstraints constraints, String sectionType) {
    final crossAxisCount = _getCrossAxisCount(constraints.maxWidth);
    final spacing = _getSpacing(constraints.maxWidth);

    List<SavedMovieModel> movies = [];
    if (sectionType == 'favorites') {
      movies = favoriteMovies;
    } else if (sectionType == 'watchLater') {
      movies = watchLaterMovies;
    } else {
      // For actors section, keep placeholder for now
      return _buildPlaceholderGrid(constraints, crossAxisCount, spacing);
    }

    if (isLoading) {
      return _buildLoadingGrid(constraints, crossAxisCount, spacing);
    }

    if (movies.isEmpty) {
      return _buildEmptyGrid(constraints, sectionType);
    }

    // Show up to crossAxisCount * 2 movies (2 rows)
    final displayMovies = movies.take(crossAxisCount * 2).toList();
    final posters = displayMovies
        .map((movie) => _buildMoviePoster(constraints.maxWidth, movie))
        .toList();

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

  Widget _buildMoviePoster(double containerWidth, SavedMovieModel movie) {
    final posterWidth = _getPosterWidth(containerWidth);
    final posterHeight = posterWidth * 1.5; // 3:2 aspect ratio

    return GestureDetector(
      onTap: () => _navigateToMovieDetails(movie),
      child: Container(
        width: posterWidth,
        height: posterHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            fit: StackFit.expand,
            children: [
              movie.posterPath.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl:
                          'https://image.tmdb.org/t/p/w500${movie.posterPath}',
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
              // Delete button
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: 18,
                    ),
                    onPressed: () => _showDeleteConfirmation(movie),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorPoster() {
    return Container(
      color: Colors.grey[800],
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image,
            color: Colors.white54,
            size: 32,
          ),
          SizedBox(height: 4),
          Text(
            'No Image',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderGrid(
      BoxConstraints constraints, int crossAxisCount, double spacing) {
    final posters = List.generate(
      crossAxisCount,
      (index) => _buildResponsivePoster(constraints.maxWidth, MyImages.dunkirk),
    );

    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      children: posters,
    );
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
            Colors.black.withValues(alpha: 0.1),
            BlendMode.darken,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingGrid(
      BoxConstraints constraints, int crossAxisCount, double spacing) {
    final posterWidth = _getPosterWidth(constraints.maxWidth);
    final posterHeight = posterWidth * 1.5;

    final loadingPosters = List.generate(
      crossAxisCount,
      (index) => Container(
        width: posterWidth,
        height: posterHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey[800],
        ),
        child: const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        ),
      ),
    );

    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      children: loadingPosters,
    );
  }

  Widget _buildEmptyGrid(BoxConstraints constraints, String sectionType) {
    final posterWidth = _getPosterWidth(constraints.maxWidth);
    final posterHeight = posterWidth * 1.5;

    String emptyMessage = '';
    if (sectionType == 'favorites') {
      emptyMessage = 'No favorite movies yet';
    } else if (sectionType == 'watchLater') {
      emptyMessage = 'No movies in watch later';
    }

    return Container(
      width: double.infinity,
      height: posterHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey[800]?.withValues(alpha: 0.3),
        border: Border.all(
          color: Colors.grey[600]!,
          style: BorderStyle.solid,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            sectionType == 'favorites'
                ? Icons.favorite_border
                : Icons.watch_later_outlined,
            color: Colors.grey[400],
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            emptyMessage,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _navigateToMovieDetails(SavedMovieModel movie) {
    // Convert SavedMovieModel to MovieModel for DetailsScreen
    final movieModel = MovieModel(
      adult: false,
      backdropPath: movie.backdropPath,
      genreIds: movie.genreIds,
      id: int.tryParse(movie.movieId) ?? movie.movieId.hashCode,
      originalLanguage: movie.originalLanguage,
      originalTitle: movie.originalTitle,
      overview: movie.overview,
      popularity: movie.popularity,
      posterPath: movie.posterPath,
      releaseDate: movie.releaseDate,
      title: movie.title,
      video: false,
      voteAverage: movie.voteAverage,
      voteCount: movie.voteCount,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailsScreen(movie: movieModel),
      ),
    );
  }

  double _getPosterWidth(double containerWidth) {
    final crossAxisCount = _getCrossAxisCount(containerWidth);
    final spacing = _getSpacing(containerWidth);
    return (containerWidth - (spacing * (crossAxisCount - 1))) / crossAxisCount;
  }

  void _showDeleteConfirmation(SavedMovieModel movie) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: MyColors.secondaryColor,
          title: const Text(
            'Remove Movie',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'Are you sure you want to remove "${movie.title}" from your list?',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteMovie(movie);
              },
              child: const Text(
                'Remove',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _deleteMovie(SavedMovieModel movie) async {
    try {
      bool success = false;
      String message = '';

      // Determine which list the movie is in and remove it
      if (favoriteMovies.any((fav) => fav.movieId == movie.movieId)) {
        success = await UserListsService.removeFromFavorites(movie.movieId);
        message = success
            ? 'Removed from favorites!'
            : 'Failed to remove from favorites.';
      } else if (watchLaterMovies
          .any((watch) => watch.movieId == movie.movieId)) {
        success = await UserListsService.removeFromWatchLater(movie.movieId);
        message = success
            ? 'Removed from watch later!'
            : 'Failed to remove from watch later.';
      }

      if (!mounted) return;

      if (success) {
        // Refresh the lists
        await _loadUserLists();

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.check_circle,
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
            backgroundColor: Colors.green,
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
                  Icons.error,
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
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
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
                  'Failed to remove movie. Please try again.',
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
}
