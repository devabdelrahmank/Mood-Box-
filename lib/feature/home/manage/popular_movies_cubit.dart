import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_proj/core/service/index.dart';
import 'package:flutter/foundation.dart';
import 'package:movie_proj/feature/home/model/movie_model.dart';

// States
abstract class PopularMoviesState {}

class PopularMoviesInitial extends PopularMoviesState {}

class PopularMoviesLoading extends PopularMoviesState {}

class PopularMoviesLoaded extends PopularMoviesState {
  final List<MovieModel> movies;

  PopularMoviesLoaded(this.movies);
}

class PopularMoviesError extends PopularMoviesState {
  final String message;

  PopularMoviesError(this.message);
}

// Cubit
class PopularMoviesCubit extends Cubit<PopularMoviesState> {
  final ApiService _apiService;

  PopularMoviesCubit(this._apiService) : super(PopularMoviesInitial());

  Future<void> loadPopularMovies() async {
    try {
      if (kDebugMode) {
        print('🎬 PopularMoviesCubit: Starting to load popular movies...');
      }
      emit(PopularMoviesLoading());
      final movies = await _apiService.getMovieData(MovieType.popular);
      if (kDebugMode) {
        print('🎬 PopularMoviesCubit: Loaded ${movies.length} popular movies');
      }
      emit(PopularMoviesLoaded(movies));
    } catch (e) {
      if (kDebugMode) {
        print('🎬 PopularMoviesCubit: Error loading popular movies: $e');
      }
      emit(PopularMoviesError('Failed to load popular movies: $e'));
    }
  }

  Future<void> refreshPopularMovies() async {
    await loadPopularMovies();
  }
}
