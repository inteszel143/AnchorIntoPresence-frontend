class PrivacyPolicyResponse {
  final String message;
  final bool status;
  final PrivacyPolicyData data;

  PrivacyPolicyResponse({
    required this.message,
    required this.status,
    required this.data,
  });

  factory PrivacyPolicyResponse.fromJson(Map<String, dynamic> json) {
    return PrivacyPolicyResponse(
      message: json['message'],
      status: json['status'],
      data: PrivacyPolicyData.fromJson(json['data']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'status': status,
      'data': data.toJson(),
    };
  }
}

class PrivacyPolicyData {
  final String id;
  final String description;
  final DateTime updatedAt;
  final String contentType;

  PrivacyPolicyData({
    required this.id,
    required this.description,
    required this.updatedAt,
    required this.contentType,
  });

  factory PrivacyPolicyData.fromJson(Map<String, dynamic> json) {
    return PrivacyPolicyData(
      id: json['_id'],
      description: json['description'],
      updatedAt: DateTime.parse(json['updatedAt']),
      contentType: json['contentType'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'description': description,
      'updatedAt': updatedAt.toIso8601String(),
      'contentType': contentType,
    };
  }
}
