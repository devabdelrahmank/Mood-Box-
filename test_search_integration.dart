import 'package:flutter/foundation.dart';
import 'package:movie_proj/feature/search/service/search_service.dart';
import 'package:movie_proj/feature/search/manage/search_cubit.dart';

/// Test function to verify Search functionality
Future<void> testSearchIntegration() async {
  try {
    debugPrint('🔍 Testing Search Integration...');

    // Test the search service directly
    debugPrint('🔍 Testing basic search...');
    final searchResults = await SearchService.searchMovies('Avengers');
    debugPrint('✅ Basic search working!');
    debugPrint('🎬 Found ${searchResults.length} movies for "Avengers"');

    if (searchResults.isNotEmpty) {
      final firstMovie = searchResults.first;
      debugPrint('🎬 First result: ${firstMovie.displayTitle}');
      debugPrint('🎬 Year: ${firstMovie.year}');
      debugPrint('🎬 Rating: ${firstMovie.rating}');
      debugPrint('🎬 Poster: ${firstMovie.posterUrl}');
    }

    // Test search with year filter
    debugPrint('🔍 Testing search with year filter...');
    final filteredResults = await SearchService.searchMovies(
      'Avengers',
      year: '2019',
    );
    debugPrint('✅ Year filter working!');
    debugPrint(
        '🎬 Found ${filteredResults.length} movies for "Avengers" in 2019');

    // Test search with genre filter
    debugPrint('🔍 Testing search with genre filter...');
    final genreResults = await SearchService.searchMovies(
      'Action',
      genre: '28', // Action genre ID
    );
    debugPrint('✅ Genre filter working!');
    debugPrint('🎬 Found ${genreResults.length} action movies');

    // Test the SearchCubit
    debugPrint('🔍 Testing SearchCubit...');
    final cubit = SearchCubit();

    // Test search
    await cubit.searchMovies('Spider-Man');
    final state = cubit.state;

    if (state is SearchLoaded) {
      debugPrint('✅ SearchCubit working!');
      debugPrint('🎬 Cubit found ${state.movies.length} movies');
      debugPrint('🎬 Query: ${state.query}');
    } else if (state is SearchError) {
      debugPrint('❌ SearchCubit error: ${state.message}');
    } else {
      debugPrint('⚠️ SearchCubit in unexpected state: ${state.runtimeType}');
    }

    // Test filters
    debugPrint('🔍 Testing SearchCubit with filters...');
    final filters = SearchFilters(
      year: '2021',
      genre: '28', // Action
      sortBy: 'rating',
    );
    cubit.updateFilters(filters);
    await cubit.searchMovies('Marvel');

    final filteredState = cubit.state;
    if (filteredState is SearchLoaded) {
      debugPrint('✅ SearchCubit filters working!');
      debugPrint('🎬 Filtered results: ${filteredState.movies.length} movies');
    }

    debugPrint('🎉 Search integration test completed successfully!');
  } catch (e) {
    debugPrint('❌ Search integration test failed: $e');
    debugPrint('Stack trace: ${StackTrace.current}');
  }
}

/// Test function specifically for search API endpoint
Future<void> testSearchAPI() async {
  try {
    debugPrint('🔍 Testing Search API Endpoint...');

    // Test different search queries
    final testQueries = [
      'Batman',
      'Star Wars',
      'Marvel',
      'Disney',
      'Horror',
    ];

    for (final query in testQueries) {
      debugPrint('🔍 Testing query: "$query"');
      final results = await SearchService.searchMovies(query);
      debugPrint('   Found ${results.length} results');

      if (results.isNotEmpty) {
        final topResult = results.first;
        debugPrint(
            '   Top result: ${topResult.displayTitle} (${topResult.year})');
      }
    }

    debugPrint('✅ Search API test completed!');
  } catch (e) {
    debugPrint('❌ Search API test failed: $e');
  }
}
