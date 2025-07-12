class UserModel {
  final String? uId;
  final String? email;
  final String? name;
  final String? image;

  UserModel({
    this.uId,
    this.email,
    this.name,
    this.image,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uId: json['uId'],
      email: json['email'],
      name: json['name'],
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uId': uId,
      'email': email,
      'name': name,
      'image': image,
    };
  }

  UserModel copyWith({
    String? uId,
    String? email,
    String? name,
    String? image,
  }) {
    return UserModel(
      uId: uId ?? this.uId,
      email: email ?? this.email,
      name: name ?? this.name,
      image: image ?? this.image,
    );
  }
}
