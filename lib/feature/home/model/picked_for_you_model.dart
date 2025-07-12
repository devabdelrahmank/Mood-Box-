// class PickedForYouResponse {
//   final String? description;
//   final List<PickedForYouMovie> recommendations;
//   final String title;

//   PickedForYouResponse({
//     this.description,
//     required this.recommendations,
//     required this.title,
//   });

//   factory PickedForYouResponse.fromJson(Map<String, dynamic> json) {
//     return PickedForYouResponse(
//       description: json['description'] as String?,
//       recommendations: (json['recommendations'] as List?)
//               ?.map((e) => PickedForYouMovie.fromJson(e as Map<String, dynamic>))
//               .toList() ??
//           [],
//       title: json['title'] as String? ?? 'Recommendations',
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'description': description,
//       'recommendations': recommendations.map((e) => e.toJson()).toList(),
//       'title': title,
//     };
//   }
// }

// class PickedForYouMovie {
//   final int? audienceScore;
//   final int? criticsScore;
//   final String? emsId;
//   final String imageUrl;
//   final String? mediaType;
//   final String? mediaUrl;
//   final String title;

//   PickedForYouMovie({
//     this.audienceScore,
//     this.criticsScore,
//     this.emsId,
//     required this.imageUrl,
//     this.mediaType,
//     this.mediaUrl,
//     required this.title,
//   });

//   factory PickedForYouMovie.fromJson(Map<String, dynamic> json) {
//     return PickedForYouMovie(
//       audienceScore: json['audience_score'] as int?,
//       criticsScore: json['critics_score'] as int?,
//       emsId: json['ems_id'] as String?,
//       imageUrl: json['image_url'] as String? ?? '',
//       mediaType: json['media_type'] as String?,
//       mediaUrl: json['media_url'] as String?,
//       title: json['title'] as String? ?? 'Unknown Title',
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'audience_score': audienceScore,
//       'critics_score': criticsScore,
//       'ems_id': emsId,
//       'image_url': imageUrl,
//       'media_type': mediaType,
//       'media_url': mediaUrl,
//       'title': title,
//     };
//   }

//   /// Helper method to get the better score (critics or audience)
//   int? get bestScore {
//     if (criticsScore != null && audienceScore != null) {
//       return criticsScore! > audienceScore! ? criticsScore : audienceScore;
//     }
//     return criticsScore ?? audienceScore;
//   }

//   /// Helper method to get score display text
//   String get scoreDisplay {
//     if (criticsScore != null && audienceScore != null) {
//       return 'Critics: $criticsScore% • Audience: $audienceScore%';
//     } else if (criticsScore != null) {
//       return 'Critics: $criticsScore%';
//     } else if (audienceScore != null) {
//       return 'Audience: $audienceScore%';
//     }
//     return 'No rating available';
//   }

//   /// Helper method to determine if it's a movie or TV show
//   bool get isMovie {
//     return mediaType?.toLowerCase() == 'movie';
//   }

//   /// Helper method to get media type display
//   String get mediaTypeDisplay {
//     if (mediaType != null && mediaType!.isNotEmpty) {
//       return mediaType!;
//     }
//     return 'Movie'; // Default assumption
//   }

//   /// Helper method to check if scores are available
//   bool get hasScores {
//     return criticsScore != null || audienceScore != null;
//   }

//   /// Helper method to get color based on score
//   String get scoreColor {
//     final score = bestScore;
//     if (score == null) return 'gray';
//     if (score >= 80) return 'green';
//     if (score >= 60) return 'yellow';
//     return 'red';
//   }
// }
