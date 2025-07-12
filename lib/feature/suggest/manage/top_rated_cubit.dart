import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_proj/core/service/index.dart';
import 'package:flutter/foundation.dart';
import 'package:movie_proj/feature/home/model/movie_model.dart';
import 'package:movie_proj/feature/home/model/tv-model.dart';
import 'dart:math';

// Combined model for movies and TV shows
class TopRatedItem {
  final String id;
  final String title;
  final String posterPath;
  final String backdropPath;
  final String overview;
  final double rating;
  final String releaseDate;
  final bool isMovie; // true for movie, false for TV show
  final MovieModel? movieData;
  final TvModel? tvData;

  TopRatedItem({
    required this.id,
    required this.title,
    required this.posterPath,
    required this.backdropPath,
    required this.overview,
    required this.rating,
    required this.releaseDate,
    required this.isMovie,
    this.movieData,
    this.tvData,
  });

  factory TopRatedItem.fromMovie(MovieModel movie) {
    return TopRatedItem(
      id: movie.id.toString(),
      title: movie.title ?? 'Unknown Title',
      posterPath: movie.posterPath ?? '',
      backdropPath: movie.backdropPath ?? '',
      overview: movie.overview ?? '',
      rating: movie.voteAverage ?? 0.0,
      releaseDate: movie.releaseDate ?? '',
      isMovie: true,
      movieData: movie,
      tvData: null,
    );
  }

  factory TopRatedItem.fromTV(TvModel tv) {
    return TopRatedItem(
      id: tv.id.toString(),
      title: tv.name ?? 'Unknown Title',
      posterPath: tv.posterPath ?? '',
      backdropPath: tv.backdropPath ?? '',
      overview: tv.overview ?? '',
      rating: tv.voteAverage ?? 0.0,
      releaseDate: tv.firstAirDate ?? '',
      isMovie: false,
      movieData: null,
      tvData: tv,
    );
  }
}

// States
abstract class TopRatedState {}

class TopRatedInitial extends TopRatedState {}

class TopRatedLoading extends TopRatedState {}

class TopRatedLoaded extends TopRatedState {
  final List<TopRatedItem> items;

  TopRatedLoaded(this.items);
}

class TopRatedError extends TopRatedState {
  final String message;

  TopRatedError(this.message);
}

// Cubit
class TopRatedCubit extends Cubit<TopRatedState> {
  final ApiService _apiService;

  TopRatedCubit(this._apiService) : super(TopRatedInitial());

  Future<void> loadTopRated() async {
    try {
      if (kDebugMode) {
        print('🎭 TopRatedCubit: Starting to load top rated content...');
      }
      emit(TopRatedLoading());

      // Load both movies and TV shows concurrently
      final results = await Future.wait([
        _apiService.getMovieData(MovieType.topRated),
        _apiService.getTVData(TvType.topRated),
      ]);

      final movies = results[0] as List<MovieModel>;
      final tvShows = results[1] as List<TvModel>;

      if (kDebugMode) {
        print('🎬 TopRatedCubit: Loaded ${movies.length} movies');
        print('📺 TopRatedCubit: Loaded ${tvShows.length} TV shows');
      }

      // Convert to TopRatedItem and combine
      final List<TopRatedItem> allItems = [];

      // Add movies
      allItems.addAll(movies.map((movie) => TopRatedItem.fromMovie(movie)));

      // Add TV shows
      allItems.addAll(tvShows.map((tv) => TopRatedItem.fromTV(tv)));

      // Shuffle the list randomly for each load
      allItems.shuffle(Random());

      if (kDebugMode) {
        print('🎭 TopRatedCubit: Combined ${allItems.length} items');
        print('🎲 TopRatedCubit: Items shuffled randomly');
        if (allItems.isNotEmpty) {
          print(
              '🏆 First item after shuffle: ${allItems.first.title} (${allItems.first.isMovie ? 'Movie' : 'TV'}) - Rating: ${allItems.first.rating.toStringAsFixed(1)}');
        }
      }

      emit(TopRatedLoaded(allItems));
    } catch (e) {
      if (kDebugMode) {
        print('🎭 TopRatedCubit: Error loading content: $e');
      }
      emit(TopRatedError('Failed to load top rated content: $e'));
    }
  }

  Future<void> refreshTopRated() async {
    await loadTopRated();
  }

  void shuffleCurrentItems() {
    final currentState = state;
    if (currentState is TopRatedLoaded) {
      final shuffledItems = List<TopRatedItem>.from(currentState.items);
      shuffledItems.shuffle(Random());

      if (kDebugMode) {
        print('🎲 TopRatedCubit: Items reshuffled');
        if (shuffledItems.isNotEmpty) {
          print(
              '🏆 New first item: ${shuffledItems.first.title} (${shuffledItems.first.isMovie ? 'Movie' : 'TV'}) - Rating: ${shuffledItems.first.rating.toStringAsFixed(1)}');
        }
      }

      emit(TopRatedLoaded(shuffledItems));
    }
  }
}
