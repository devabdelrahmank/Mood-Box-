class CastModel {
  bool? adult;
  int? gender;
  int? id;
  String? knownForDepartment;
  String? name;
  String? originalName;
  double? popularity;
  String? profilePath;
  int? castId;
  String? character;
  String? creditId;
  int? order;

  CastModel(
      {this.adult,
      this.gender,
      this.id,
      this.knownForDepartment,
      this.name,
      this.originalName,
      this.popularity,
      this.profilePath,
      this.castId,
      this.character,
      this.creditId,
      this.order});

  CastModel.fromJson(Map<String, dynamic> json) {
    try {
      adult = json['adult'];
      gender = json['gender'];
      id = json['id'];
      knownForDepartment = json['known_for_department'];
      name = json['name'];
      originalName = json['original_name'];
      popularity = json['popularity'];
      profilePath = json['profile_path'];
      castId = json['cast_id'];
      character = json['character'];
      creditId = json['credit_id'];
      order = json['order'];
    } catch (e) {
      print("Error in CastModel.fromJson: $e");
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['adult'] = adult;
    data['gender'] = gender;
    data['id'] = id;
    data['known_for_department'] = knownForDepartment;
    data['name'] = name;
    data['original_name'] = originalName;
    data['popularity'] = popularity;
    data['profile_path'] = profilePath;
    data['cast_id'] = castId;
    data['character'] = character;
    data['credit_id'] = creditId;
    data['order'] = order;
    return data;
  }

  // Get full profile image URL
  String get fullProfilePath {
    if (profilePath != null && profilePath!.isNotEmpty) {
      return 'https://image.tmdb.org/t/p/w185$profilePath';
    }
    return 'https://via.placeholder.com/185x278/333333/FFFFFF?text=No+Image';
  }

  // Get display name (fallback if name is empty)
  String get displayName {
    return name?.isNotEmpty == true ? name! : 'Unknown Actor';
  }

  // Get display character (fallback if character is empty)
  String get displayCharacter {
    return character?.isNotEmpty == true ? character! : 'Unknown Role';
  }

  // Get character image URL (for now, we'll use the actor's image)
  // In a real app, you might have separate character images
  String get characterImagePath {
    return fullProfilePath;
  }
}
