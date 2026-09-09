class SigninResponseModel {
  final String message;
  final SigninData? data;
  final String token;
  final bool isFirst;


  SigninResponseModel({
    required this.message,
    required this.data,
    required this.token,
    required this.isFirst,
  });

  factory SigninResponseModel.fromJson(Map<String, dynamic> json) {
    return SigninResponseModel(
      message: json['message'] ?? '',
      data: json['data'] != null ? SigninData.fromJson(json['data']) : null,
      token: json['token'] ?? '',
      isFirst: json['isFirst'] ?? false,
    );
  }
}

class SigninData {
  final String? name;
  final String? email;
  final String? image;

  SigninData({
    this.name,
    required this.email,
    this.image,
  });

  factory SigninData.fromJson(Map<String, dynamic> json) {
    return SigninData(
      name: json['name'],
      email: json['email'] ?? '',
      image: json['image'],
    );
  }
}


class SocialSigninResponseModel {
  final String message;
  final SocialSigninData? data;
  final String token;

  SocialSigninResponseModel({
    required this.message,
    required this.data,
    required this.token,
  });

  factory SocialSigninResponseModel.fromJson(Map<String, dynamic> json) {
    return SocialSigninResponseModel(
      message: json['message'] ?? '',
      data: json['data'] != null ? SocialSigninData.fromJson(json['data']) : null,
      token: json['data']['token'] ?? '',  // token is inside data in the response
    );
  }
}


class SocialSigninData {
  final String? name;
  final String? email;
  final String? image;
  final String? fcmToken;
  final String token;

  SocialSigninData({
    this.name,
    this.email,
    this.image,
    this.fcmToken,
    required this.token,
  });

  factory SocialSigninData.fromJson(Map<String, dynamic> json) {
    return SocialSigninData(
      name: json['name'],
      email: json['email'] ?? '',
      image: json['image'],
      fcmToken: json['fcmToken'],
      token: json['token'] ?? '',  // token in the social login response
    );
  }
}