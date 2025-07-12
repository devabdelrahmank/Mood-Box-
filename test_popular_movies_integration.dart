import 'package:flutter/foundation.dart';
import 'package:movie_proj/core/service/index.dart';
import 'package:movie_proj/feature/home/manage/popular_movies_cubit.dart';

/// Test function to verify Popular Movies integration in similar movies section
Future<void> testPopularMoviesIntegration() async {
  try {
    debugPrint('🎬 Testing Popular Movies Integration...');

    // Test the service
    final service = ApiService();
    final movies = await service.getMovieData(MovieType.popular);

    debugPrint('✅ ApiService working!');
    debugPrint('🎬 Number of popular movies: ${movies.length}');

    if (movies.isNotEmpty) {
      final firstMovie = movies.first;
      debugPrint('🎬 First movie: ${firstMovie.displayTitle}');
      debugPrint('🎬 Poster URL: ${firstMovie.posterUrl}');
      debugPrint('🎬 Rating: ${firstMovie.rating}');
      debugPrint('🎬 Year: ${firstMovie.year}');
    }

    // Test the cubit
    final cubit = PopularMoviesCubit(service);
    await cubit.loadPopularMovies();

    final state = cubit.state;
    if (state is PopularMoviesLoaded) {
      debugPrint('✅ PopularMoviesCubit working!');
      debugPrint('🎬 Loaded ${state.movies.length} movies in cubit');
    } else if (state is PopularMoviesError) {
      debugPrint('❌ PopularMoviesCubit error: ${state.message}');
    } else {
      debugPrint('⚠️ PopularMoviesCubit in unexpected state: ${state.runtimeType}');
    }

    debugPrint('🎉 Popular Movies Integration Test Complete!');
  } catch (e) {
    debugPrint('❌ Test failed: $e');
  }
}

void main() async {
  await testPopularMoviesIntegration();
}
