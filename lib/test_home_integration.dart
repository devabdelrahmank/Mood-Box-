import 'package:flutter/foundation.dart';
import 'package:movie_proj/core/service/index.dart';
import 'package:movie_proj/feature/home/manage/popular_tv_cubit.dart';

/// Test function to verify Popular TV integration in home screen
Future<void> testHomeIntegration() async {
  try {
    debugPrint('🏠 Testing Home Screen Integration...');

    // Test the service
    final service = ApiService();
    final tvShows = await service.getTVData(TvType.popular);

    debugPrint('✅ ApiService working!');
    debugPrint('📺 Number of TV shows: ${tvShows.length}');

    // Test the cubit
    final cubit = PopularTVCubit(service);
    await cubit.loadPopularTV();

    final state = cubit.state;
    if (state is PopularTVLoaded) {
      debugPrint('✅ PopularTVCubit working!');
      debugPrint('📺 Cubit loaded ${state.tvShows.length} TV shows');

      // Display first show details
      if (state.tvShows.isNotEmpty) {
        final firstShow = state.tvShows.first;
        debugPrint('🎬 First show: ${firstShow.name ?? 'Unknown Title'}');
        debugPrint(
            '   Rating: ${firstShow.voteAverage?.toStringAsFixed(1) ?? '0.0'}');
        debugPrint('   First Air Date: ${firstShow.firstAirDate ?? 'Unknown'}');
        debugPrint('   Overview: ${firstShow.overview ?? 'No description'}');
        debugPrint(
            '   Popularity: ${firstShow.popularity?.toStringAsFixed(1) ?? '0.0'}');
      }
    } else if (state is PopularTVError) {
      debugPrint('❌ PopularTVCubit error: ${state.message}');
    } else {
      debugPrint('⚠️ PopularTVCubit in unexpected state: ${state.runtimeType}');
    }

    debugPrint('🎉 Home integration test completed successfully!');
  } catch (e) {
    debugPrint('❌ Home integration test failed: $e');
  }
}

void main() async {
  await testHomeIntegration();
}
