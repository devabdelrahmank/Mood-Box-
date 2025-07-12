import 'package:movie_proj/core/const.dart';
import 'package:movie_proj/core/service/enums.dart';

import 'dart:convert';
import 'package:http/http.dart';
import 'package:movie_proj/feature/home/model/cast_model.dart' show CastModel;
import 'package:movie_proj/feature/home/model/movie_model.dart';
import 'package:movie_proj/feature/home/model/tv-model.dart';

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
      Response response =
          await get(Uri.parse("$url?api_key=$tmdbApiKey&language=en-US"));
      if (response.statusCode == 200) {
        Map<String, dynamic> json = jsonDecode(response.body);
        List<dynamic> body = json['results'];
        List<MovieModel> movie =
            body.map((dynamic item) => MovieModel.fromJson(item)).toList();
        return movie;
      } else {
        throw ("No movie found");
      }
    } catch (e) {
      throw (e.toString());
    }
  }

  Future<List<CastModel>> getCastlist(int id, ProgramType type) async {
    String url = "";
    if (type == ProgramType.movie) {
      url = kmoviedbURL + id.toString() + kcredits;
    } else if (type == ProgramType.tv) {
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
        throw ("No TV show found");
      }
    } catch (e) {
      throw (e.toString());
    }
  }
}
