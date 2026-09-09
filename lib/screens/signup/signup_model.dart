class SignupResponseModel {
  final String message;
  final bool status;
  final Map<String, dynamic> data;

  SignupResponseModel({
    required this.message,
    required this.status,
    required this.data,
  });

  factory SignupResponseModel.fromJson(Map<String, dynamic> json) {
    return SignupResponseModel(
      message: json['message'] ?? '',
      status: json['status'] ?? false,
      data: json['data'] ?? {},
    );
  }
}
