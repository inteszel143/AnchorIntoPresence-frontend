class ResetPasswordResponseModel {
  final String message;
  final bool status;
  final Map<String, dynamic> data;

  ResetPasswordResponseModel({
    required this.message,
    required this.status,
    required this.data,
  });

  factory ResetPasswordResponseModel.fromJson(Map<String, dynamic> json) {
    return ResetPasswordResponseModel(
      message: json['message'] ?? '',
      status: json['status'] ?? false,
      data: json['data'] ?? {},
    );
  }
}
