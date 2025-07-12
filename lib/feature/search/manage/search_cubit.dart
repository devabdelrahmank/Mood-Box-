import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:movie_proj/feature/home/model/movie_model.dart';
import 'package:movie_proj/feature/search/service/search_service.dart';

// Search Filter Model
class SearchFilters {
  final String? year;
  final String? genre;
  final String? sortBy;
  final bool includeAdult;

  const SearchFilters({
    this.year,
    this.genre,
    this.sortBy,
    this.includeAdult = false,
  });

  SearchFilters copyWith({
    String? year,
    String? genre,
    String? sortBy,
    bool? includeAdult,
  }) {
    return SearchFilters(
      year: year ?? this.year,
      genre: genre ?? this.genre,
      sortBy: sortBy ?? this.sortBy,
      includeAdult: includeAdult ?? this.includeAdult,
    );
  }
}

// Search States
abstract class SearchState {}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchLoaded extends SearchState {
  final List<MovieModel> movies;
  final String query;
  final SearchFilters filters;
  final bool hasMore;
  final int currentPage;

  SearchLoaded({
    required this.movies,
    required this.query,
    required this.filters,
    this.hasMore = false,
    this.currentPage = 1,
  });

  SearchLoaded copyWith({
    List<MovieModel>? movies,
    String? query,
    SearchFilters? filters,
    bool? hasMore,
    int? currentPage,
  }) {
    return SearchLoaded(
      movies: movies ?? this.movies,
      query: query ?? this.query,
      filters: filters ?? this.filters,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class SearchError extends SearchState {
  final String message;

  SearchError(this.message);
}

class SearchEmpty extends SearchState {
  final String query;

  SearchEmpty(this.query);
}

// Search Cubit
class SearchCubit extends Cubit<SearchState> {
  SearchFilters _currentFilters = const SearchFilters();
  String _currentQuery = '';

  SearchCubit() : super(SearchInitial());

  // Get current filters
  SearchFilters get currentFilters => _currentFilters;
  String get currentQuery => _currentQuery;

  // Search movies
  Future<void> searchMovies(String query, {bool resetResults = true}) async {
    if (query.trim().isEmpty) {
      emit(SearchInitial());
      return;
    }

    _currentQuery = query.trim();

    try {
      if (kDebugMode) {
        print('🔍 SearchCubit: Searching for "$query"');
      }

      if (resetResults) {
        emit(SearchLoading());
      }

      final movies = await SearchService.searchMovies(
        query,
        page: resetResults ? 1 : _getCurrentPage() + 1,
        year: _currentFilters.year,
        genre: _currentFilters.genre,
        includeAdult: _currentFilters.includeAdult,
      );

      if (kDebugMode) {
        print('🔍 SearchCubit: Found ${movies.length} movies');
      }

      if (movies.isEmpty && resetResults) {
        emit(SearchEmpty(query));
        return;
      }

      final currentState = state;
      List<MovieModel> allMovies = [];
      int currentPage = 1;

      if (!resetResults && currentState is SearchLoaded) {
        allMovies = [...currentState.movies, ...movies];
        currentPage = currentState.currentPage + 1;
      } else {
        allMovies = movies;
        currentPage = 1;
      }

      // Apply sorting if specified
      if (_currentFilters.sortBy != null) {
        allMovies = _sortMovies(allMovies, _currentFilters.sortBy!);
      }

      emit(SearchLoaded(
        movies: allMovies,
        query: query,
        filters: _currentFilters,
        hasMore: movies.length >= 20, // TMDB returns 20 results per page
        currentPage: currentPage,
      ));
    } catch (e) {
      if (kDebugMode) {
        print('🔍 SearchCubit: Error searching movies: $e');
      }
      emit(SearchError('Failed to search movies: $e'));
    }
  }

  // Load more results (pagination)
  Future<void> loadMoreResults() async {
    final currentState = state;
    if (currentState is SearchLoaded && currentState.hasMore) {
      await searchMovies(_currentQuery, resetResults: false);
    }
  }

  // Update filters
  void updateFilters(SearchFilters filters) {
    _currentFilters = filters;
    if (_currentQuery.isNotEmpty) {
      searchMovies(_currentQuery);
    }
  }

  // Clear search
  void clearSearch() {
    _currentQuery = '';
    emit(SearchInitial());
  }

  // Helper methods
  int _getCurrentPage() {
    final currentState = state;
    if (currentState is SearchLoaded) {
      return currentState.currentPage;
    }
    return 1;
  }

  List<MovieModel> _sortMovies(List<MovieModel> movies, String sortBy) {
    switch (sortBy) {
      case 'popularity':
        movies.sort((a, b) => (b.popularity ?? 0).compareTo(a.popularity ?? 0));
        break;
      case 'rating':
        movies
            .sort((a, b) => (b.voteAverage ?? 0).compareTo(a.voteAverage ?? 0));
        break;
      case 'release_date':
        movies.sort(
            (a, b) => (b.releaseDate ?? '').compareTo(a.releaseDate ?? ''));
        break;
      case 'title':
        movies.sort((a, b) => (a.title ?? '').compareTo(b.title ?? ''));
        break;
      default:
        // Keep original order
        break;
    }
    return movies;
  }
}
