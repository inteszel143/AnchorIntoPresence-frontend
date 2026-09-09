class ReminderResponse {
  final String message;
  final ReminderData data;
  final bool status;

  ReminderResponse({
    required this.message,
    required this.data,
    required this.status,
  });

  factory ReminderResponse.fromJson(Map<String, dynamic> json) {
    return ReminderResponse(
      message: json['message'],
      data: ReminderData.fromJson(json['data']),
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() => {
        'message': message,
        'data': data.toJson(),
        'status': status,
      };
}

class ReminderData {
  final String id;
  final String userId;
  final int v;
  final DateTime createdAt;
  final DateTime date;
  final String time;
  final DateTime updatedAt;
  final List<dynamic> weekday;

  ReminderData({
    required this.id,
    required this.userId,
    required this.v,
    required this.createdAt,
    required this.date,
    required this.time,
    required this.updatedAt,
    required this.weekday,
  });

  factory ReminderData.fromJson(Map<String, dynamic> json) {
    return ReminderData(
      id: json['_id'],
      userId: json['userId'],
      v: json['__v'],
      createdAt: DateTime.parse(json['createdAt']),
      date: DateTime.parse(json['date']),
      time: json['time'],
      updatedAt: DateTime.parse(json['updatedAt']),
      weekday: List<dynamic>.from(json['weekday']),
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'userId': userId,
        '__v': v,
        'createdAt': createdAt.toIso8601String(),
        'date': date.toIso8601String(),
        'time': time,
        'updatedAt': updatedAt.toIso8601String(),
        'weekday': weekday,
      };
}

class ReminderModel {
  final String id;
  final String? time;
  final DateTime? createdAt;
  final List<int> weekdays;
  final DateTime? date;

  ReminderModel({
    required this.id,
    required this.time,
    required this.createdAt,
    required this.weekdays,
    required this.date,
  });

  factory ReminderModel.fromJson(Map<String, dynamic> json) {
    return ReminderModel(
      id: json['_id'],
      time: json['time'],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      weekdays: List<int>.from(json['weekday']),
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
    );
  }
}

class TimeZoneUtils {
  /// local HH:mm -> UTC HH:mm string (for sending to API)
  static String localToUtcTimeString(int hour, int minute) {
    final now = DateTime.now();
    final local = DateTime(now.year, now.month, now.day, hour, minute);
    final utc = local.toUtc();
    return '${utc.hour.toString().padLeft(2, '0')}:${utc.minute.toString().padLeft(2, '0')}';
  }

  /// UTC HH:mm string -> local {hour, minute} (for displaying/editing)
  static Map<String, int> utcTimeStringToLocal(String utcTime) {
    final parts = utcTime.split(':');
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    final now = DateTime.now();
    final utcDt = DateTime.utc(now.year, now.month, now.day, hour, minute);
    final local = utcDt.toLocal();
    return {'hour': local.hour, 'minute': local.minute};
  }
}
