// Represents the API response received after submitting activity progress or completion.
class PostActivityResponseModel {
  final String message;
  final bool status;
  final ActivityLogData data;

  PostActivityResponseModel({
    required this.message,
    required this.status,
    required this.data,
  });

  factory PostActivityResponseModel.fromJson(Map<String, dynamic> json) {
    return PostActivityResponseModel(
      message: json['message'],
      status: json['status'],
      data: ActivityLogData.fromJson(json['data']),
    );
  }
}

// Contains the user's activity progress, completion status, and activity log details.
class ActivityLogData {
  final String userId;
  final String videoTimestamp;
  final String totalVideoTime;
  final bool isCompleted;
  final String activityId;
  final String id;
  final String createdAt;
  final String updatedAt;

  ActivityLogData({
    required this.userId,
    required this.videoTimestamp,
    required this.totalVideoTime,
    required this.isCompleted,
    required this.activityId,
    required this.id,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ActivityLogData.fromJson(Map<String, dynamic> json) {
    return ActivityLogData(
      userId: json['userId'],
      videoTimestamp: json['videoTimestamp'],
      totalVideoTime: json['totalVideoTime'],
      isCompleted: json['isCompleted'],
      activityId: json['activityId'],
      id: json['_id'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}
