class OtpVerificationResponseModel {
  final String message;
  final bool status;
  final Map<String, dynamic> data;

  OtpVerificationResponseModel({
    required this.message,
    required this.status,
    required this.data,
  });

  factory OtpVerificationResponseModel.fromJson(Map<String, dynamic> json) {
    return OtpVerificationResponseModel(
      message: json['message'] ?? '',
      status: json['status'] ?? false,
      data: json['data'] ?? {},
    );
  }
}
