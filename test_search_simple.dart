import 'package:flutter/foundation.dart';
import 'package:movie_proj/feature/search/service/search_service.dart';

/// Simple test to verify search functionality
void main() async {
  await testSearchSimple();
}

Future<void> testSearchSimple() async {
  try {
    debugPrint('🔍 Testing Search Functionality...');

    // Test if the method exists and works
    debugPrint('🔍 Calling searchMovies method...');

    final results = await SearchService.searchMovies('Batman');

    debugPrint('✅ Search successful!');
    debugPrint('🎬 Found ${results.length} results for "Batman"');

    if (results.isNotEmpty) {
      final firstMovie = results.first;
      debugPrint('🎬 First result: ${firstMovie.displayTitle}');
      debugPrint('🎬 Year: ${firstMovie.year}');
      debugPrint('🎬 Rating: ${firstMovie.rating}');
    }
  } catch (e) {
    debugPrint('❌ Search test failed: $e');
    debugPrint('Stack trace: ${StackTrace.current}');
  }
}
