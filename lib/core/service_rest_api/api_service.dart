// api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:movie_proj/core/service_rest_api/model/model_service.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000';
  static String? _accessToken;

  static Map<String, String> get headers => {
        'Content-Type': 'application/json',
        if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
      };

  // Authentication Methods
  static Future<AuthResponse> register(RegisterRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(json.decode(response.body));
        _accessToken = authResponse.accessToken;
        return authResponse;
      } else {
        throw Exception('فشل في التسجيل: ${response.body}');
      }
    } catch (e) {
      throw Exception('خطأ في التسجيل: $e');
    }
  }

  static Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(json.decode(response.body));
        _accessToken = authResponse.accessToken;
        return authResponse;
      } else {
        throw Exception('فشل في تسجيل الدخول: ${response.body}');
      }
    } catch (e) {
      throw Exception('خطأ في تسجيل الدخول: $e');
    }
  }

  static void logout() {
    _accessToken = null;
  }

  // Users Methods
  static Future<List<User>> getUsers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((user) => User.fromJson(user)).toList();
      } else {
        throw Exception('فشل في تحميل المستخدمين');
      }
    } catch (e) {
      throw Exception('خطأ في تحميل المستخدمين: $e');
    }
  }

  static Future<User> getUserById(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return User.fromJson(json.decode(response.body));
      } else if (response.statusCode == 404) {
        throw Exception('المستخدم غير موجود');
      } else {
        throw Exception('فشل في تحميل المستخدم');
      }
    } catch (e) {
      throw Exception('خطأ في تحميل المستخدم: $e');
    }
  }

  // Movies Methods
  static Future<List<Movie>> getMovies() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/movies/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((movie) => Movie.fromJson(movie)).toList();
      } else {
        throw Exception('فشل في تحميل الأفلام');
      }
    } catch (e) {
      throw Exception('خطأ في تحميل الأفلام: $e');
    }
  }

  static Future<Movie> getMovieById(int movieId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/movies/$movieId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return Movie.fromJson(json.decode(response.body));
      } else if (response.statusCode == 404) {
        throw Exception('الفيلم غير موجود');
      } else {
        throw Exception('فشل في تحميل الفيلم');
      }
    } catch (e) {
      throw Exception('خطأ في تحميل الفيلم: $e');
    }
  }

  // Ratings Methods
  static Future<List<Rating>> getRatings() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/ratings/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((rating) => Rating.fromJson(rating)).toList();
      } else {
        throw Exception('فشل في تحميل التقييمات');
      }
    } catch (e) {
      throw Exception('خطأ في تحميل التقييمات: $e');
    }
  }

  static Future<Rating> getRatingById(int ratingId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/ratings/$ratingId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return Rating.fromJson(json.decode(response.body));
      } else if (response.statusCode == 404) {
        throw Exception('التقييم غير موجود');
      } else {
        throw Exception('فشل في تحميل التقييم');
      }
    } catch (e) {
      throw Exception('خطأ في تحميل التقييم: $e');
    }
  }

  // Friend Suggestions
  static Future<List<User>> getFriendSuggestions() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/suggest/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((user) => User.fromJson(user)).toList();
      } else {
        throw Exception('فشل في تحميل اقتراحات الأصدقاء');
      }
    } catch (e) {
      throw Exception('خطأ في تحميل اقتراحات الأصدقاء: $e');
    }
  }

  // Friends Methods
  static Future<void> addFriend(int userId, int friendId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/friends/$userId/add/$friendId'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception('فشل في إضافة الصديق');
      }
    } catch (e) {
      throw Exception('خطأ في إضافة الصديق: $e');
    }
  }

  static Future<void> removeFriend(int userId, int friendId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/friends/$userId/remove/$friendId'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception('فشل في إزالة الصديق');
      }
    } catch (e) {
      throw Exception('خطأ في إزالة الصديق: $e');
    }
  }

  // Helper method to check if user is authenticated
  static bool get isAuthenticated => _accessToken != null;

  // Get current token
  static String? get accessToken => _accessToken;
}
