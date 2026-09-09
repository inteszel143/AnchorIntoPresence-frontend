/// Model for home page data response from API
class HomePageDataModel {
  final String message;
  final Map<String, CategoryData> data;
  final bool status;

  HomePageDataModel({
    required this.message,
    required this.data,
    required this.status,
  });

  /// Creates instance from JSON response
  factory HomePageDataModel.fromJson(Map<String, dynamic> json) {
    var dataMap = json['data'] as Map<String, dynamic>? ?? {};
    Map<String, CategoryData> categoryDataMap = {};

    dataMap.forEach((key, value) {
      categoryDataMap[key] = CategoryData.fromJson(value);
    });

    return HomePageDataModel(
      message: json['message'],
      data: categoryDataMap,
      status: json['status'],
    );
  }
}

/// Model for category data containing list of activities
class CategoryData {
  final List<ActivityData> activities;

  CategoryData({required this.activities});

  /// Creates instance from JSON list
  factory CategoryData.fromJson(List<dynamic> json) {
    List<ActivityData> activityList =
        json.map((activity) => ActivityData.fromJson(activity)).toList();
    return CategoryData(activities: activityList);
  }
}

/// Model for individual activity data
class ActivityData {
  final String id;
  final String categoryId;
  final String name;
  final String thumbnail;
  final String description;
  final String categoryName;
  final String? video;
  final List<String>? tagName;
  final bool isFavorite;
  final DateTime? createdAt;

  ActivityData({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.thumbnail,
    required this.description,
    required this.categoryName,
    this.video,
    this.tagName,
    required this.isFavorite,
    this.createdAt,
  });

  /// Creates instance from JSON response with tag parsing
  factory ActivityData.fromJson(Map<String, dynamic> json) {
    var rawTag = json['tagName'];

    // Parse tags handling both List and String formats
    List<String> parsedTags;
    if (rawTag is List) {
      parsedTags = List<String>.from(rawTag);
    } else if (rawTag is String) {
      parsedTags = [rawTag];
    } else {
      parsedTags = [];
    }

    return ActivityData(
      id: json['_id'],
      categoryId: json['categoryId'],
      name: json['name'],
      thumbnail: json['thumbnail'],
      description: json['description'],
      categoryName: json['categoryName'],
      video: json['video'] ?? '',
      tagName: parsedTags,
      isFavorite: json['isFavorite'] ?? false,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }
}

/// Model for user profile data
class ProfileDataModel {
  final String id;
  final String name;
  final String email;
  final String? provider;
  final bool isVerified;
  final bool isBlocked;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? image;
  final String? fcmToken;
  final bool resetPassword;
  final String? userMood;
  final String? subscriptionStatus;
  final String? productId;

  ProfileDataModel({
    required this.id,
    required this.name,
    required this.email,
    this.provider,
    required this.isVerified,
    required this.isBlocked,
    required this.createdAt,
    required this.updatedAt,
    this.image,
    this.fcmToken,
    required this.resetPassword,
    this.userMood,
    this.subscriptionStatus,
    this.productId,
  });

  /// Creates instance from JSON response
  factory ProfileDataModel.fromJson(Map<String, dynamic> json) {
    return ProfileDataModel(
      id: json['_id'],
      name: json['name'],
      email: json['email'],
      provider: json['provider'],
      isVerified: json['isVerified'],
      isBlocked: json['isBlocked'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      image: json['image'],
      fcmToken: json['fcmToken'],
      resetPassword: json['resetPassword'],
      userMood: json['userMood'],
      subscriptionStatus: json['subscriptionStatus'],
      productId: json['productId'],
    );
  }
}
