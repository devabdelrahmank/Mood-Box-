import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_proj/core/my_colors.dart';
import 'package:movie_proj/core/my_styles.dart';
import 'package:movie_proj/core/my_text.dart';
import 'package:movie_proj/core/spacing.dart';
import 'package:movie_proj/feature/details/details_screen.dart';
import 'package:movie_proj/feature/home/model/movie_model.dart';
import 'package:movie_proj/feature/suggest/manage/top_rated_cubit.dart';

class SuggestBody extends StatelessWidget {
  const SuggestBody({super.key});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<TopRatedCubit>().refreshTopRated();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              vSpace(30),
              Center(
                child: Text(
                  MyText.forYourTaste,
                  style: MyStyles.title24White700.copyWith(fontSize: 24),
                ),
              ),
              vSpace(16),
              Center(
                child: Text(
                  MyText.choseFiveMovies,
                  style: MyStyles.title24White400.copyWith(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
              vSpace(30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Top Rated Movies & TV Shows',
                    style: MyStyles.title24White700.copyWith(fontSize: 18),
                  ),
                  BlocBuilder<TopRatedCubit, TopRatedState>(
                    builder: (context, state) {
                      if (state is TopRatedLoaded) {
                        return IconButton(
                          onPressed: () {
                            context.read<TopRatedCubit>().shuffleCurrentItems();
                          },
                          icon: const Icon(
                            Icons.shuffle,
                            color: Colors.white,
                            size: 20,
                          ),
                          tooltip: 'Shuffle Order',
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
              vSpace(20),
              BlocBuilder<TopRatedCubit, TopRatedState>(
                builder: (context, state) {
                  if (state is TopRatedLoading) {
                    return _buildLoadingGrid(context);
                  } else if (state is TopRatedError) {
                    return _buildErrorGrid(context, state.message);
                  } else if (state is TopRatedLoaded) {
                    return _buildTopRatedGrid(context, state.items);
                  }
                  return _buildEmptyGrid(context);
                },
              ),
              vSpace(30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopRatedGrid(BuildContext context, List<TopRatedItem> items) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = _getCrossAxisCount(constraints.maxWidth);
        final spacing = _getSpacing(constraints.maxWidth);

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            childAspectRatio: 0.65,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return GestureDetector(
              onTap: () => _navigateToDetails(context, item),
              child: _buildTopRatedCard(item, constraints.maxWidth),
            );
          },
        );
      },
    );
  }

  Widget _buildLoadingGrid(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = _getCrossAxisCount(constraints.maxWidth);
        final spacing = _getSpacing(constraints.maxWidth);

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            childAspectRatio: 0.65,
          ),
          itemCount: 12, // Show 12 loading placeholders
          itemBuilder: (context, index) {
            return _buildLoadingCard(constraints.maxWidth);
          },
        );
      },
    );
  }

  Widget _buildErrorGrid(BuildContext context, String message) {
    return Container(
      height: 300,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading content',
              style: MyStyles.title24White700.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: MyStyles.title24White400.copyWith(fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<TopRatedCubit>().loadTopRated();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: MyColors.btnColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyGrid(BuildContext context) {
    return Container(
      height: 300,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.movie_outlined,
              color: Colors.grey,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'No content available',
              style: MyStyles.title24White700.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Please try again later',
              style: MyStyles.title24White400.copyWith(fontSize: 14),
            ),
          ],
        ),
      ),
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

  Widget _buildTopRatedCard(TopRatedItem item, double containerWidth) {
    final isSmallScreen = containerWidth <= 400;
    final isMediumScreen = containerWidth <= 700;

    return Container(
      decoration: BoxDecoration(
        color: MyColors.secondaryColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(10)),
              ),
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(10)),
                child: item.posterPath.isNotEmpty
                    ? Image.network(
                        'https://image.tmdb.org/t/p/w500${item.posterPath}',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildPlaceholderImage();
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return _buildLoadingImage();
                        },
                      )
                    : _buildPlaceholderImage(),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: MyStyles.title24White400.copyWith(
                      fontSize: isSmallScreen ? 10 : (isMediumScreen ? 11 : 12),
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: isSmallScreen ? 12 : 14,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        item.rating.toStringAsFixed(1),
                        style: MyStyles.title24White400.copyWith(
                          fontSize: isSmallScreen ? 8 : 10,
                          color: Colors.amber,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: item.isMovie ? Colors.blue : Colors.green,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item.isMovie ? 'Movie' : 'TV',
                          style: MyStyles.title24White400.copyWith(
                            fontSize: isSmallScreen ? 6 : 8,
                            color: Colors.white,
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
    );
  }

  Widget _buildLoadingCard(double containerWidth) {
    final isSmallScreen = containerWidth <= 400;

    return Container(
      decoration: BoxDecoration(
        color: MyColors.secondaryColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(10)),
                color: Colors.grey[800],
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.white54,
                  strokeWidth: 2,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 12,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[700],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 8,
                    width: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey[700],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: Colors.grey[800],
      child: const Center(
        child: Icon(
          Icons.movie,
          color: Colors.white54,
          size: 48,
        ),
      ),
    );
  }

  Widget _buildLoadingImage() {
    return Container(
      color: Colors.grey[800],
      child: const Center(
        child: CircularProgressIndicator(
          color: Colors.white54,
          strokeWidth: 2,
        ),
      ),
    );
  }

  void _navigateToDetails(BuildContext context, TopRatedItem item) {
    if (item.isMovie && item.movieData != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetailsScreen(movie: item.movieData!),
        ),
      );
    } else if (!item.isMovie && item.tvData != null) {
      // Convert TvModel to MovieModel for compatibility with DetailsScreen
      final movieModel = MovieModel(
        adult: false,
        backdropPath: item.tvData!.backdropPath,
        genreIds: item.tvData!.genreIds,
        id: item.tvData!.id,
        originalLanguage: item.tvData!.originalLanguage,
        originalTitle: item.tvData!.originalName,
        overview: item.tvData!.overview,
        popularity: item.tvData!.popularity,
        posterPath: item.tvData!.posterPath,
        releaseDate: item.tvData!.firstAirDate,
        title: item.tvData!.name,
        video: false,
        voteAverage: item.tvData!.voteAverage,
        voteCount: item.tvData!.voteCount,
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetailsScreen(movie: movieModel),
        ),
      );
    }
  }
}
