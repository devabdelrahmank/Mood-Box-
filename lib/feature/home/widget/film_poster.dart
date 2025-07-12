import 'package:flutter/material.dart';
import 'package:movie_proj/core/my_styles.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:movie_proj/feature/home/model/movie_model.dart';
import 'package:movie_proj/feature/user_lists/service/user_lists_service.dart';
import 'package:movie_proj/feature/user_lists/model/saved_movie_model.dart';
import 'package:movie_proj/core/my_colors.dart';

class FilmPoster extends StatefulWidget {
  final String imagePath;
  final String title;
  final bool isNetworkImage;
  final VoidCallback? onTap;
  final MovieModel? movieData; // Add movie data for favorites/watch later
  final bool
      showActionIcons; // Control whether to show favorite/watch later icons

  const FilmPoster({
    super.key,
    required this.imagePath,
    required this.title,
    this.isNetworkImage = false,
    this.onTap,
    this.movieData,
    this.showActionIcons = true,
  });

  @override
  State<FilmPoster> createState() => _FilmPosterState();
}

class _FilmPosterState extends State<FilmPoster> {
  bool _isInFavorites = false;
  bool _isInWatchLater = false;

  @override
  void initState() {
    super.initState();
    _checkMovieStatus();
  }

  @override
  void didUpdateWidget(FilmPoster oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Refresh status if movie data changed
    if (oldWidget.movieData != widget.movieData) {
      _checkMovieStatus();
    }
  }

  Future<void> _checkMovieStatus() async {
    if (widget.movieData == null) return;

    try {
      final movieId = widget.movieData!.id?.toString() ??
          widget.movieData!.title.hashCode.toString();

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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: 200,
        height: 300,
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
            fit: StackFit.expand,
            children: [
              _buildImage(),
              _buildGradientOverlay(),
              _buildTitle(),
              if (widget.movieData != null && widget.showActionIcons)
                _buildActionIcons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (widget.isNetworkImage && widget.imagePath.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: widget.imagePath,
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
        errorWidget: (context, url, error) {
          return _buildErrorPlaceholder();
        },
        fadeInDuration: const Duration(milliseconds: 300),
        fadeOutDuration: const Duration(milliseconds: 300),
      );
    } else if (!widget.isNetworkImage && widget.imagePath.isNotEmpty) {
      return Image.asset(
        widget.imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorPlaceholder();
        },
      );
    } else {
      return _buildErrorPlaceholder();
    }
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      color: Colors.grey[800],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.broken_image,
            color: Colors.white54,
            size: 48,
          ),
          const SizedBox(height: 8),
          Text(
            'Image not available',
            style: MyStyles.title24White400.copyWith(
              fontSize: 12,
              color: Colors.white54,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      height: 100,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withValues(alpha: 0.8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          widget.title,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: MyStyles.title24White400.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            height: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildActionIcons() {
    return Positioned(
      top: 8,
      right: 8,
      child: Column(
        children: [
          // Favorite Icon
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: _isInFavorites
                  ? Colors.red.withValues(alpha: 0.9)
                  : Colors.black.withValues(alpha: 0.6),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(
                _isInFavorites ? Icons.favorite : Icons.favorite_border,
                color: Colors.white,
                size: 18,
              ),
              onPressed: () => _toggleFavorites(),
            ),
          ),
          // Watch Later Icon
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _isInWatchLater
                  ? MyColors.primaryColor.withValues(alpha: 0.9)
                  : Colors.black.withValues(alpha: 0.6),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(
                _isInWatchLater
                    ? Icons.watch_later
                    : Icons.watch_later_outlined,
                color: Colors.white,
                size: 18,
              ),
              onPressed: () => _toggleWatchLater(),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleFavorites() async {
    if (widget.movieData == null) return;

    try {
      final movieId = widget.movieData!.id?.toString() ??
          widget.movieData!.title.hashCode.toString();

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
        final savedMovie = SavedMovieModel.fromMovieModel(widget.movieData!);
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
    if (widget.movieData == null) return;

    try {
      final movieId = widget.movieData!.id?.toString() ??
          widget.movieData!.title.hashCode.toString();

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
        final savedMovie = SavedMovieModel.fromMovieModel(widget.movieData!);
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
}
