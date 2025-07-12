import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_proj/core/service/index.dart';
import 'package:movie_proj/feature/home/model/movie_model.dart';

// States
abstract class PickedForYouState {}

class PickedForYouInitial extends PickedForYouState {}

class PickedForYouLoading extends PickedForYouState {}

class PickedForYouLoaded extends PickedForYouState {
  final List<MovieModel> movies;

  PickedForYouLoaded(this.movies);
}

class PickedForYouError extends PickedForYouState {
  final String message;

  PickedForYouError(this.message);
}

// Cubit
class PickedForYouCubit extends Cubit<PickedForYouState> {
  final ApiService _apiService;

  PickedForYouCubit(this._apiService) : super(PickedForYouInitial());

  Future<void> loadPickedForYou({bool forceRefresh = false}) async {
    // إذا كانت البيانات محملة مسبقاً ولا نريد إعادة التحميل، لا نفعل شيء
    if (!forceRefresh && state is PickedForYouLoaded) {
      return;
    }

    try {
      emit(PickedForYouLoading());
      final movies = await _apiService.getMovieData(MovieType.upcoming);
      emit(PickedForYouLoaded(movies));
    } catch (e) {
      emit(PickedForYouError('Failed to load recommendations: $e'));
    }
  }

  Future<void> refreshPickedForYou() async {
    await loadPickedForYou(forceRefresh: true);
  }
}
