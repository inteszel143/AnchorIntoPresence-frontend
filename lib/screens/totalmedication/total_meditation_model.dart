class TotalMeditationDataResponse {
  final String message;
  final TotalMeditationData data;
  final bool status;

  TotalMeditationDataResponse({
    required this.message,
    required this.data,
    required this.status,
  });

  factory TotalMeditationDataResponse.fromJson(Map<String, dynamic> json) {
    return TotalMeditationDataResponse(
      message: json['message'].toString(),
      data: TotalMeditationData.fromJson(json['data'] ?? {}),
      status: json['status'] ?? false,
    );
  }
}

class TotalMeditationData {
  final double average;
  final List<Category> categories;
  final List<Day> week;

  TotalMeditationData({
    required this.average,
    required this.categories,
    required this.week,
  });

  factory TotalMeditationData.fromJson(Map<String, dynamic> json) {
    return TotalMeditationData(
      average:
          (json['average'] is num) ? (json['average'] as num).toDouble() : 0.0,
      categories: (json['categories'] as List?)
              ?.where((item) => item is Map<String, dynamic>)
              .map((category) =>
                  Category.fromJson(category as Map<String, dynamic>))
              .toList() ??
          [],
      week: (json['week'] as List?)
              ?.map((day) => Day.fromJson(day as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class Category {
  final String name;
  final double value;
  final int percentage;

  Category({
    required this.name,
    required this.value,
    required this.percentage,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      name: json['name']?.toString() ?? '',
      value: (json['value'] is num) ? (json['value'] as num).toDouble() : 0.0,
      percentage:
          (json['percentage'] is num) ? (json['percentage'] as num).toInt() : 0,
    );
  }
}

class Day {
  final String day;
  final int value;

  Day({
    required this.day,
    required this.value,
  });

  factory Day.fromJson(Map<String, dynamic> json) {
    return Day(
      day: json['day']?.toString() ?? '',
      value: (json['value'] is int) ? json['value'] as int : 0,
    );
  }
}
