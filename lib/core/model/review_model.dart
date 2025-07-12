class ReviewModel {
  final String id;
  final String username;
  final String content;
  final double rating;
  final String date;
  final int helpfulCount;
  final int notHelpfulCount;

  ReviewModel({
    required this.id,
    required this.username,
    required this.content,
    required this.rating,
    required this.date,
    required this.helpfulCount,
    required this.notHelpfulCount,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      content: json['content'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      date: json['date'] ?? '',
      helpfulCount: json['helpfulCount'] ?? 0,
      notHelpfulCount: json['notHelpfulCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'content': content,
      'rating': rating,
      'date': date,
      'helpfulCount': helpfulCount,
      'notHelpfulCount': notHelpfulCount,
    };
  }
}
