import 'package:cloud_firestore/cloud_firestore.dart';

class SavedMovieModel {
  final String movieId;
  final String title;
  final String originalTitle;
  final String posterPath;
  final String? backdropPath;
  final String releaseDate;
  final double voteAverage;
  final int voteCount;
  final String overview;
  final List<int> genreIds;
  final String originalLanguage;
  final double popularity;
  final DateTime addedAt;

  SavedMovieModel({
    required this.movieId,
    required this.title,
    required this.originalTitle,
    required this.posterPath,
    this.backdropPath,
    required this.releaseDate,
    required this.voteAverage,
    required this.voteCount,
    required this.overview,
    required this.genreIds,
    required this.originalLanguage,
    required this.popularity,
    required this.addedAt,
  });

  // Convert from MovieModel to SavedMovieModel
  factory SavedMovieModel.fromMovieModel(dynamic movieModel) {
    return SavedMovieModel(
      movieId: movieModel.id?.toString() ?? movieModel.title.hashCode.toString(),
      title: movieModel.title ?? movieModel.displayTitle ?? 'Unknown Title',
      originalTitle: movieModel.originalTitle ?? movieModel.title ?? 'Unknown Title',
      posterPath: movieModel.posterPath ?? '',
      backdropPath: movieModel.backdropPath,
      releaseDate: movieModel.releaseDate ?? '2024-01-01',
      voteAverage: movieModel.voteAverage?.toDouble() ?? 0.0,
      voteCount: movieModel.voteCount ?? 0,
      overview: movieModel.overview ?? 'No overview available.',
      genreIds: movieModel.genreIds ?? [],
      originalLanguage: movieModel.originalLanguage ?? 'en',
      popularity: movieModel.popularity?.toDouble() ?? 0.0,
      addedAt: DateTime.now(),
    );
  }

  // Convert from Map (for similar movies data)
  factory SavedMovieModel.fromMap(Map<String, String> movieData) {
    return SavedMovieModel(
      movieId: movieData['title']?.hashCode.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: movieData['title'] ?? 'Unknown Title',
      originalTitle: movieData['title'] ?? 'Unknown Title',
      posterPath: _extractPosterPath(movieData['poster'] ?? ''),
      backdropPath: null,
      releaseDate: '${movieData['year'] ?? '2024'}-01-01',
      voteAverage: double.tryParse(movieData['rating'] ?? '0.0') ?? 0.0,
      voteCount: 1000,
      overview: 'Discover more about ${movieData['title'] ?? 'this movie'} in this exciting film.',
      genreIds: [],
      originalLanguage: 'en',
      popularity: 50.0,
      addedAt: DateTime.now(),
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'movieId': movieId,
      'title': title,
      'originalTitle': originalTitle,
      'posterPath': posterPath,
      'backdropPath': backdropPath,
      'releaseDate': releaseDate,
      'voteAverage': voteAverage,
      'voteCount': voteCount,
      'overview': overview,
      'genreIds': genreIds,
      'originalLanguage': originalLanguage,
      'popularity': popularity,
      'addedAt': Timestamp.fromDate(addedAt),
    };
  }

  // Convert from Firestore document
  factory SavedMovieModel.fromFirestore(Map<String, dynamic> data) {
    return SavedMovieModel(
      movieId: data['movieId'] ?? '',
      title: data['title'] ?? 'Unknown Title',
      originalTitle: data['originalTitle'] ?? 'Unknown Title',
      posterPath: data['posterPath'] ?? '',
      backdropPath: data['backdropPath'],
      releaseDate: data['releaseDate'] ?? '2024-01-01',
      voteAverage: (data['voteAverage'] ?? 0.0).toDouble(),
      voteCount: data['voteCount'] ?? 0,
      overview: data['overview'] ?? 'No overview available.',
      genreIds: List<int>.from(data['genreIds'] ?? []),
      originalLanguage: data['originalLanguage'] ?? 'en',
      popularity: (data['popularity'] ?? 0.0).toDouble(),
      addedAt: data['addedAt'] != null 
          ? (data['addedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  // Helper method to extract poster path from full URL
  static String _extractPosterPath(String fullUrl) {
    if (fullUrl.contains('image.tmdb.org')) {
      final uri = Uri.parse(fullUrl);
      final pathSegments = uri.pathSegments;
      if (pathSegments.length >= 3) {
        return '/${pathSegments.last}';
      }
    }
    return fullUrl;
  }

  // Get full poster URL
  String get posterUrl {
    if (posterPath.isEmpty) return '';
    if (posterPath.startsWith('http')) return posterPath;
    return 'https://image.tmdb.org/t/p/w500$posterPath';
  }

  // Get display title
  String get displayTitle => title.isNotEmpty ? title : originalTitle;

  // Get rating as string
  String get rating => voteAverage.toStringAsFixed(1);

  // Get year from release date
  String get year {
    try {
      return DateTime.parse(releaseDate).year.toString();
    } catch (e) {
      return releaseDate.split('-').first;
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SavedMovieModel && other.movieId == movieId;
  }

  @override
  int get hashCode => movieId.hashCode;

  @override
  String toString() {
    return 'SavedMovieModel(movieId: $movieId, title: $title, addedAt: $addedAt)';
  }
}
