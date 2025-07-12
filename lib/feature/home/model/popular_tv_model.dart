// class PopularTVShow {
//   final String id;
//   final String url;
//   final String primaryTitle;
//   final String originalTitle;
//   final String type;
//   final String description;
//   final String primaryImage;
//   final List<TVThumbnail> thumbnails;
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
//   final int numberOfSeasons;
//   final int numberOfEpisodes;
//   final String status; // ongoing, ended, etc.

//   PopularTVShow({
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
//     required this.numberOfSeasons,
//     required this.numberOfEpisodes,
//     required this.status,
//   });

//   factory PopularTVShow.fromJson(Map<String, dynamic> json) {
//     return PopularTVShow(
//       id: json['id'] as String? ?? '',
//       url: json['url'] as String? ?? '',
//       primaryTitle: json['primaryTitle'] as String? ?? '',
//       originalTitle: json['originalTitle'] as String? ?? '',
//       type: json['type'] as String? ?? 'tvSeries',
//       description: json['description'] as String? ?? '',
//       primaryImage: json['primaryImage'] as String? ?? '',
//       thumbnails: (json['thumbnails'] as List?)
//               ?.map((e) => TVThumbnail.fromJson(e as Map<String, dynamic>))
//               .toList() ??
//           [],
//       trailer: json['trailer'] as String? ?? '',
//       contentRating: json['contentRating'] as String? ?? '',
//       startYear: json['startYear'] as int? ?? 0,
//       endYear: json['endYear'] as int?,
//       releaseDate: json['releaseDate'] as String? ?? '',
//       interests: (json['interests'] as List?)?.map((e) => e.toString()).toList() ?? [],
//       countriesOfOrigin: (json['countriesOfOrigin'] as List?)?.map((e) => e.toString()).toList() ?? [],
//       externalLinks: (json['externalLinks'] as List?)?.map((e) => e.toString()).toList() ?? [],
//       spokenLanguages: (json['spokenLanguages'] as List?)?.map((e) => e.toString()).toList() ?? [],
//       filmingLocations: (json['filmingLocations'] as List?)?.map((e) => e.toString()).toList() ?? [],
//       productionCompanies: (json['productionCompanies'] as List?)
//               ?.map((e) => ProductionCompany.fromJson(e as Map<String, dynamic>))
//               .toList() ??
//           [],
//       budget: json['budget'] as int? ?? 0,
//       grossWorldwide: json['grossWorldwide'] as int? ?? 0,
//       genres: (json['genres'] as List?)?.map((e) => e.toString()).toList() ?? [],
//       isAdult: json['isAdult'] as bool? ?? false,
//       runtimeMinutes: json['runtimeMinutes'] as int? ?? 0,
//       averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
//       numVotes: json['numVotes'] as int? ?? 0,
//       metascore: json['metascore'] as int? ?? 0,
//       numberOfSeasons: json['numberOfSeasons'] as int? ?? 0,
//       numberOfEpisodes: json['numberOfEpisodes'] as int? ?? 0,
//       status: json['status'] as String? ?? 'unknown',
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'url': url,
//       'primaryTitle': primaryTitle,
//       'originalTitle': originalTitle,
//       'type': type,
//       'description': description,
//       'primaryImage': primaryImage,
//       'thumbnails': thumbnails.map((e) => e.toJson()).toList(),
//       'trailer': trailer,
//       'contentRating': contentRating,
//       'startYear': startYear,
//       'endYear': endYear,
//       'releaseDate': releaseDate,
//       'interests': interests,
//       'countriesOfOrigin': countriesOfOrigin,
//       'externalLinks': externalLinks,
//       'spokenLanguages': spokenLanguages,
//       'filmingLocations': filmingLocations,
//       'productionCompanies': productionCompanies.map((e) => e.toJson()).toList(),
//       'budget': budget,
//       'grossWorldwide': grossWorldwide,
//       'genres': genres,
//       'isAdult': isAdult,
//       'runtimeMinutes': runtimeMinutes,
//       'averageRating': averageRating,
//       'numVotes': numVotes,
//       'metascore': metascore,
//       'numberOfSeasons': numberOfSeasons,
//       'numberOfEpisodes': numberOfEpisodes,
//       'status': status,
//     };
//   }
// }

// class TVThumbnail {
//   final String url;
//   final int width;
//   final int height;

//   TVThumbnail({
//     required this.url,
//     required this.width,
//     required this.height,
//   });

//   factory TVThumbnail.fromJson(Map<String, dynamic> json) {
//     return TVThumbnail(
//       url: json['url'] as String? ?? '',
//       width: json['width'] as int? ?? 0,
//       height: json['height'] as int? ?? 0,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'url': url,
//       'width': width,
//       'height': height,
//     };
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
//       id: json['id'] as String? ?? '',
//       name: json['name'] as String? ?? '',
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'name': name,
//     };
//   }
// }
