import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_proj/core/service/index.dart';
import 'package:flutter/foundation.dart';
import 'package:movie_proj/feature/home/model/tv-model.dart';

// States
abstract class TopTVState {}

class TopTVInitial extends TopTVState {}

class TopTVLoading extends TopTVState {}

class TopTVLoaded extends TopTVState {
  final List<TvModel> tvShows;

  TopTVLoaded(this.tvShows);
}

class TopTVError extends TopTVState {
  final String message;

  TopTVError(this.message);
}

// Cubit
class TopTVCubit extends Cubit<TopTVState> {
  final ApiService _apiService;

  TopTVCubit(this._apiService) : super(TopTVInitial());

  Future<void> loadTopTV() async {
    try {
      if (kDebugMode) {
        print('📺 TopTVCubit: Starting to load top TV shows...');
      }
      emit(TopTVLoading());
      final tvShows = await _apiService.getTVData(TvType.topRated);
      if (kDebugMode) {
        print('📺 TopTVCubit: Loaded ${tvShows.length} TV shows');
      }
      emit(TopTVLoaded(tvShows));
    } catch (e) {
      if (kDebugMode) {
        print('📺 TopTVCubit: Error loading TV shows: $e');
      }
      emit(TopTVError('Failed to load top TV shows: $e'));
    }
  }

  Future<void> refreshTopTV() async {
    await loadTopTV();
  }
}
