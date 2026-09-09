/// Model for recently played activities response from API
class RecentlyPlayedResponse {
  final String message;
  final List<RecentlyPlayedActivity> data;
  final RecentlyPlayedPagination pagination;
  final bool status;

  RecentlyPlayedResponse({
    required this.message,
    required this.data,
    required this.pagination,
    required this.status,
  });

  /// Creates instance from JSON response
  factory RecentlyPlayedResponse.fromJson(Map<String, dynamic> json) {
    return RecentlyPlayedResponse(
      message: json['message']?.toString() ?? '',
      data: (json['data'] as List<dynamic>? ?? [])
          .map(
            (e) => RecentlyPlayedActivity.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      pagination: json['pagination'] != null
          ? RecentlyPlayedPagination.fromJson(json['pagination'])
          : RecentlyPlayedPagination.empty(),
      status: json['status'] == true,
    );
  }

  /// Returns empty response for fallback scenarios
  static RecentlyPlayedResponse empty() => RecentlyPlayedResponse(
        message: '',
        data: const [],
        pagination: RecentlyPlayedPagination.empty(),
        status: false,
      );
}

/// Model for individual recently played activity
class RecentlyPlayedActivity {
  final String id;
  final DateTime? playedAt;
  final String videoTimestamp;
  final String totalVideoTime;
  final bool isCompleted;
  final RecentlyPlayedCategory? category;
  final String name;
  final String thumbnail;
  final String video;
  final String description;
  final String duration;
  final List<RecentlyPlayedTag> tags;
  final bool isFavorite;

  RecentlyPlayedActivity({
    required this.id,
    this.playedAt,
    required this.videoTimestamp,
    required this.totalVideoTime,
    required this.isCompleted,
    this.category,
    required this.name,
    required this.thumbnail,
    required this.video,
    required this.description,
    required this.duration,
    required this.tags,
    required this.isFavorite,
  });

  /// Getter for category ID
  String? get categoryId => category?.id;

  /// Getter for tag names list
  List<String> get tagNames => tags.map((t) => t.name).toList();

  /// Creates instance from JSON response
  factory RecentlyPlayedActivity.fromJson(Map<String, dynamic> json) {
    return RecentlyPlayedActivity(
      id: json['_id']?.toString() ?? '',
      playedAt: json['playedAt'] != null
          ? DateTime.tryParse(json['playedAt'].toString())
          : null,
      videoTimestamp: json['videoTimestamp']?.toString() ?? '00:00',
      totalVideoTime: json['totalVideoTime']?.toString() ?? '--:--',
      isCompleted: json['isCompleted'] == true,
      category: json['category'] != null
          ? RecentlyPlayedCategory.fromJson(json['category'])
          : null,
      name: json['name']?.toString() ?? '',
      thumbnail: json['thumbnail']?.toString() ?? '',
      video: json['video']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      duration: json['duration']?.toString() ?? '',
      tags: (json['tags'] as List<dynamic>? ?? [])
          .map((e) => RecentlyPlayedTag.fromJson(e as Map<String, dynamic>))
          .toList(),
      isFavorite: json['isFavorite'] == true,
    );
  }
}

/// Model for activity category
class RecentlyPlayedCategory {
  final String id;
  final String name;

  RecentlyPlayedCategory({required this.id, required this.name});

  /// Creates instance from JSON response
  factory RecentlyPlayedCategory.fromJson(Map<String, dynamic> json) {
    return RecentlyPlayedCategory(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }
}

/// Model for activity tags
class RecentlyPlayedTag {
  final String id;
  final String name;

  RecentlyPlayedTag({required this.id, required this.name});

  /// Creates instance from JSON response
  factory RecentlyPlayedTag.fromJson(Map<String, dynamic> json) {
    return RecentlyPlayedTag(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }
}

/// Model for pagination data
class RecentlyPlayedPagination {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  RecentlyPlayedPagination({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  /// Creates instance from JSON response
  factory RecentlyPlayedPagination.fromJson(Map<String, dynamic> json) {
    return RecentlyPlayedPagination(
      page: (json['page'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? 10,
      total: (json['total'] as num?)?.toInt() ?? 0,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 1,
    );
  }

  /// Returns empty pagination for fallback
  static RecentlyPlayedPagination empty() =>
      RecentlyPlayedPagination(page: 1, limit: 10, total: 0, totalPages: 1);
}
