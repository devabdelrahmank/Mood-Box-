import 'package:flutter/foundation.dart';
import 'package:movie_proj/core/service/review_service.dart';

/// Test function to verify Reviews System
Future<void> testReviewsSystem() async {
  try {
    debugPrint('💬 Testing Reviews System...');

    final reviewService = ReviewService();
    
    // Test generating 100 reviews
    final allReviews = reviewService.generateRandomReviews(count: 100);
    debugPrint('✅ Generated ${allReviews.length} reviews');
    
    // Test rating distribution
    final highRated = allReviews.where((r) => r.rating >= 8.0).length;
    final mediumRated = allReviews.where((r) => r.rating >= 6.0 && r.rating < 8.0).length;
    final lowRated = allReviews.where((r) => r.rating < 6.0).length;
    
    debugPrint('📊 Rating Distribution:');
    debugPrint('   High (8.0+): $highRated reviews');
    debugPrint('   Medium (6.0-7.9): $mediumRated reviews');
    debugPrint('   Low (<6.0): $lowRated reviews');
    
    // Test getting random reviews for details screen
    final randomReviews = reviewService.getRandomReviews(count: 2);
    debugPrint('✅ Got ${randomReviews.length} random reviews for details screen');
    
    // Display sample reviews
    for (int i = 0; i < randomReviews.length; i++) {
      final review = randomReviews[i];
      debugPrint('📝 Review ${i + 1}:');
      debugPrint('   User: ${review.username}');
      debugPrint('   Rating: ${review.rating.toStringAsFixed(1)}/10');
      debugPrint('   Date: ${review.date}');
      debugPrint('   Helpful: ${review.helpfulCount} | Not Helpful: ${review.notHelpfulCount}');
      debugPrint('   Content: ${review.content.length > 100 ? review.content.substring(0, 100) + '...' : review.content}');
      debugPrint('');
    }
    
    // Test multiple calls to ensure randomness
    debugPrint('🔄 Testing randomness...');
    final firstCall = reviewService.getRandomReviews(count: 2);
    final secondCall = reviewService.getRandomReviews(count: 2);
    
    bool isDifferent = false;
    for (int i = 0; i < 2; i++) {
      if (firstCall[i].id != secondCall[i].id) {
        isDifferent = true;
        break;
      }
    }
    
    if (isDifferent) {
      debugPrint('✅ Reviews are properly randomized');
    } else {
      debugPrint('⚠️ Reviews might not be properly randomized (could be random chance)');
    }
    
    debugPrint('🎉 Reviews System Test Complete!');
  } catch (e) {
    debugPrint('❌ Test failed: $e');
  }
}
