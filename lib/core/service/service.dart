import 'package:movie_proj/core/const.dart';
import 'package:movie_proj/core/service/enums.dart';

import 'dart:convert';
import 'package:http/http.dart';
import 'package:movie_proj/feature/home/model/cast_model.dart' show CastModel;
import 'package:movie_proj/feature/home/model/movie_model.dart';
import 'package:movie_proj/feature/home/model/tv-model.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  Future<List<MovieModel>> getMovieData(MovieType type,
      {int movieID = 0}) async {
    String url = "";
    if (type == MovieType.popular) {
      url = kmoviedbURL + kpopular;
    } else if (type == MovieType.topRated) {
      url = kmoviedbURL + ktop_rated;
    } else if (type == MovieType.upcoming) {
      url = kmoviedbURL + kupcoming;
    } else if (type == MovieType.nowPlaying) {
      url = kmoviedbURL + knowPlaying;
    } else if (type == MovieType.similar) {
      url = kmoviedbURL + movieID.toString() + ksimilar;
    }
    try {
      final fullUrl = "$url?api_key=$tmdbApiKey&language=en-US";
      if (kDebugMode) {
        print('🎬 Fetching movies from: $fullUrl');
      }

      Response response = await get(Uri.parse(fullUrl));

      if (kDebugMode) {
        print('🎬 Response status: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        Map<String, dynamic> json = jsonDecode(response.body);
        List<dynamic> body = json['results'];

        if (kDebugMode) {
          print('🎬 Found ${body.length} movies');
          if (body.isNotEmpty) {
            print(
                '🎬 First movie: ${body.first['title']} - Poster: ${body.first['poster_path']}');
          }
        }

        List<MovieModel> movie =
            body.map((dynamic item) => _mapTMDBToMovieModel(item)).toList();
        return movie;
      } else {
        if (kDebugMode) {
          print('🎬 Error response: ${response.body}');
        }
        throw ("No movie found");
      }
    } catch (e) {
      if (kDebugMode) {
        print('🎬 Exception: $e');
      }
      throw (e.toString());
    }
  }

  Future<List<CastModel>> getCastlist(int id, ProgramType type) async {
    String url = "";
    if (type == ProgramType.movie) {
      url = kmoviedbURL + id.toString() + kcredits;
    } else {
      url = ktvdbURL + id.toString() + kcredits;
    }
    try {
      Response response =
          await get(Uri.parse("$url?api_key=$tmdbApiKey&language=en-US"));
      if (response.statusCode == 200) {
        Map<String, dynamic> json = jsonDecode(response.body);
        List<dynamic> body = json['cast'];
        List<CastModel> cast =
            body.map((dynamic item) => CastModel.fromJson(item)).toList();
        return cast;
      } else {
        throw ("No cast found");
      }
    } catch (e) {
      throw (e.toString());
    }
  }

  Future<List<TvModel>> getTVData(TvType type, {int tvID = 0}) async {
    String url = "";
    if (type == TvType.popular) {
      url = ktvdbURL + kpopular;
    } else if (type == TvType.topRated) {
      url = ktvdbURL + ktop_rated;
    } else if (type == TvType.onTheAir) {
      url = ktvdbURL + kon_the_air;
    } else if (type == TvType.airingTody) {
      url = ktvdbURL + kairringToday;
    } else if (type == TvType.similar) {
      url = ktvdbURL + tvID.toString() + ksimilar;
    }

    try {
      Response response =
          await get(Uri.parse("$url?api_key=$tmdbApiKey&language=en-US"));
      if (response.statusCode == 200) {
        Map<String, dynamic> json = jsonDecode(response.body);
        List<dynamic> body = json['results'];
        List<TvModel> tv =
            body.map((dynamic item) => TvModel.fromJson(item)).toList();
        return tv;
      } else {
        throw ("No tv found");
      }
    } catch (e) {
      throw (e.toString());
    }
  }

  /// Search movies using TMDB search API
  Future<List<MovieModel>> searchMovies(
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
  MovieModel _mapTMDBToMovieModel(Map<String, dynamic> tmdbData) {
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
