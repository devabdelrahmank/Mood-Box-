class MovieModel {
  final String title;
  final String posterUrl;
  final String year;
  final String duration;
  final String rating;
  final List<String> genres;
  final String plot;
  final String director;
  final String stars;
  final String reviews;
  final List<String> photos;
  final List<CastMember> cast;

  MovieModel({
    required this.title,
    required this.posterUrl,
    required this.year,
    required this.duration,
    required this.rating,
    required this.genres,
    required this.plot,
    required this.director,
    required this.stars,
    required this.reviews,
    required this.photos,
    required this.cast,
  });

  factory MovieModel.fromJson(Map<String, dynamic> json) {
    return MovieModel(
      title: json['title'] ?? '',
      posterUrl: json['posterUrl'] ?? '',
      year: json['year']?.toString() ?? '',
      duration: json['duration'] ?? '',
      rating: json['rating']?.toString() ?? '0.0',
      genres:
          (json['genres'] as List?)?.map((e) => e.toString()).toList() ?? [],
      plot: json['plot'] ?? '',
      director: json['director'] ?? '',
      stars: json['stars'] ?? '',
      reviews: json['reviews'] ?? '',
      photos:
          (json['photos'] as List?)?.map((e) => e.toString()).toList() ?? [],
      cast: (json['cast'] as List?)
              ?.map((e) => CastMember.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class CastMember {
  final String name;
  final String role;
  final String imageUrl;

  CastMember({
    required this.name,
    required this.role,
    required this.imageUrl,
  });

  factory CastMember.fromJson(Map<String, dynamic> json) {
    return CastMember(
      name: json['name'] ?? '',
      role: json['role'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
    );
  }
}
