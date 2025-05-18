class TrackingSession {
  final String id;
  final DateTime startTime;
  DateTime? endTime;
  final String categoryId;
  final String? userId;
  int? durationMinutes;

  String? taskDescription;
  final DateTime createdAt;
  String? trackingSessionId;
  final bool isSplit;
  bool isCompleted;
  String? trackingSessionIdCommun;
  TrackingSession(
      {required this.id,
      required this.startTime,
      this.userId,
      this.endTime,
      this.durationMinutes = 0,
      this.taskDescription = '',
      required this.createdAt,
      required this.categoryId,
      this.trackingSessionId,
      this.isSplit = false,
      this.trackingSessionIdCommun,
      this.isCompleted = false});
  Map<String, dynamic> lokalToMap() {
    return {
      'id': id,
      'startTime': startTime.toString(),
      'endTime': endTime?.toString() ?? '',
      "durationMinutes": durationMinutes ?? 0,
      "createdAt": createdAt.toString(),
      'categoryId': categoryId,
      "taskDescription": taskDescription,
      'isCompleted': isCompleted ? 1 : 0,
      "trackingSessionId": trackingSessionId,
      'isSplit': isSplit ? 1 : 0,
      "trackingSessionIdCommun": trackingSessionIdCommun,
    };
  }

  Map<String, dynamic> cloudToMap() {
    return {
      'id': id,
      'startTime': startTime,
      'endTime': endTime ?? '',
      "durationMinutes": durationMinutes ?? 0,
      "createdAt": createdAt,
      'categoryId': categoryId,
      "taskDescription": taskDescription,
      'isCompleted': isCompleted,
      "trackingSessionId": trackingSessionId,
      "userId": userId,
      "isSplit": isSplit
    };
  }
}

class BreakSession {
  final String id;
  final String trackingSessionId;
  final DateTime startTime;
  DateTime? endTime;
  int? durationMinutes;
  String? reason;
  final bool isCompleted;
  final DateTime createdAt;
  final bool isSplit;

  BreakSession({
    required this.id,
    required this.trackingSessionId,
    required this.startTime,
    this.isSplit = false,
    this.endTime,
    this.durationMinutes,
    this.reason,
    required this.createdAt,
    this.isCompleted = false,
  });
  Map<String, dynamic> lokalToMap() {
    return {
      'id': id,
      'trackingSessionId': trackingSessionId,
      'startTime': startTime.toString(),
      'endTime': endTime?.toString() ?? "",
      "durationMinutes": durationMinutes ?? 0,
      "reason": reason ?? '',
      "createdAt": createdAt.toString(),
      'isSplit': isSplit ? 1 : 0,
      'isCompleted': isCompleted ? 1 : 0,
    };
  }

  Map<String, dynamic> cloudToMap() {
    return {
      'id': id,
      'trackingSessionId': trackingSessionId,
      'startTime': startTime,
      'endTime': endTime,
      "durationMinutes": durationMinutes ?? 0,
      "reason": reason,
      "createdAt": createdAt,
      'isCompleted': isCompleted,
      "isSplit": isSplit
    };
  }
}
