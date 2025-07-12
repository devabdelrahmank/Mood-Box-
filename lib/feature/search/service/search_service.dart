import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:movie_proj/core/const.dart';
import 'package:movie_proj/feature/home/model/movie_model.dart';

class SearchService {
  /// Search movies using TMDB search API
  static Future<List<MovieModel>> searchMovies(
    String query, {
    int page = 1,
    String? year,
    String? genre,
    bool includeAdult = false,
  }) async {
    if (query.trim().isEmpty) {
      return [];
    }

    try {
      // Build search URL
      String url = "https://api.themoviedb.org/3/search/movie";
      Map<String, String> queryParams = {
        'api_key': tmdbApiKey,
        'language': 'en-US',
        'query': query.trim(),
        'page': page.toString(),
        'include_adult': includeAdult.toString(),
      };

      // Add optional filters
      if (year != null && year.isNotEmpty) {
        queryParams['year'] = year;
      }

      // Build final URL with query parameters
      final uri = Uri.parse(url).replace(queryParameters: queryParams);

      if (kDebugMode) {
        print('🔍 Searching movies: $uri');
      }

      Response response = await get(uri);

      if (kDebugMode) {
        print('🔍 Search response status: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        Map<String, dynamic> json = jsonDecode(response.body);
        List<dynamic> body = json['results'] ?? [];

        if (kDebugMode) {
          print('🔍 Found ${body.length} movies for query: "$query"');
        }

        List<MovieModel> movies =
            body.map((dynamic item) => _mapTMDBToMovieModel(item)).toList();

        // Apply genre filter if specified (client-side filtering)
        if (genre != null && genre.isNotEmpty) {
          final genreId = int.tryParse(genre);
          if (genreId != null) {
            movies = movies.where((movie) {
              return movie.genreIds?.contains(genreId) ?? false;
            }).toList();
          }
        }

        return movies;
      } else {
        if (kDebugMode) {
          print('🔍 Search error response: ${response.body}');
        }
        throw ("Search failed: ${response.statusCode}");
      }
    } catch (e) {
      if (kDebugMode) {
        print('🔍 Search error: $e');
      }
      throw (e.toString());
    }
  }

  /// Maps TMDB API response to MovieModel format
  static MovieModel _mapTMDBToMovieModel(Map<String, dynamic> tmdbData) {
    final posterPath = tmdbData['poster_path'] ?? '';
    final title =
        tmdbData['title'] ?? tmdbData['original_title'] ?? 'Unknown Title';

    if (kDebugMode) {
      print('🎬 Mapping movie: $title');
      print('🎬 Poster path: $posterPath');
    }

    return MovieModel(
      adult: tmdbData['adult'],
      backdropPath: tmdbData['backdrop_path'],
      genreIds: (tmdbData['genre_ids'] as List?)?.cast<int>(),
      id: tmdbData['id'],
      originalLanguage: tmdbData['original_language'],
      originalTitle: tmdbData['original_title'],
      overview: tmdbData['overview'],
      popularity: tmdbData['popularity']?.toDouble(),
      posterPath: posterPath,
      releaseDate: tmdbData['release_date'],
      title: title,
      video: tmdbData['video'],
      voteAverage: tmdbData['vote_average']?.toDouble(),
      voteCount: tmdbData['vote_count'],
    );
  }
}
