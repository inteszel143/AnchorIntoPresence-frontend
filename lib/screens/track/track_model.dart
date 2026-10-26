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
  final List<DateTime>? practiceDates;
  final List<CompletedActivity> completedActivities;

  Data({
    required this.loggedActivities,
    required this.categoryDistribution,
    required this.loginDates,
    this.practiceDates,
    this.completedActivities = const [],
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      loggedActivities: LoggedActivities.fromJson(json['loggedActivities']),
      categoryDistribution:
          Map<String, dynamic>.from(json['categoryDistribution']),
      loginDates: LoginDates.fromJson(json['loginDates']),
      practiceDates: (json['practiceDates'] as List?)
          ?.map((date) => DateTime.tryParse(date.toString())?.toLocal())
          .whereType<DateTime>()
          .toList(),
      completedActivities: (json['completedActivities'] as List? ?? [])
          .map((entry) => CompletedActivity.fromJson(entry))
          .toList(),
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

class CompletedActivity {
  final String name;
  final DateTime? completedAt;
  final String duration;

  CompletedActivity(
      {required this.name, this.completedAt, required this.duration});

  factory CompletedActivity.fromJson(Map<String, dynamic> json) =>
      CompletedActivity(
        name: json['name'] as String? ?? 'Meditation',
        completedAt:
            DateTime.tryParse(json['completedAt'] as String? ?? '')?.toLocal(),
        duration: json['totalVideoTime'] as String? ?? '',
      );
}
