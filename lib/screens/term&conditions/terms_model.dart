class TermsResponse {
  final String message;
  final bool status;
  final TermsData data;

  TermsResponse({
    required this.message,
    required this.status,
    required this.data,
  });

  factory TermsResponse.fromJson(Map<String, dynamic> json) {
    return TermsResponse(
      message: json['message'],
      status: json['status'],
      data: TermsData.fromJson(json['data']),
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

class TermsData {
  final String id;
  final String description;
  final DateTime updatedAt;
  final String contentType;

  TermsData({
    required this.id,
    required this.description,
    required this.updatedAt,
    required this.contentType,
  });

  factory TermsData.fromJson(Map<String, dynamic> json) {
    return TermsData(
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
