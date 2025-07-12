import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_proj/core/my_images.dart';
import 'package:movie_proj/core/my_styles.dart';
import 'package:movie_proj/core/my_text.dart';
import 'package:movie_proj/core/spacing.dart';
import 'package:movie_proj/feature/auth/widget/my_text_btns.dart';
import 'package:movie_proj/feature/auth/widget/social_btn.dart';
import 'package:movie_proj/feature/home/manage/popular_tv_cubit.dart';
import 'package:movie_proj/feature/home/model/tv-model.dart';
import 'package:movie_proj/feature/home/model/movie_model.dart';
import 'package:movie_proj/feature/details/details_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:async';

class HomeMostWatched extends StatefulWidget {
  const HomeMostWatched({super.key});

  @override
  State<HomeMostWatched> createState() => _HomeMostWatchedState();
}

class _HomeMostWatchedState extends State<HomeMostWatched> {
  PageController _pageController = PageController();
  Timer? _timer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Don't start auto slide immediately, wait for data to load
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoSlide() {
    _timer?.cancel(); // Cancel any existing timer
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_pageController.hasClients) {
        try {
          final tvState = context.read<PopularTVCubit>().state;
          if (tvState is PopularTVLoaded && tvState.tvShows.isNotEmpty) {
            _currentIndex = (_currentIndex + 1) % tvState.tvShows.length;
            _pageController.animateToPage(
              _currentIndex,
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOut,
            );
          }
        } catch (e) {
          // Handle any errors gracefully
          assert(() {
            debugPrint('Error in auto slide: $e');
            return true;
          }());
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bannerHeight = screenWidth > 600 ? 500.0 : 400.0;

    return BlocConsumer<PopularTVCubit, PopularTVState>(
      listener: (context, state) {
        // Restart auto slide when data is loaded
        if (state is PopularTVLoaded && state.tvShows.isNotEmpty) {
          _startAutoSlide();
        } else {
          _timer?.cancel();
        }
      },
      builder: (context, state) {
        if (state is PopularTVLoaded && state.tvShows.isNotEmpty) {
          return _buildAnimatedBanner(state.tvShows, screenWidth, bannerHeight);
        } else if (state is PopularTVLoading) {
          return _buildLoadingBanner(screenWidth, bannerHeight);
        } else if (state is PopularTVError) {
          return _buildErrorBanner(screenWidth, bannerHeight, state.message);
        } else {
          return _buildFallbackBanner(screenWidth, bannerHeight);
        }
      },
    );
  }

  Widget _buildAnimatedBanner(
      List<TvModel> tvShows, double screenWidth, double bannerHeight) {
    return Container(
      height: bannerHeight,
      child: Stack(
        children: [
          // Background Images with PageView
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: tvShows.length,
            itemBuilder: (context, index) {
              final tvShow = tvShows[index];
              return _buildBannerSlide(tvShow, screenWidth, bannerHeight);
            },
          ),
          // Page Indicators
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                tvShows.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentIndex == index ? 12 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentIndex == index
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: _currentIndex == index
                        ? [
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.3),
                              blurRadius: 4,
                              spreadRadius: 1,
                            )
                          ]
                        : null,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerSlide(
      TvModel tvShow, double screenWidth, double bannerHeight) {
    final contentWidth = screenWidth > 600 ? 350.0 : screenWidth * 0.8;
    final titleFontSize = screenWidth > 600 ? 48.0 : 32.0;
    final buttonWidth = screenWidth > 600 ? 120.0 : 100.0;

    return Builder(
      builder: (context) => GestureDetector(
        onTap: () => _navigateToTVDetails(context, tvShow),
        child: Stack(
          children: [
            // Background Image
            _BannerImage(
              imageUrl: tvShow.backdropPath != null
                  ? 'https://image.tmdb.org/t/p/w1280${tvShow.backdropPath}'
                  : (tvShow.posterPath != null
                      ? 'https://image.tmdb.org/t/p/w500${tvShow.posterPath}'
                      : ''),
              width: double.infinity,
              height: bannerHeight,
            ),
            // Gradient Overlay
            Container(
              width: double.infinity,
              height: bannerHeight,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                    Colors.black.withValues(alpha: 0.9),
                  ],
                ),
              ),
            ),
            // Content
            Positioned(
              top: screenWidth > 600 ? 150 : 100,
              left: screenWidth > 600 ? 30 : 20,
              child: Container(
                width: contentWidth,
                child: AnimatedOpacity(
                  opacity: 1.0,
                  duration: const Duration(milliseconds: 500),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tvShow.name ?? 'Unknown Title',
                        style: MyStyles.title24White700
                            .copyWith(fontSize: titleFontSize),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      vSpace(15),
                      Text(
                        tvShow.overview?.isNotEmpty == true
                            ? tvShow.overview!
                            : 'Popular TV Show • First aired: ${tvShow.firstAirDate?.split('-').first ?? 'Unknown'}',
                        style: MyStyles.title24White400.copyWith(fontSize: 14),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      vSpace(20),
                      Row(
                        children: [
                          Image.asset(MyImages.imdb, width: 50),
                          hSpace(10),
                          Text(
                            '${tvShow.voteAverage?.toStringAsFixed(1) ?? '0.0'}/10',
                            style:
                                MyStyles.title24White400.copyWith(fontSize: 14),
                          ),
                          hSpace(20),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'TV SERIES',
                              style: MyStyles.title24White400
                                  .copyWith(fontSize: 10),
                            ),
                          ),
                        ],
                      ),
                      vSpace(20),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          MyTextBtn(
                            onTap: () {},
                            text: MyText.addToPlaylist,
                            color: Colors.white,
                            textColor: Colors.black,
                            radius: 5,
                            width: buttonWidth,
                          ),
                          SocialBtn(
                            color: const Color(0xff6D6D6E),
                            textColor: Colors.white,
                            imagePath: MyImages.iconError,
                            radius: 5,
                            width: buttonWidth,
                            text: MyText.moreInfo,
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingBanner(double screenWidth, double bannerHeight) {
    return Container(
      height: bannerHeight,
      child: Stack(
        children: [
          Image.asset(
            MyImages.background,
            width: double.infinity,
            height: bannerHeight,
            fit: BoxFit.cover,
          ),
          Container(
            width: double.infinity,
            height: bannerHeight,
            color: Colors.black.withValues(alpha: 0.5),
            child: const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(
      double screenWidth, double bannerHeight, String message) {
    return Container(
      height: bannerHeight,
      child: Stack(
        children: [
          Image.asset(
            MyImages.background,
            width: double.infinity,
            height: bannerHeight,
            fit: BoxFit.cover,
          ),
          Container(
            width: double.infinity,
            height: bannerHeight,
            color: Colors.black.withValues(alpha: 0.7),
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
                    'Failed to load TV shows',
                    style: MyStyles.title24White400.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    style: MyStyles.title24White400.copyWith(
                      color: Colors.red,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackBanner(double screenWidth, double bannerHeight) {
    final contentWidth = screenWidth > 600 ? 350.0 : screenWidth * 0.8;
    final titleFontSize = screenWidth > 600 ? 48.0 : 32.0;
    final buttonWidth = screenWidth > 600 ? 120.0 : 100.0;

    return Stack(
      children: [
        Image.asset(
          MyImages.background,
          width: double.infinity,
          height: bannerHeight,
          fit: BoxFit.cover,
        ),
        Positioned(
          top: screenWidth > 600 ? 150 : 100,
          left: screenWidth > 600 ? 30 : 20,
          child: Container(
            width: contentWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  MyText.johnWick,
                  style: MyStyles.title24White700
                      .copyWith(fontSize: titleFontSize),
                ),
                vSpace(15),
                Text(
                  MyText.johnWickCaption,
                  style: MyStyles.title24White400.copyWith(fontSize: 14),
                ),
                vSpace(20),
                Row(
                  children: [
                    Image.asset(MyImages.imdb, width: 50),
                    hSpace(10),
                    Text(
                      '86.0/100',
                      style: MyStyles.title24White400.copyWith(fontSize: 14),
                    ),
                  ],
                ),
                vSpace(20),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    MyTextBtn(
                      onTap: () {},
                      text: MyText.addToPlaylist,
                      color: Colors.white,
                      textColor: Colors.black,
                      radius: 5,
                      width: buttonWidth,
                    ),
                    SocialBtn(
                      color: const Color(0xff6D6D6E),
                      textColor: Colors.white,
                      imagePath: MyImages.iconError,
                      radius: 5,
                      width: buttonWidth,
                      text: MyText.moreInfo,
                    )
                  ],
                )
              ],
            ),
          ),
        )
      ],
    );
  }

  void _navigateToTVDetails(BuildContext context, TvModel tvShow) {
    // Convert TvModel to MovieModel for compatibility with DetailsScreen
    final movieModel = MovieModel(
      adult: false,
      backdropPath: tvShow.backdropPath,
      genreIds: tvShow.genreIds,
      id: tvShow.id,
      originalLanguage: tvShow.originalLanguage,
      originalTitle: tvShow.originalName,
      overview: tvShow.overview,
      popularity: tvShow.popularity,
      posterPath: tvShow.posterPath,
      releaseDate: tvShow.firstAirDate,
      title: tvShow.name,
      video: false,
      voteAverage: tvShow.voteAverage,
      voteCount: tvShow.voteCount,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailsScreen(movie: movieModel),
      ),
    );
  }
}

class _BannerImage extends StatelessWidget {
  final String imageUrl;
  final double width;
  final double height;

  const _BannerImage({
    required this.imageUrl,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: imageUrl.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: imageUrl,
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
                // Log error in debug mode only
                assert(() {
                  debugPrint('Error loading banner image: $error');
                  return true;
                }());
                return _buildFallbackImage();
              },
              fadeInDuration: const Duration(milliseconds: 300),
              fadeOutDuration: const Duration(milliseconds: 300),
            )
          : _buildFallbackImage(),
    );
  }

  Widget _buildFallbackImage() {
    return Image.asset(
      MyImages.background,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey[800],
          child: const Center(
            child: Icon(
              Icons.image_not_supported,
              color: Colors.white54,
              size: 48,
            ),
          ),
        );
      },
    );
  }
}
