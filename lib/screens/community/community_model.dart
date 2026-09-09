import '../../utils/urls.dart';

class Post {
  final String id;
  final String shareId;
  final String userId;
  final String userName;
  final String? image;
  final String message;
  final String postType;
  List<String> images;
  final bool postAnonymously;
  final bool liked;
  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final DateTime createdAt;

  Post({
    required this.id,
    required this.shareId,
    required this.userId,
    required this.userName,
    this.image,
    required this.message,
    required this.postType,
    required this.images,
    required this.postAnonymously,
    required this.liked,
    required this.likesCount,
    required this.commentsCount,
    required this.sharesCount,
    required this.createdAt,
  });

  List<String> get imagesList => images.isEmpty ? [] : images;

  factory Post.fromJson(Map<String, dynamic> json) {
    // Safely extract user image
    String? rawImage = json['userId']?['image'];
    String image = (rawImage != null && rawImage.isNotEmpty)
        ? '${Urls.baseUrlimages}$rawImage'
        : '';

    // Parse images, ensure it's a list of strings
    List<String> postImages =
        json['images'] != null ? List<String>.from(json['images']) : [];

    // Construct the Post object
    return Post(
      id: json['_id'] as String,
      shareId:
          json['shareId'] as String? ?? '', // Default empty string if missing
      userId:
          json['userId']?['_id'] as String ?? 'Unknown User', // Safe fallback
      userName:
          json['userId']?['name'] as String ?? 'Anonymous', // Safe fallback
      image: image,
      message: json['message'] as String? ??
          '', // Default to empty string if missing
      postType: json['postType'] as String? ?? 'Unknown', // Default fallback
      liked: json['liked'] as bool? ?? false, // Safe fallback for boolean
      images: postImages, // No longer nullable, ensure it’s always a list
      postAnonymously:
          json['postAnonymously'] as bool? ?? false, // Safe fallback
      likesCount: json['likesCount'] as int? ?? 0, // Safe fallback for int
      commentsCount:
          json['commentsCount'] as int? ?? 0, // Safe fallback for int
      sharesCount: json['sharesCount'] as int? ?? 0, // Safe fallback for int
      createdAt: DateTime.parse(json['createdAt'] as String? ??
          DateTime.now().toString()), // Safe fallback for DateTime
    );
  }

  // A helper method to convert PostDetailModal data into Post (if needed for detail screens)
  static Post fromPostDetail(Map<String, dynamic> json) {
    String? rawImage = json['userId']?['image'];
    String image = (rawImage != null && rawImage.isNotEmpty)
        ? '${Urls.baseUrlimages}$rawImage'
        : '';

    List<String> postImages =
        json['images'] != null ? List<String>.from(json['images']) : [];

    return Post(
      id: json['_id'] as String,
      shareId: '', // Post detail doesn't usually have shareId
      userId: json['userId']?['_id'] as String ?? 'Unknown User',
      userName: json['userId']?['name'] as String ?? 'Anonymous',
      image: image,
      message: json['message'] as String? ?? '',
      postType: json['postType'] as String? ?? 'Unknown',
      liked: false, // Assume not liked by current user in PostDetail
      images: postImages,
      postAnonymously: false, // Assume not anonymous in PostDetail
      likesCount: json['likesCount'] as int? ?? 0,
      commentsCount: json['commentsCount'] as int? ?? 0,
      sharesCount: json['sharesCount'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Post copyWith({
    String? id,
    String? shareId,
    String? userId,
    String? userName,
    String? image,
    String? message,
    String? postType,
    List<String>? images,
    bool? postAnonymously,
    bool? liked,
    int? likesCount,
    int? commentsCount,
    int? sharesCount,
    DateTime? createdAt,
  }) {
    return Post(
      id: id ?? this.id,
      shareId: shareId ?? this.shareId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      image: image ?? this.image,
      message: message ?? this.message,
      postType: postType ?? this.postType,
      images: images ?? this.images,
      postAnonymously: postAnonymously ?? this.postAnonymously,
      liked: liked ?? this.liked,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      sharesCount: sharesCount ?? this.sharesCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// A single "like" entry on a post — one user + when they liked it.
/// Used by the "who liked this post" bottom sheet.
class PostLike {
  final String id;
  final String userId;
  final String userName;
  final String? userImage;
  final DateTime createdAt;

  PostLike({
    required this.id,
    required this.userId,
    required this.userName,
    this.userImage,
    required this.createdAt,
  });

  factory PostLike.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? {};
    final String? rawImage = user['image'] as String?;
    final String? image = (rawImage != null && rawImage.isNotEmpty)
        ? '${Urls.baseUrlimages}$rawImage'
        : null;

    return PostLike(
      id: json['_id'] as String? ?? '',
      userId: user['_id'] as String? ?? '',
      userName: user['name'] as String? ?? 'Anonymous',
      userImage: image,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

/// Wraps one page of the "post likes" API response, including the
/// pagination info needed to drive infinite scroll.
class PostLikesPage {
  final List<PostLike> likes;
  final int page;
  final int totalPages;
  final int totalLikes;

  PostLikesPage({
    required this.likes,
    required this.page,
    required this.totalPages,
    required this.totalLikes,
  });

  bool get hasMore => page < totalPages;

  factory PostLikesPage.fromJson(Map<String, dynamic> json) {
    final List<dynamic> data = json['data'] as List<dynamic>? ?? [];
    final Map<String, dynamic> pagination =
        json['pagination'] as Map<String, dynamic>? ?? {};

    return PostLikesPage(
      likes: data
          .map((e) => PostLike.fromJson(e as Map<String, dynamic>))
          .toList(),
      page: pagination['page'] as int? ?? 1,
      totalPages: pagination['totalPages'] as int? ?? 1,
      totalLikes: pagination['totalLikes'] as int? ?? data.length,
    );
  }
}
