class UserActivitySummary {
  final String message;
  final bool status;
  final Data data; // nested data object

  UserActivitySummary({
    required this.message,
    required this.status,
    required this.data,
  });

  factory UserActivitySummary.fromJson(Map<String, dynamic> json) {
    return UserActivitySummary(
      message: json['message'],
      status: json['status'],
      data: Data.fromJson(json['data']),
    );
  }
}

class Data {
  final LoggedActivities loggedActivities;
  final Map<String, dynamic> categoryDistribution;
  final LoginDates loginDates;

  Data({
    required this.loggedActivities,
    required this.categoryDistribution,
    required this.loginDates,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      loggedActivities: LoggedActivities.fromJson(json['loggedActivities']),
      categoryDistribution:
          Map<String, dynamic>.from(json['categoryDistribution']),
      loginDates: LoginDates.fromJson(json['loginDates']),
    );
  }
}

class LoggedActivities {
  final String totalTime;
  final List<dynamic> thumbnails;

  LoggedActivities({
    required this.totalTime,
    required this.thumbnails,
  });

  factory LoggedActivities.fromJson(Map<String, dynamic> json) {
    return LoggedActivities(
      totalTime: json['totalTime'],
      thumbnails: List<dynamic>.from(json['thumbnails']),
    );
  }
}

class LoginDates {
  final List<dynamic> streak;

  LoginDates({
    required this.streak,
  });

  factory LoginDates.fromJson(Map<String, dynamic> json) {
    return LoginDates(
      streak: List<dynamic>.from(json['streak']),
    );
  }
}
