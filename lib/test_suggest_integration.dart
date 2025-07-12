import 'package:flutter/foundation.dart';
import 'package:movie_proj/core/service/index.dart';
import 'package:movie_proj/feature/suggest/manage/top_rated_cubit.dart';

/// Test function to verify Suggest Screen integration
Future<void> testSuggestIntegration() async {
  try {
    debugPrint('🎭 Testing Suggest Screen Integration...');

    // Test the service
    final service = ApiService();

    // Test movies
    final movies = await service.getMovieData(MovieType.topRated);
    debugPrint('✅ Top Rated Movies Service working!');
    debugPrint('🎬 Number of movies: ${movies.length}');

    // Test TV shows
    final tvShows = await service.getTVData(TvType.topRated);
    debugPrint('✅ Top Rated TV Shows Service working!');
    debugPrint('📺 Number of TV shows: ${tvShows.length}');

    // Test the cubit
    final cubit = TopRatedCubit(service);
    await cubit.loadTopRated();

    final state = cubit.state;
    if (state is TopRatedLoaded) {
      debugPrint('✅ TopRatedCubit working!');
      debugPrint('🎭 Cubit loaded ${state.items.length} items');

      // Display first few items details
      final movieCount = state.items.where((item) => item.isMovie).length;
      final tvCount = state.items.where((item) => !item.isMovie).length;

      debugPrint('🎬 Movies: $movieCount');
      debugPrint('📺 TV Shows: $tvCount');

      if (state.items.isNotEmpty) {
        final firstItem = state.items.first;
        debugPrint('🏆 First item (after shuffle): ${firstItem.title}');
        debugPrint('   Type: ${firstItem.isMovie ? 'Movie' : 'TV Show'}');
        debugPrint('   Rating: ${firstItem.rating.toStringAsFixed(1)}');
        debugPrint('   Release Date: ${firstItem.releaseDate}');
        debugPrint(
            '   Overview: ${firstItem.overview.length > 100 ? firstItem.overview.substring(0, 100) + '...' : firstItem.overview}');

        // Test shuffle functionality
        debugPrint('🎲 Testing shuffle functionality...');
        final originalFirstTitle = firstItem.title;
        cubit.shuffleCurrentItems();

        final newState = cubit.state;
        if (newState is TopRatedLoaded && newState.items.isNotEmpty) {
          final newFirstItem = newState.items.first;
          debugPrint('🏆 First item after reshuffle: ${newFirstItem.title}');
          if (originalFirstTitle != newFirstItem.title) {
            debugPrint('✅ Shuffle working - order changed!');
          } else {
            debugPrint(
                '⚠️ Shuffle may have resulted in same order (random chance)');
          }
        }
      }
    } else if (state is TopRatedError) {
      debugPrint('❌ TopRatedCubit error: ${state.message}');
    } else {
      debugPrint('⚠️ TopRatedCubit in unexpected state: ${state.runtimeType}');
    }

    debugPrint('🎉 Suggest Screen Integration Test Complete!');
  } catch (e) {
    debugPrint('❌ Test failed: $e');
  }
}
