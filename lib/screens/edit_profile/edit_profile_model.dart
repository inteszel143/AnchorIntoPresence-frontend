/// Model for edit profile data response from API
class EditProfileResponseModel {
  final String message;
  final bool status;
  final ProfileData data;

  EditProfileResponseModel({
    required this.message,
    required this.status,
    required this.data,
  });

  factory EditProfileResponseModel.fromJson(Map<String, dynamic> json) {
    return EditProfileResponseModel(
      message: json['message'] ?? '',
      status: json['status'] ?? false,
      data: ProfileData.fromJson(json['data'] ?? {}),
    );
  }
}

class ProfileData {
  final String id;
  final String name;
  final String email;
  final String provider;
  final bool isVerified;
  final String otp;
  final String otpExpiresAt;
  final bool isBlocked;
  final String createdAt;
  final String updatedAt;
  final String? image;
  final String? fcmToken;
  final bool resetPassword;

  ProfileData({
    required this.id,
    required this.name,
    required this.email,
    required this.provider,
    required this.isVerified,
    required this.otp,
    required this.otpExpiresAt,
    required this.isBlocked,
    required this.createdAt,
    required this.updatedAt,
    this.image,
    this.fcmToken,
    required this.resetPassword,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      provider: json['provider'] ?? '',
      isVerified: json['isVerified'] ?? false,
      otp: json['otp'] ?? '',
      otpExpiresAt: json['otpExpiresAt'] ?? '',
      isBlocked: json['isBlocked'] ?? false,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      image: json['image'],
      fcmToken: json['fcmToken'],
      resetPassword: json['resetPassword'] ?? false,
    );
  }
}
