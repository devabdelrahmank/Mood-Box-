import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_proj/core/const.dart';
import 'package:movie_proj/core/my_colors.dart';
import 'package:movie_proj/core/my_images.dart';
import 'package:movie_proj/core/my_styles.dart';
import 'package:movie_proj/core/my_text.dart';
import 'package:movie_proj/core/spacing.dart';
import 'package:movie_proj/core/widget/movie_app_bar.dart';
import 'package:movie_proj/feature/home/manage/top_movies_cubit.dart';
import 'package:movie_proj/feature/home/manage/new_release_cubit.dart';
import 'package:movie_proj/feature/home/manage/popular_tv_cubit.dart';
import 'package:movie_proj/feature/home/manage/picked_for_you_cubit.dart';
import 'package:movie_proj/feature/home/model/movie_model.dart';
import 'package:movie_proj/feature/home/model/tv-model.dart';
import 'package:movie_proj/feature/home/widget/film_avatars.dart';

import 'package:movie_proj/feature/home/widget/film_poster.dart';
import 'package:movie_proj/feature/home/widget/new_release_poster.dart';
import 'package:movie_proj/feature/home/widget/home_most_watched.dart';
import 'package:movie_proj/feature/details/details_screen.dart';
import 'package:movie_proj/feature/user_lists/service/user_lists_service.dart';
import 'package:movie_proj/feature/user_lists/model/saved_movie_model.dart';

import 'package:cached_network_image/cached_network_image.dart';

class HomeScreen extends StatefulWidget {
  final Function(int) onNavigate;

  const HomeScreen({
    super.key,
    required this.onNavigate,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  bool _isRefreshing = false;
  DateTime? _lastDataLoadTime;
  static const Duration _dataRefreshInterval =
      Duration(minutes: 30); // تحديث البيانات كل 30 دقيقة

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Load all data from new services when the screen is first mounted
    _loadAllData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // تحديث البيانات فقط إذا مر وقت كافي منذ آخر تحديث
    if (state == AppLifecycleState.resumed && mounted) {
      _loadDataIfNeeded();
    }
  }

  void _loadAllData() {
    Future.microtask(() {
      if (mounted) {
        // Load data from all new services (سيتم التحميل فقط إذا لم تكن البيانات محملة)
        context.read<TopMoviesCubit>().loadTopMovies();
        context.read<NewReleaseCubit>().loadNewReleases();
        context.read<PopularTVCubit>().loadPopularTV();
        context.read<PickedForYouCubit>().loadPickedForYou();

        // تحديث وقت آخر تحميل
        _lastDataLoadTime = DateTime.now();
      }
    });
  }

  void _loadDataIfNeeded() {
    final now = DateTime.now();

    // إذا لم يتم تحميل البيانات من قبل أو مر وقت كافي منذ آخر تحديث
    if (_lastDataLoadTime == null ||
        now.difference(_lastDataLoadTime!) > _dataRefreshInterval) {
      _refreshAllData();
    } else {
      // تحميل البيانات فقط إذا لم تكن محملة (بدون إجبار التحديث)
      _loadAllData();
    }
  }

  // دالة لإعادة تعيين البيانات (مفيدة عند تغيير الإعدادات أو تسجيل الدخول)
  void resetData() {
    _lastDataLoadTime = null;
    _refreshAllData();
  }

  Future<void> _refreshAllData() async {
    if (_isRefreshing || !mounted) return;

    setState(() {
      _isRefreshing = true;
    });

    try {
      // Refresh all data from new services
      await Future.wait([
        context.read<TopMoviesCubit>().refreshTopMovies(),
        context.read<NewReleaseCubit>().refreshNewReleases(),
        context.read<PopularTVCubit>().refreshPopularTV(),
        context.read<PickedForYouCubit>().refreshPickedForYou(),
      ]);

      // تحديث وقت آخر تحميل بعد نجاح التحديث
      _lastDataLoadTime = DateTime.now();
    } catch (e) {
      // Handle errors gracefully
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to refresh data: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth > 600 ? 60.0 : 20.0;

    return Scaffold(
      backgroundColor: MyColors.primaryColor,
      appBar: MovieAppBar(
        currentIndex: 0,
        onNavigate: widget.onNavigate,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshAllData,
        color: Colors.white,
        backgroundColor: MyColors.primaryColor,
        strokeWidth: 2.5,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      MyText.mostWatched,
                      style: MyStyles.title24White400,
                    ),
                    if (_isRefreshing) ...[
                      const SizedBox(width: 10),
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const HomeMostWatched(),
              vSpace(30),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(MyText.tvShows,
                        style: MyStyles.title24White400.copyWith(fontSize: 14)),
                    hSpace(40),
                    Text(MyText.movies,
                        style: MyStyles.title24White400.copyWith(fontSize: 14)),
                    hSpace(40),
                    Text(MyText.newPopular,
                        style: MyStyles.title24White400.copyWith(fontSize: 14)),
                    hSpace(40),
                    Text(MyText.myList,
                        style: MyStyles.title24White400.copyWith(fontSize: 14)),
                    hSpace(40),
                    Text(MyText.browseByLanguage,
                        style: MyStyles.title24White400.copyWith(fontSize: 14)),
                  ],
                ),
              ),
              vSpace(30),
              Center(
                child: Text(
                  'top Movies',
                  style: MyStyles.title24White400.copyWith(
                    fontSize: screenWidth > 600 ? 24.0 : 20.0,
                  ),
                ),
              ),
              vSpace(30),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: BlocBuilder<TopMoviesCubit, TopMoviesState>(
                  builder: (context, state) {
                    if (state is TopMoviesLoading) {
                      return _buildLoadingState(screenWidth);
                    } else if (state is TopMoviesError) {
                      return _buildErrorState(state.message, context);
                    } else if (state is TopMoviesLoaded) {
                      final movies = state.movies;
                      if (movies.isEmpty) {
                        return _buildEmptyState();
                      }
                      return _buildMoviesLayout(movies, screenWidth);
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
              vSpace(50),
              // const FilmInfoWidget(
              //   text: MyText.newRelease,
              // ),
              // vSpace(30),
              //! New Release Movies Section
              Center(
                child: Text(
                  'New Release Movies',
                  style: MyStyles.title24White400.copyWith(
                    fontSize: screenWidth > 600 ? 24.0 : 20.0,
                  ),
                ),
              ),
              vSpace(30),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: BlocBuilder<NewReleaseCubit, NewReleaseState>(
                  builder: (context, state) {
                    if (state is NewReleaseLoading) {
                      return _buildNewReleaseLoadingState(screenWidth);
                    } else if (state is NewReleaseError) {
                      return _buildNewReleaseErrorState(state.message, context);
                    } else if (state is NewReleaseLoaded) {
                      final movies = state.movies;
                      if (movies.isEmpty) {
                        return _buildNewReleaseEmptyState();
                      }
                      return _buildNewReleaseLayout(movies, screenWidth);
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
              vSpace(50),
              // const FilmInfoWidget(
              //   text: 'Popular TV Shows',
              // ),
              Center(
                child: Text(
                  'Popular TV Shows',
                  style: MyStyles.title24White400.copyWith(
                    fontSize: screenWidth > 600 ? 24.0 : 20.0,
                  ),
                ),
              ),
              vSpace(30),
              //! Popular TV Shows Section
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: BlocBuilder<PopularTVCubit, PopularTVState>(
                  builder: (context, state) {
                    if (state is PopularTVLoading) {
                      return _buildPopularTVLoadingState(screenWidth);
                    } else if (state is PopularTVError) {
                      return _buildPopularTVErrorState(state.message, context);
                    } else if (state is PopularTVLoaded) {
                      final tvShows = state.tvShows;
                      if (tvShows.isEmpty) {
                        return _buildPopularTVEmptyState();
                      }
                      return _buildPopularTVLayout(tvShows, screenWidth);
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
              vSpace(30),
              Center(
                child: Text(
                  'Picked for You',
                  style: MyStyles.title24White400.copyWith(
                    fontSize: screenWidth > 600 ? 24.0 : 20.0,
                  ),
                ),
              ),
              vSpace(30),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: BlocBuilder<PickedForYouCubit, PickedForYouState>(
                  builder: (context, state) {
                    if (state is PickedForYouLoading) {
                      return _buildPickedForYouLoadingState(screenWidth);
                    } else if (state is PickedForYouError) {
                      return _buildPickedForYouErrorState(
                          state.message, context);
                    } else if (state is PickedForYouLoaded) {
                      final movies = state.movies;
                      if (movies.isEmpty) {
                        return _buildPickedForYouEmptyState();
                      }
                      return _buildPickedForYouLayout(movies, screenWidth);
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
              vSpace(50),
              const FilmAvatars(),
              vSpace(30),
              dSpace(),
              vSpace(20)
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState(double screenWidth) {
    return SizedBox(
      height: 300,
      child: screenWidth > 900
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                5,
                (index) => _buildLoadingSkeleton(),
              ),
            )
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(
                  5,
                  (index) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: _buildLoadingSkeleton(),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return Container(
      width: 200,
      height: 300,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildErrorState(String message, BuildContext context) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(20),
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
            'Failed to load movies',
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
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<TopMoviesCubit>().loadTopMovies();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: MyColors.btnColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.movie_outlined,
            color: Colors.grey[600],
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'No movies available',
            style: MyStyles.title24White400.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for new releases',
            style: MyStyles.title24White400.copyWith(
              color: Colors.grey[600],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMoviesLayout(List<MovieModel> movies, double screenWidth) {
    if (screenWidth > 900) {
      // Desktop layout - show movies in a responsive grid
      return _buildDesktopLayout(movies);
    } else {
      // Mobile/Tablet layout - horizontal scroll
      return _buildMobileLayout(movies);
    }
  }

  Widget _buildDesktopLayout(List<MovieModel> movies) {
    // Show up to 5 movies in a row for desktop
    final displayMovies = movies.take(5).toList();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: displayMovies
          .map((movie) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: FilmPoster(
                    imagePath: {kmoviedbImageURL + movie.backdropPath!}.isEmpty
                        ? ''
                        : kmoviedbImageURL + movie.posterUrl,
                    title: movie.title!,
                    isNetworkImage: true,
                    onTap: () => _navigateToDetails(movie),
                    movieData: movie,
                    showActionIcons: false,
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildMobileLayout(List<MovieModel> movies) {
    return SizedBox(
      height: 300,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: movies
              .map((movie) => Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: FilmPoster(
                      imagePath: movie.posterUrl.isNotEmpty
                          ? 'https://image.tmdb.org/t/p/w500${movie.posterUrl}'
                          : '',
                      title: movie.title!,
                      isNetworkImage: true,
                      onTap: () => _navigateToDetails(movie),
                      movieData: movie,
                      showActionIcons: false,
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }

  // New Release Methods
  Widget _buildNewReleaseLoadingState(double screenWidth) {
    return SizedBox(
      height: 320,
      child: screenWidth > 900
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                4, // Show 4 items for desktop
                (index) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: _buildNewReleaseLoadingSkeleton(),
                  ),
                ),
              ),
            )
          : ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: 6, // Show 6 items for mobile
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(right: 16),
                child: _buildNewReleaseLoadingSkeleton(),
              ),
            ),
    );
  }

  Widget _buildNewReleaseLoadingSkeleton() {
    return Container(
      width: 200,
      height: 320,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Image placeholder
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            ),
          ),
          // Text placeholders
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 16,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[600],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 12,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey[600],
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

  Widget _buildNewReleaseErrorState(String message, BuildContext context) {
    return Container(
      height: 320,
      padding: const EdgeInsets.all(20),
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
            'Failed to load new releases',
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
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<NewReleaseCubit>().loadNewReleases();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: MyColors.btnColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildNewReleaseEmptyState() {
    return Container(
      height: 320,
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.new_releases_outlined,
            color: Colors.grey[600],
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'No new releases available',
            style: MyStyles.title24White400.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for new movies',
            style: MyStyles.title24White400.copyWith(
              color: Colors.grey[600],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNewReleaseLayout(List<MovieModel> movies, double screenWidth) {
    if (screenWidth > 900) {
      // Desktop layout - show movies in a responsive grid
      return _buildNewReleaseDesktopLayout(movies);
    } else {
      // Mobile/Tablet layout - horizontal scroll
      return _buildNewReleaseMobileLayout(movies);
    }
  }

  Widget _buildNewReleaseDesktopLayout(List<MovieModel> movies) {
    // Show up to 4 movies in a row for desktop
    final displayMovies = movies.take(4).toList();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: displayMovies
          .map((movie) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: NewReleasePoster(
                    imagePath: movie.posterUrl.isNotEmpty
                        ? 'https://image.tmdb.org/t/p/w500${movie.posterUrl}'
                        : '',
                    title: movie.title ?? 'Unknown Title',
                    year: movie.year,
                    rating: movie.rating,
                    boxOffice: '', // Box office not available in MovieModel
                    isNetworkImage: true,
                    onTap: () => _navigateToDetails(movie),
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildNewReleaseMobileLayout(List<MovieModel> movies) {
    // Show up to 8 movies for mobile to improve performance
    final displayMovies = movies.take(8).toList();
    return SizedBox(
      height: 320,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: displayMovies.length,
        itemBuilder: (context, index) {
          final movie = displayMovies[index];
          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: NewReleasePoster(
              imagePath: movie.posterUrl.isNotEmpty
                  ? 'https://image.tmdb.org/t/p/w500${movie.posterUrl}'
                  : '',
              title: movie.title ?? 'Unknown Title',
              year: movie.year,
              rating: movie.rating,
              boxOffice: '', // Box office not available in MovieModel
              isNetworkImage: true,
              onTap: () => _navigateToDetails(movie),
            ),
          );
        },
      ),
    );
  }

  // Popular TV Shows Methods
  Widget _buildPopularTVLoadingState(double screenWidth) {
    return Container(
      height: 320,
      child: const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildPopularTVErrorState(String message, BuildContext context) {
    return Container(
      height: 320,
      padding: const EdgeInsets.all(20),
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
            'Failed to load popular TV shows',
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
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<PopularTVCubit>().loadPopularTV();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: MyColors.btnColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularTVEmptyState() {
    return Container(
      height: 320,
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.tv_outlined,
            color: Colors.grey[600],
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'No popular TV shows available',
            style: MyStyles.title24White400.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for popular shows',
            style: MyStyles.title24White400.copyWith(
              color: Colors.grey[600],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPopularTVLayout(List<TvModel> tvShows, double screenWidth) {
    if (screenWidth > 900) {
      // Desktop layout - show TV shows in a responsive grid
      return _buildPopularTVDesktopLayout(tvShows);
    } else {
      // Mobile/Tablet layout - horizontal scroll
      return _buildPopularTVMobileLayout(tvShows);
    }
  }

  Widget _buildPopularTVDesktopLayout(List<TvModel> tvShows) {
    return Container(
      height: 320,
      child: GridView.builder(
        scrollDirection: Axis.horizontal,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
          mainAxisSpacing: 20,
          childAspectRatio: 1.5,
        ),
        itemCount: tvShows.length,
        itemBuilder: (context, index) {
          final tvShow = tvShows[index];
          return _buildTVShowCard(tvShow);
        },
      ),
    );
  }

  Widget _buildPopularTVMobileLayout(List<TvModel> tvShows) {
    return Container(
      height: 320,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tvShows.length,
        itemBuilder: (context, index) {
          final tvShow = tvShows[index];
          return Container(
            width: 200,
            margin: EdgeInsets.only(
              left: index == 0 ? 0 : 10,
              right: index == tvShows.length - 1 ? 0 : 10,
            ),
            child: _buildTVShowCard(tvShow),
          );
        },
      ),
    );
  }

  Widget _buildTVShowCard(TvModel tvShow) {
    return GestureDetector(
      onTap: () => _navigateToTVDetails(tvShow),
      child: Card(
        color: MyColors.secondaryColor,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TV Show Poster
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  color: Colors.grey[800],
                ),
                child: Stack(
                  children: [
                    // Poster Image
                    tvShow.posterPath != null && tvShow.posterPath!.isNotEmpty
                        ? ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12)),
                            child: Image.network(
                              'https://image.tmdb.org/t/p/w500${tvShow.posterPath}',
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[800],
                                  child: const Icon(
                                    Icons.tv,
                                    color: Colors.white54,
                                    size: 48,
                                  ),
                                );
                              },
                            ),
                          )
                        : const Icon(
                            Icons.tv,
                            color: Colors.white54,
                            size: 48,
                          ),
                  ],
                ),
              ),
            ),
            // TV Show Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tvShow.name ?? 'Unknown Title',
                      style: MyStyles.title24White400.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    _buildTVShowIMDbRatingInline(tvShow),
                    const SizedBox(height: 4),
                    Text(
                      tvShow.firstAirDate?.split('-').first ?? 'Unknown Year',
                      style: MyStyles.title24White400.copyWith(
                        fontSize: 12,
                        color: Colors.grey[400],
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Text(
                    //   tvShow.overview ?? 'No description available',
                    //   style: MyStyles.title24White400.copyWith(
                    //     fontSize: 10,
                    //     color: Colors.grey[500],
                    //   ),
                    //   maxLines: 2,
                    //   overflow: TextOverflow.ellipsis,
                    // ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTVShowIMDbRatingInline(TvModel tvShow) {
    // Only show IMDb rating if rating is available and not empty
    final rating = tvShow.voteAverage?.toStringAsFixed(1) ?? '0.0';
    if (rating == '0.0') {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF000000).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: const Color.fromARGB(114, 245, 197, 24), // IMDb yellow color
          width: 1.2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            MyImages.imdb,
            width: 20,
            height: 12,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 4),
          Text(
            rating,
            style: MyStyles.title24White400.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            '/10',
            style: MyStyles.title24White400.copyWith(
              fontSize: 9,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  // Picked For You Methods
  Widget _buildPickedForYouLoadingState(double screenWidth) {
    return Container(
      height: 280,
      child: const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildPickedForYouErrorState(String message, BuildContext context) {
    return Container(
      height: 280,
      padding: const EdgeInsets.all(20),
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
            'Failed to load recommendations',
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
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<PickedForYouCubit>().loadPickedForYou();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: MyColors.btnColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildPickedForYouEmptyState() {
    return Container(
      height: 280,
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.recommend_outlined,
            color: Colors.grey[600],
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'No recommendations available',
            style: MyStyles.title24White400.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for personalized picks',
            style: MyStyles.title24White400.copyWith(
              color: Colors.grey[600],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPickedForYouLayout(List<MovieModel> movies, double screenWidth) {
    if (screenWidth > 900) {
      // Desktop layout - show movies in a responsive grid
      return _buildPickedForYouDesktopLayout(movies);
    } else {
      // Mobile/Tablet layout - horizontal scroll
      return _buildPickedForYouMobileLayout(movies);
    }
  }

  Widget _buildPickedForYouDesktopLayout(List<MovieModel> movies) {
    return Container(
      height: 280,
      child: GridView.builder(
        scrollDirection: Axis.horizontal,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
          mainAxisSpacing: 15,
          childAspectRatio: 1.4,
        ),
        itemCount: movies.length,
        itemBuilder: (context, index) {
          final movie = movies[index];
          return _buildPickedForYouCard(movie);
        },
      ),
    );
  }

  Widget _buildPickedForYouMobileLayout(List<MovieModel> movies) {
    return Container(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: movies.length,
        itemBuilder: (context, index) {
          final movie = movies[index];
          return Container(
            width: 180,
            margin: EdgeInsets.only(
              left: index == 0 ? 0 : 10,
              right: index == movies.length - 1 ? 0 : 10,
            ),
            child: _buildPickedForYouCard(movie),
          );
        },
      ),
    );
  }

  Widget _buildPickedForYouCard(MovieModel movie) {
    return GestureDetector(
      onTap: () => _navigateToDetails(movie),
      child: Card(
        color: MyColors.secondaryColor,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Movie Poster
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  color: Colors.grey[800],
                ),
                child: Stack(
                  children: [
                    // Poster Image
                    movie.posterUrl.isNotEmpty
                        ? ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12)),
                            child: CachedNetworkImage(
                              imageUrl:
                                  'https://image.tmdb.org/t/p/w500${movie.posterUrl}',
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
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
                                return Container(
                                  color: Colors.grey[800],
                                  child: const Icon(
                                    Icons.movie,
                                    color: Colors.white54,
                                    size: 48,
                                  ),
                                );
                              },
                              fadeInDuration: const Duration(milliseconds: 300),
                              fadeOutDuration:
                                  const Duration(milliseconds: 300),
                            ),
                          )
                        : Container(
                            color: Colors.grey[800],
                            child: const Icon(
                              Icons.movie,
                              color: Colors.white54,
                              size: 48,
                            ),
                          ),
                  ],
                ),
              ),
            ),
            // Movie Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.title!,
                      style: MyStyles.title24White400.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    _buildPickedForYouIMDbRatingInline(movie),
                    const SizedBox(height: 2),
                    Text(
                      '', // Default to Movie since we're using MovieModel
                      style: MyStyles.title24White400.copyWith(
                        fontSize: 10,
                        color: Colors.grey[400],
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

  Widget _buildPickedForYouIMDbRatingInline(MovieModel movie) {
    // Only show IMDb rating if rating is available and not empty
    final rating = movie.rating;
    if (rating == '0.0' || rating.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF000000).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: const Color.fromARGB(114, 245, 197, 24), // IMDb yellow color
          width: 1.2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            MyImages.imdb,
            width: 20,
            height: 20,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 4),
          Text(
            rating,
            style: MyStyles.title24White400.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            '/10',
            style: MyStyles.title24White400.copyWith(
              fontSize: 9,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToDetails(MovieModel movie) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailsScreen(movie: movie),
      ),
    );
  }

  void _navigateToTVDetails(TvModel tvShow) {
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

  void _addToFavorites(MovieModel movie) async {
    try {
      // Convert MovieModel to SavedMovieModel
      final savedMovie = SavedMovieModel.fromMovieModel(movie);

      // Add to favorites
      final success = await UserListsService.addToFavorites(savedMovie);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(
                  Icons.favorite,
                  color: Colors.white,
                  size: 20,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Added to favorites!',
                    style: TextStyle(color: Colors.white),
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
            content: const Row(
              children: [
                Icon(
                  Icons.info,
                  color: Colors.white,
                  size: 20,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Already in favorites!',
                    style: TextStyle(color: Colors.white),
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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(
                Icons.error,
                color: Colors.white,
                size: 20,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Failed to add to favorites.',
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

  void _addToWatchLater(MovieModel movie) async {
    try {
      // Convert MovieModel to SavedMovieModel
      final savedMovie = SavedMovieModel.fromMovieModel(movie);

      // Add to watch later
      final success = await UserListsService.addToWatchLater(savedMovie);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(
                  Icons.watch_later,
                  color: Colors.white,
                  size: 20,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Added to watch later!',
                    style: TextStyle(color: Colors.white),
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
            content: const Row(
              children: [
                Icon(
                  Icons.info,
                  color: Colors.white,
                  size: 20,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Already in watch later!',
                    style: TextStyle(color: Colors.white),
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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(
                Icons.error,
                color: Colors.white,
                size: 20,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Failed to add to watch later.',
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
