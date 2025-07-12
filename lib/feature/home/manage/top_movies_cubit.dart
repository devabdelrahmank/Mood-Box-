import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_proj/core/service/index.dart';
import 'package:flutter/foundation.dart';
import 'package:movie_proj/feature/home/model/movie_model.dart';

// States
abstract class TopMoviesState {}

class TopMoviesInitial extends TopMoviesState {}

class TopMoviesLoading extends TopMoviesState {}

class TopMoviesLoaded extends TopMoviesState {
  final List<MovieModel> movies;

  TopMoviesLoaded(this.movies);
}

class TopMoviesError extends TopMoviesState {
  final String message;

  TopMoviesError(this.message);
}

// Cubit
class TopMoviesCubit extends Cubit<TopMoviesState> {
  final ApiService _apiService;

  TopMoviesCubit(this._apiService) : super(TopMoviesInitial());

  Future<void> loadTopMovies({bool forceRefresh = false}) async {
    // إذا كانت البيانات محملة مسبقاً ولا نريد إعادة التحميل، لا نفعل شيء
    if (!forceRefresh && state is TopMoviesLoaded) {
      if (kDebugMode) {
        print('🎬 TopMoviesCubit: Data already loaded, skipping...');
      }
      return;
    }

    try {
      if (kDebugMode) {
        print('🎬 TopMoviesCubit: Starting to load top movies...');
      }
      emit(TopMoviesLoading());
      final movies = await _apiService.getMovieData(MovieType.topRated);
      if (kDebugMode) {
        print('🎬 TopMoviesCubit: Loaded ${movies.length} movies');
      }
      emit(TopMoviesLoaded(movies));
    } catch (e) {
      if (kDebugMode) {
        print('🎬 TopMoviesCubit: Error loading movies: $e');
      }
      emit(TopMoviesError('Failed to load top movies: $e'));
    }
  }

  Future<void> refreshTopMovies() async {
    await loadTopMovies(forceRefresh: true);
  }
}
