// models.dart
class User {
  final int? id;
  final String? username;
  final String? email;
  final String? fullName;

  User({this.id, this.username, this.email, this.fullName});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      fullName: json['full_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'full_name': fullName,
    };
  }
}

class Movie {
  final int? id;
  final String title;
  final String? description;
  final String? genre;
  final double? rating;
  final String? releaseDate;
  final String? posterUrl;

  Movie({
    this.id,
    required this.title,
    this.description,
    this.genre,
    this.rating,
    this.releaseDate,
    this.posterUrl,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      genre: json['genre'],
      rating: json['rating']?.toDouble(),
      releaseDate: json['release_date'],
      posterUrl: json['poster_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'genre': genre,
      'rating': rating,
      'release_date': releaseDate,
      'poster_url': posterUrl,
    };
  }
}

class Rating {
  final int? id;
  final int userId;
  final int movieId;
  final double rating;
  final String? comment;

  Rating({
    this.id,
    required this.userId,
    required this.movieId,
    required this.rating,
    this.comment,
  });

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      id: json['id'],
      userId: json['user_id'],
      movieId: json['movie_id'],
      rating: json['rating'].toDouble(),
      comment: json['comment'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'movie_id': movieId,
      'rating': rating,
      'comment': comment,
    };
  }
}

class LoginRequest {
  final String username;
  final String password;

  LoginRequest({required this.username, required this.password});

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
    };
  }
}

class RegisterRequest {
  final String username;
  final String email;
  final String password;
  final String? fullName;

  RegisterRequest({
    required this.username,
    required this.email,
    required this.password,
    this.fullName,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'password': password,
      'full_name': fullName,
    };
  }
}

class AuthResponse {
  final String accessToken;
  final String tokenType;
  final User user;

  AuthResponse({
    required this.accessToken,
    required this.tokenType,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['access_token'],
      tokenType: json['token_type'],
      user: User.fromJson(json['user']),
    );
  }
}
