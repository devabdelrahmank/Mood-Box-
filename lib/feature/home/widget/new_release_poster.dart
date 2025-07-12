import 'package:flutter/material.dart';
import 'package:movie_proj/core/my_styles.dart';
import 'package:movie_proj/core/my_images.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:movie_proj/feature/home/model/movie_model.dart';
import 'package:movie_proj/feature/user_lists/service/user_lists_service.dart';
import 'package:movie_proj/feature/user_lists/model/saved_movie_model.dart';
import 'package:movie_proj/core/my_colors.dart';

class NewReleasePoster extends StatefulWidget {
  final String imagePath;
  final String title;
  final String year;
  final String rating;
  final String boxOffice;
  final bool isNetworkImage;
  final VoidCallback? onTap;
  final MovieModel? movieData;

  const NewReleasePoster({
    super.key,
    required this.imagePath,
    required this.title,
    required this.year,
    required this.rating,
    required this.boxOffice,
    this.isNetworkImage = false,
    this.onTap,
    this.movieData,
  });

  @override
  State<NewReleasePoster> createState() => _NewReleasePosterState();
}

class _NewReleasePosterState extends State<NewReleasePoster> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: 200,
        height: 320,
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
              _buildNewReleaseTag(),
              _buildMovieInfo(),
              _buildIMDbRating(),
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
      height: 120,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withValues(alpha: 0.9),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNewReleaseTag() {
    return Positioned(
      top: 8,
      left: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          'NEW',
          style: MyStyles.title24White400.copyWith(
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildMovieInfo() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            12, 12, 12, 50), // Extra bottom padding for IMDb box
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: MyStyles.title24White400.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  widget.year,
                  style: MyStyles.title24White400.copyWith(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
                if (widget.boxOffice.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.attach_money,
                    color: Colors.green,
                    size: 12,
                  ),
                  const SizedBox(width: 2),
                  Expanded(
                    child: Text(
                      widget.boxOffice,
                      style: MyStyles.title24White400.copyWith(
                        fontSize: 10,
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIMDbRating() {
    // Only show IMDb rating if rating is available and not empty
    if (widget.rating.isEmpty || widget.rating == '0.0') {
      return const SizedBox.shrink();
    }

    return Positioned(
      bottom: 12,
      left: 12,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF000000).withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFFF5C518), // IMDb yellow color
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              MyImages.imdb,
              width: 24,
              height: 14,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 6),
            Text(
              widget.rating,
              style: MyStyles.title24White400.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              '/10',
              style: MyStyles.title24White400.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
