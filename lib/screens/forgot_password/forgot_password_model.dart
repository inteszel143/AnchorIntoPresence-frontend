class ForgotPasswordResponseModel {
  final String message;
  final bool status;
  final Map<String, dynamic> data;

  ForgotPasswordResponseModel({
    required this.message,
    required this.status,
    required this.data,
  });

  factory ForgotPasswordResponseModel.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordResponseModel(
      message: json['message'] ?? '',
      status: json['status'] ?? false,
      data: json['data'] ?? {},
    );
  }
}
