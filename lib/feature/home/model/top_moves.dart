// class TopMovie {
//   final String id;
//   final String url;
//   final String primaryTitle;
//   final String originalTitle;
//   final String type;
//   final String description;
//   final String primaryImage;
//   final List<MovieThumbnail> thumbnails;
//   final String trailer;
//   final String contentRating;
//   final int startYear;
//   final int? endYear;
//   final String releaseDate;
//   final List<String> interests;
//   final List<String> countriesOfOrigin;
//   final List<String> externalLinks;
//   final List<String> spokenLanguages;
//   final List<String> filmingLocations;
//   final List<ProductionCompany> productionCompanies;
//   final int budget;
//   final int grossWorldwide;
//   final List<String> genres;
//   final bool isAdult;
//   final int runtimeMinutes;
//   final double averageRating;
//   final int numVotes;
//   final int metascore;

//   TopMovie({
//     required this.id,
//     required this.url,
//     required this.primaryTitle,
//     required this.originalTitle,
//     required this.type,
//     required this.description,
//     required this.primaryImage,
//     required this.thumbnails,
//     required this.trailer,
//     required this.contentRating,
//     required this.startYear,
//     this.endYear,
//     required this.releaseDate,
//     required this.interests,
//     required this.countriesOfOrigin,
//     required this.externalLinks,
//     required this.spokenLanguages,
//     required this.filmingLocations,
//     required this.productionCompanies,
//     required this.budget,
//     required this.grossWorldwide,
//     required this.genres,
//     required this.isAdult,
//     required this.runtimeMinutes,
//     required this.averageRating,
//     required this.numVotes,
//     required this.metascore,
//   });

//   factory TopMovie.fromJson(Map<String, dynamic> json) {
//     return TopMovie(
//       id: json['id'] as String,
//       url: json['url'] as String,
//       primaryTitle: json['primaryTitle'] as String,
//       originalTitle: json['originalTitle'] as String,
//       type: json['type'] as String,
//       description: json['description'] as String,
//       primaryImage: json['primaryImage'] as String,
//       thumbnails: (json['thumbnails'] as List)
//           .map((e) => MovieThumbnail.fromJson(e as Map<String, dynamic>))
//           .toList(),
//       trailer: json['trailer'] as String,
//       contentRating: json['contentRating'] as String,
//       startYear: json['startYear'] as int,
//       endYear: json['endYear'] as int?,
//       releaseDate: json['releaseDate'] as String,
//       interests: (json['interests'] as List).map((e) => e as String).toList(),
//       countriesOfOrigin:
//           (json['countriesOfOrigin'] as List).map((e) => e as String).toList(),
//       externalLinks:
//           (json['externalLinks'] as List).map((e) => e as String).toList(),
//       spokenLanguages:
//           (json['spokenLanguages'] as List).map((e) => e as String).toList(),
//       filmingLocations:
//           (json['filmingLocations'] as List).map((e) => e as String).toList(),
//       productionCompanies: (json['productionCompanies'] as List)
//           .map((e) => ProductionCompany.fromJson(e as Map<String, dynamic>))
//           .toList(),
//       budget: json['budget'] as int,
//       grossWorldwide: json['grossWorldwide'] as int,
//       genres: (json['genres'] as List).map((e) => e as String).toList(),
//       isAdult: json['isAdult'] as bool,
//       runtimeMinutes: json['runtimeMinutes'] as int,
//       averageRating: (json['averageRating'] as num).toDouble(),
//       numVotes: json['numVotes'] as int,
//       metascore: json['metascore'] as int,
//     );
//   }
// }

// class MovieThumbnail {
//   final String url;
//   final int width;
//   final int height;

//   MovieThumbnail({
//     required this.url,
//     required this.width,
//     required this.height,
//   });

//   factory MovieThumbnail.fromJson(Map<String, dynamic> json) {
//     return MovieThumbnail(
//       url: json['url'] as String,
//       width: json['width'] as int,
//       height: json['height'] as int,
//     );
//   }
// }

// class ProductionCompany {
//   final String id;
//   final String name;

//   ProductionCompany({
//     required this.id,
//     required this.name,
//   });

//   factory ProductionCompany.fromJson(Map<String, dynamic> json) {
//     return ProductionCompany(
//       id: json['id'] as String,
//       name: json['name'] as String,
//     );
//   }
// }
