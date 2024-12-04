class WorkSession {
  final String id;
  final DateTime startTime;
  DateTime? endTime;
  final String categoryId;
  int? durationMinutes;
  int? breakTimeMinutes;
  String? taskDescription;
  final DateTime createdAt;
  bool isCompleted;
  WorkSession(
      {required this.id,
      required this.startTime,
      this.endTime,
      this.durationMinutes = 0,
      this.breakTimeMinutes = 0,
      this.taskDescription = '',
      required this.createdAt,
      required this.categoryId,
      this.isCompleted = false});
  Map<String, dynamic> lokalToMap() {
    return {
      'id': id,
      'startTime': startTime.toString(),
      'endTime': endTime?.toString() ?? '',
      "durationMinutes": durationMinutes ?? 0,
      "breakTimeMinutes": breakTimeMinutes ?? 0,
      "createdAt": createdAt.toString(),
      'categoryId': categoryId,
      "taskDescription": taskDescription,
      'isCompleted': isCompleted ? 1 : 0,
    };
  }
}

class BreakSession {
  final String id;
  final String workSessionId;
  final DateTime startTime;
  DateTime? endTime;
  int? durationMinutes;
  String? reason;
  final DateTime createdAt;
  BreakSession({
    required this.id,
    required this.workSessionId,
    required this.startTime,
    this.endTime,
    this.durationMinutes,
    this.reason,
    required this.createdAt,
  });
  Map<String, dynamic> lokalToMap() {
    return {
      'id': id,
      'workSessionId': workSessionId,
      'startTime': startTime.toString(),
      'endTime': endTime?.toString() ?? "",
      "durationMinutes": durationMinutes ?? 0,
      "reason": reason ?? '',
      "createdAt": createdAt.toString(),
    };
  }
}
