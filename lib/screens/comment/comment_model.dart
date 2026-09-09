// Represents a reply to a comment.
class Reply {
  final String id;
  final String postId;
  final String? userId;
  final String? userName;
  final String? image;
  final String parentCommentId;
  final String message;
  final int likesCount;
  final int repliesCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Reply({
    required this.id,
    required this.postId,
    this.userId,
    this.userName,
    this.image,
    required this.parentCommentId,
    required this.message,
    required this.likesCount,
    required this.repliesCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Reply.fromJson(Map<String, dynamic> json) {
    return Reply(
      id: json['_id'],
      postId: json['postId'],
      userId: json['userId']?['_id'] as String?,
      userName: json['userId']?['name'] as String?,
      image: json['userId']?['image'] as String?,
      parentCommentId: json['parentCommentId'] ?? '',
      message: json['message'] ?? '',
      likesCount: json['likesCount'] ?? 0,
      repliesCount: json['repliesCount'] ?? 0,
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  // To JSON map
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'postId': postId,
      'userId': userId,
      'userName': userName,
      'userImage': image,
      'parentCommentId': parentCommentId,
      'message': message,
      'likesCount': likesCount,
      'repliesCount': repliesCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

// Model for the Comment
class Comment {
  final String id;
  final String postId;
  final String? userId;
  final String? userName;
  final String? image;
  final String? parentCommentId;
  final String message;
  final int likesCount;
  final bool liked;
  final int repliesCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Reply>? replies;

  Comment({
    required this.id,
    required this.postId,
    this.userId,
    this.userName,
    this.image,
    this.parentCommentId,
    required this.message,
    required this.likesCount,
    required this.liked,
    required this.repliesCount,
    required this.createdAt,
    required this.updatedAt,
    this.replies,
  });

  // From JSON map to Comment object
  factory Comment.fromJson(Map<String, dynamic> json) {
    var repliesList =
        (json['replies'] as List?)?.map((i) => Reply.fromJson(i)).toList();

    if (repliesList == null || repliesList.isEmpty) {
      repliesList = [];
    }

    return Comment(
      id: json['_id'],
      postId: json['postId'],
      userId: json['userId']?['_id'] as String?,
      userName: json['userId']?['name'] as String?,
      image: json['userId']?['image'] as String?,
      parentCommentId: json['parentCommentId'] as String?,
      message: json['message'] ?? '',
      likesCount: json['likesCount'] ?? 0,
      liked: json['liked'] ?? false,
      repliesCount: json['repliesCount'] ?? 0,
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      replies: repliesList,
    );
  }

  // To JSON map
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'postId': postId,
      'userId': userId,
      'userName': userName,
      'userImage': image,
      'parentCommentId': parentCommentId,
      'message': message,
      'likesCount': likesCount,
      'liked': liked,
      'repliesCount': repliesCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'replies': replies?.map((e) => e.toJson()).toList() ?? [],
    };
  }
}

// Root Model for Response Data
class CommentResponse {
  final bool status;
  final String message;
  final int page;
  final int limit;
  final List<Comment> data;

  CommentResponse({
    required this.status,
    required this.message,
    required this.page,
    required this.limit,
    required this.data,
  });

  // From JSON map to CommentResponse object
  factory CommentResponse.fromJson(Map<String, dynamic> json) {
    var list = json['data'] as List;
    List<Comment> commentList = list.map((i) => Comment.fromJson(i)).toList();

    return CommentResponse(
      status: json['status'],
      message: json['message'],
      page: json['page'],
      limit: json['limit'],
      data: commentList,
    );
  }

  // To JSON map
  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'page': page,
      'limit': limit,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }
}
