import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:movie_proj/feature/user_lists/model/saved_movie_model.dart';

class UserListsService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  static String? get currentUserId => _auth.currentUser?.uid;

  // Collections
  static CollectionReference get _usersCollection => _firestore.collection('users');

  // Initialize user lists when user is created
  static Future<void> initializeUserLists(String userId) async {
    try {
      await _usersCollection.doc(userId).update({
        'favorites': [],
        'watchLater': [],
        'listsCreatedAt': FieldValue.serverTimestamp(),
      });

      if (kDebugMode) {
        debugPrint('User lists initialized for: $userId');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error initializing user lists: $e');
      }
      rethrow;
    }
  }

  // Add movie to favorites
  static Future<bool> addToFavorites(SavedMovieModel movie) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        if (kDebugMode) {
          debugPrint('User not authenticated');
        }
        return false;
      }

      // Check if movie already exists in favorites
      final userDoc = await _usersCollection.doc(userId).get();
      final userData = userDoc.data() as Map<String, dynamic>?;
      final favorites = userData?['favorites'] as List<dynamic>? ?? [];

      // Check if movie already exists
      final existingMovie = favorites.firstWhere(
        (fav) => fav['movieId'] == movie.movieId,
        orElse: () => null,
      );

      if (existingMovie != null) {
        if (kDebugMode) {
          debugPrint('Movie already in favorites: ${movie.title}');
        }
        return false; // Movie already in favorites
      }

      // Add movie to favorites
      await _usersCollection.doc(userId).update({
        'favorites': FieldValue.arrayUnion([movie.toFirestore()]),
        'favoritesUpdatedAt': FieldValue.serverTimestamp(),
      });

      if (kDebugMode) {
        debugPrint('Movie added to favorites: ${movie.title}');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error adding movie to favorites: $e');
      }
      return false;
    }
  }

  // Remove movie from favorites
  static Future<bool> removeFromFavorites(String movieId) async {
    try {
      final userId = currentUserId;
      if (userId == null) return false;

      // Get current favorites
      final userDoc = await _usersCollection.doc(userId).get();
      final userData = userDoc.data() as Map<String, dynamic>?;
      final favorites = userData?['favorites'] as List<dynamic>? ?? [];

      // Find and remove the movie
      final updatedFavorites = favorites.where((fav) => fav['movieId'] != movieId).toList();

      // Update the document
      await _usersCollection.doc(userId).update({
        'favorites': updatedFavorites,
        'favoritesUpdatedAt': FieldValue.serverTimestamp(),
      });

      if (kDebugMode) {
        debugPrint('Movie removed from favorites: $movieId');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error removing movie from favorites: $e');
      }
      return false;
    }
  }

  // Add movie to watch later
  static Future<bool> addToWatchLater(SavedMovieModel movie) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        if (kDebugMode) {
          debugPrint('User not authenticated');
        }
        return false;
      }

      // Check if movie already exists in watch later
      final userDoc = await _usersCollection.doc(userId).get();
      final userData = userDoc.data() as Map<String, dynamic>?;
      final watchLater = userData?['watchLater'] as List<dynamic>? ?? [];

      // Check if movie already exists
      final existingMovie = watchLater.firstWhere(
        (watch) => watch['movieId'] == movie.movieId,
        orElse: () => null,
      );

      if (existingMovie != null) {
        if (kDebugMode) {
          debugPrint('Movie already in watch later: ${movie.title}');
        }
        return false; // Movie already in watch later
      }

      // Add movie to watch later
      await _usersCollection.doc(userId).update({
        'watchLater': FieldValue.arrayUnion([movie.toFirestore()]),
        'watchLaterUpdatedAt': FieldValue.serverTimestamp(),
      });

      if (kDebugMode) {
        debugPrint('Movie added to watch later: ${movie.title}');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error adding movie to watch later: $e');
      }
      return false;
    }
  }

  // Remove movie from watch later
  static Future<bool> removeFromWatchLater(String movieId) async {
    try {
      final userId = currentUserId;
      if (userId == null) return false;

      // Get current watch later list
      final userDoc = await _usersCollection.doc(userId).get();
      final userData = userDoc.data() as Map<String, dynamic>?;
      final watchLater = userData?['watchLater'] as List<dynamic>? ?? [];

      // Find and remove the movie
      final updatedWatchLater = watchLater.where((watch) => watch['movieId'] != movieId).toList();

      // Update the document
      await _usersCollection.doc(userId).update({
        'watchLater': updatedWatchLater,
        'watchLaterUpdatedAt': FieldValue.serverTimestamp(),
      });

      if (kDebugMode) {
        debugPrint('Movie removed from watch later: $movieId');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error removing movie from watch later: $e');
      }
      return false;
    }
  }

  // Get user's favorite movies
  static Future<List<SavedMovieModel>> getFavorites() async {
    try {
      final userId = currentUserId;
      if (userId == null) return [];

      final userDoc = await _usersCollection.doc(userId).get();
      final userData = userDoc.data() as Map<String, dynamic>?;
      final favorites = userData?['favorites'] as List<dynamic>? ?? [];

      return favorites
          .map((fav) => SavedMovieModel.fromFirestore(fav as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.addedAt.compareTo(a.addedAt)); // Sort by newest first
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting favorites: $e');
      }
      return [];
    }
  }

  // Get user's watch later movies
  static Future<List<SavedMovieModel>> getWatchLater() async {
    try {
      final userId = currentUserId;
      if (userId == null) return [];

      final userDoc = await _usersCollection.doc(userId).get();
      final userData = userDoc.data() as Map<String, dynamic>?;
      final watchLater = userData?['watchLater'] as List<dynamic>? ?? [];

      return watchLater
          .map((watch) => SavedMovieModel.fromFirestore(watch as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.addedAt.compareTo(a.addedAt)); // Sort by newest first
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting watch later: $e');
      }
      return [];
    }
  }

  // Check if movie is in favorites
  static Future<bool> isInFavorites(String movieId) async {
    try {
      final userId = currentUserId;
      if (userId == null) return false;

      final userDoc = await _usersCollection.doc(userId).get();
      final userData = userDoc.data() as Map<String, dynamic>?;
      final favorites = userData?['favorites'] as List<dynamic>? ?? [];

      return favorites.any((fav) => fav['movieId'] == movieId);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error checking if movie is in favorites: $e');
      }
      return false;
    }
  }

  // Check if movie is in watch later
  static Future<bool> isInWatchLater(String movieId) async {
    try {
      final userId = currentUserId;
      if (userId == null) return false;

      final userDoc = await _usersCollection.doc(userId).get();
      final userData = userDoc.data() as Map<String, dynamic>?;
      final watchLater = userData?['watchLater'] as List<dynamic>? ?? [];

      return watchLater.any((watch) => watch['movieId'] == movieId);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error checking if movie is in watch later: $e');
      }
      return false;
    }
  }

  // Get user lists statistics
  static Future<Map<String, int>> getUserListsStats() async {
    try {
      final userId = currentUserId;
      if (userId == null) return {'favorites': 0, 'watchLater': 0};

      final userDoc = await _usersCollection.doc(userId).get();
      final userData = userDoc.data() as Map<String, dynamic>?;
      
      final favorites = userData?['favorites'] as List<dynamic>? ?? [];
      final watchLater = userData?['watchLater'] as List<dynamic>? ?? [];

      return {
        'favorites': favorites.length,
        'watchLater': watchLater.length,
      };
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting user lists stats: $e');
      }
      return {'favorites': 0, 'watchLater': 0};
    }
  }

  // Stream user's favorites (for real-time updates)
  static Stream<List<SavedMovieModel>> favoritesStream() {
    final userId = currentUserId;
    if (userId == null) return Stream.value([]);

    return _usersCollection.doc(userId).snapshots().map((doc) {
      final userData = doc.data() as Map<String, dynamic>?;
      final favorites = userData?['favorites'] as List<dynamic>? ?? [];
      
      return favorites
          .map((fav) => SavedMovieModel.fromFirestore(fav as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.addedAt.compareTo(a.addedAt));
    });
  }

  // Stream user's watch later (for real-time updates)
  static Stream<List<SavedMovieModel>> watchLaterStream() {
    final userId = currentUserId;
    if (userId == null) return Stream.value([]);

    return _usersCollection.doc(userId).snapshots().map((doc) {
      final userData = doc.data() as Map<String, dynamic>?;
      final watchLater = userData?['watchLater'] as List<dynamic>? ?? [];
      
      return watchLater
          .map((watch) => SavedMovieModel.fromFirestore(watch as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.addedAt.compareTo(a.addedAt));
    });
  }
}
