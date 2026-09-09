
class Notification {
  final String id;
  final String title;
  final String description;
  final DateTime createdAt;

  Notification({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
  });

  factory Notification.fromMap(Map<String, dynamic> map) {
    return Notification(
      id: map['_id'],
      title: map['title'],
      description: map['description'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class NotificationResponse {
  final List<Notification> data;
  final int currentPage;
  final int totalPages;
  final int totalItems;

  NotificationResponse({
    required this.data,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
  });

  factory NotificationResponse.fromMap(Map<String, dynamic> map) {
    return NotificationResponse(
      data: List<Notification>.from(
        map['data'].map((x) => Notification.fromMap(x)),
      ),
      currentPage: map['currentPage'],
      totalPages: map['totalPages'],
      totalItems: map['totalItems'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'data': data.map((x) => x.toMap()).toList(),
      'currentPage': currentPage,
      'totalPages': totalPages,
      'totalItems': totalItems,
    };
  }
}
