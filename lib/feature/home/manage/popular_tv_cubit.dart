import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_proj/core/service/index.dart';
import 'package:movie_proj/feature/home/model/tv-model.dart';

// States
abstract class PopularTVState {}

class PopularTVInitial extends PopularTVState {}

class PopularTVLoading extends PopularTVState {}

class PopularTVLoaded extends PopularTVState {
  final List<TvModel> tvShows;

  PopularTVLoaded(this.tvShows);
}

class PopularTVError extends PopularTVState {
  final String message;

  PopularTVError(this.message);
}

// Cubit
class PopularTVCubit extends Cubit<PopularTVState> {
  final ApiService _apiService;

  PopularTVCubit(this._apiService) : super(PopularTVInitial());

  Future<void> loadPopularTV({bool forceRefresh = false}) async {
    // إذا كانت البيانات محملة مسبقاً ولا نريد إعادة التحميل، لا نفعل شيء
    if (!forceRefresh && state is PopularTVLoaded) {
      return;
    }

    try {
      emit(PopularTVLoading());
      final tvShows = await _apiService.getTVData(TvType.popular);
      emit(PopularTVLoaded(tvShows));
    } catch (e) {
      emit(PopularTVError('Failed to load popular TV shows: $e'));
    }
  }

  Future<void> refreshPopularTV() async {
    await loadPopularTV(forceRefresh: true);
  }
}
