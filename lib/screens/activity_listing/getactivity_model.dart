import '../../utils/urls.dart';

class Activity {
  final String id;
  final String name;
  final String description;
  final String thumbnail;
  final String video;
  final bool isFavorite;
  final List<String> tags;
  final String categoryName;

  bool get isDailyPause => categoryName.trim().toLowerCase() == 'daily pause';
  bool get isDailyAnchor => categoryName.trim().toLowerCase() == 'daily anchor';
  String get categoryLabel => isDailyPause
      ? 'Daily Pause'
      : isDailyAnchor
          ? 'Daily Anchor'
          : categoryName;

  Activity({
    required this.id,
    required this.name,
    required this.description,
    required this.thumbnail,
    required this.video,
    required this.isFavorite,
    required this.tags,
    this.categoryName = '',
  });

  // Factory constructor to parse JSON response
  factory Activity.fromJson(Map<String, dynamic> json) {
    // Parsing tags
    final rawTags = json['tags'];
    List<String> parsedTags = [];

    if (rawTags is List) {
      parsedTags = rawTags
          .whereType<Map<String, dynamic>>()
          .map((tagMap) => tagMap['name']?.toString() ?? '')
          .where((name) => name.isNotEmpty)
          .toList();
    }

    final baseUrlimages = Urls.baseUrlimages;
    return Activity(
      categoryName: json['categoryName']?.toString() ?? '',
      id: json['_id'],
      name: json['name'],
      description: json['description'],
      thumbnail: json['thumbnail'],
      video: json['video'] != null ? '$baseUrlimages ${json['video']}' : '',
      isFavorite: json['isFavorite'] ?? false,
      tags: parsedTags,
    );
  }
}

class ActivityResponse {
  final String message;
  final List<Activity> activities;
  final List<Activity> recommendedActivities;
  final bool status;

  ActivityResponse({
    required this.message,
    required this.activities,
    required this.recommendedActivities,
    required this.status,
  });

  // Factory constructor to parse the entire response
  factory ActivityResponse.fromJson(Map<String, dynamic> json) {
    // Parsing activities
    List<Activity> activities = (json['data'] as List)
        .map((activityJson) => Activity.fromJson(activityJson))
        .toList();

    // Parsing recommended activities
    List<Activity> recommendedActivities =
        (json['recommendedActivities'] as List)
            .map((activityJson) => Activity.fromJson(activityJson))
            .toList();

    return ActivityResponse(
      message: json['message'],
      activities: activities,
      recommendedActivities: recommendedActivities,
      status: json['status'],
    );
  }
}
