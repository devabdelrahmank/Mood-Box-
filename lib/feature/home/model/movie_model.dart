class MovieModel {
  bool? adult;
  String? backdropPath;
  List<int>? genreIds;
  int? id;
  String? originalLanguage;
  String? originalTitle;
  String? overview;
  double? popularity;
  String? posterPath;
  String? releaseDate;
  String? title;
  bool? video;
  double? voteAverage;
  int? voteCount;

  MovieModel(
      {this.adult,
      this.backdropPath,
      this.genreIds,
      this.id,
      this.originalLanguage,
      this.originalTitle,
      this.overview,
      this.popularity,
      this.posterPath,
      this.releaseDate,
      this.title,
      this.video,
      this.voteAverage,
      this.voteCount});

  MovieModel.fromJson(Map<String, dynamic> json) {
    try {
      adult = json['adult'];
      backdropPath = json['backdrop_path'];
      genreIds = json['genre_ids'].cast<int>();
      id = json['id'];
      originalLanguage = json['original_language'];
      originalTitle = json['original_title'];
      overview = json['overview'];
      popularity = json['popularity'];
      posterPath = json['poster_path'];
      releaseDate = json['release_date'];
      title = json['title'];
      video = json['video'];
      voteAverage = json['vote_average'];
      voteCount = json['vote_count'];
    }
    // ignore: empty_catches
    catch (e) {}
  }

  get trailerKey => null;

  // Getter to build full poster URL from posterPath
  String get posterUrl {
    if (posterPath != null && posterPath!.isNotEmpty) {
      return 'https://image.tmdb.org/t/p/w500$posterPath';
    }
    return '';
  }

  // Getter to extract year from releaseDate
  String get year {
    if (releaseDate != null && releaseDate!.isNotEmpty) {
      return releaseDate!.split('-').first;
    }
    return '';
  }

  // Getter to format rating
  String get rating {
    if (voteAverage != null) {
      return voteAverage!.toStringAsFixed(1);
    }
    return '0.0';
  }

  // Getter to ensure title is never null
  String get displayTitle {
    return title ?? originalTitle ?? 'Unknown Title';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['adult'] = adult;
    data['backdrop_path'] = backdropPath;
    data['genre_ids'] = genreIds;
    data['id'] = id;
    data['original_language'] = originalLanguage;
    data['original_title'] = originalTitle;
    data['overview'] = overview;
    data['popularity'] = popularity;
    data['poster_path'] = posterPath;
    data['release_date'] = releaseDate;
    data['title'] = title;
    data['video'] = video;
    data['vote_average'] = voteAverage;
    data['vote_count'] = voteCount;
    return data;
  }
}
