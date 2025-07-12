import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_proj/core/service/index.dart';
import 'package:movie_proj/feature/home/model/movie_model.dart';

// States
abstract class NewReleaseState {}

class NewReleaseInitial extends NewReleaseState {}

class NewReleaseLoading extends NewReleaseState {}

class NewReleaseLoaded extends NewReleaseState {
  final List<MovieModel> movies;

  NewReleaseLoaded(this.movies);
}

class NewReleaseError extends NewReleaseState {
  final String message;

  NewReleaseError(this.message);
}

// Cubit
class NewReleaseCubit extends Cubit<NewReleaseState> {
  final ApiService _apiService;

  NewReleaseCubit(this._apiService) : super(NewReleaseInitial());

  Future<void> loadNewReleases({bool forceRefresh = false}) async {
    // إذا كانت البيانات محملة مسبقاً ولا نريد إعادة التحميل، لا نفعل شيء
    if (!forceRefresh && state is NewReleaseLoaded) {
      return;
    }

    try {
      emit(NewReleaseLoading());
      final movies = await _apiService.getMovieData(MovieType.nowPlaying);
      emit(NewReleaseLoaded(movies));
    } catch (e) {
      emit(NewReleaseError('Failed to load new releases: $e'));
    }
  }

  Future<void> refreshNewReleases() async {
    await loadNewReleases(forceRefresh: true);
  }
}
