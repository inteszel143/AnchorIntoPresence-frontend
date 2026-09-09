/// Model for contact support API response
class ContactSupportResponseModel {
  final String message;
  final bool status;
  final Map<String, dynamic> data;

  ContactSupportResponseModel({
    required this.message,
    required this.status,
    required this.data,
  });

  /// Creates instance from JSON response
  factory ContactSupportResponseModel.fromJson(Map<String, dynamic> json) {
    return ContactSupportResponseModel(
      message: json['message'] ?? '',
      status: json['status'] ?? false,
      data: json['data'] ?? {},
    );
  }
}
