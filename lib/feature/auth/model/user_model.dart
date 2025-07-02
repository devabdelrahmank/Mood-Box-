class UserModel {
  String? name;
  String? email;
  String? image;
  String? uId;
  bool? isVerified;

  UserModel({
    this.name,
    this.email,
    this.image,
    this.uId,
    this.isVerified,
  });
  UserModel.fromJson(Map<String, dynamic> json) {
    name = json['name'] as String?;
    email = json['email'] as String?;
    uId = json['uId'] as String?;
    image = json['image'] as String?;
    isVerified = json['isVerified'] as bool?;
  }
  Map<String, dynamic>? toMap() {
    return {
      'name': name,
      'email': email,
      'uId': uId,
      'image': image,
      'isVerified': isVerified,
    };
  }
}
