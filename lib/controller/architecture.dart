class WorkSession {
  int? id;
  final String startTime;
  final String endTime;
  bool isCompleted;
  WorkSession(
      {this.id,
      required this.startTime,
      required this.endTime,
      this.isCompleted = false});
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'startTime': startTime,
      'endTime': endTime,
      'isCompleted': isCompleted ? 1 : 0,
    };
  }
}

class BreakSession {
  final int id;
  final int workSessionId;
  final String breakStartTime;
  final String breakEndTime;
  BreakSession(
      {required this.id,
      required this.workSessionId,
      required this.breakStartTime,
      required this.breakEndTime});
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'workSessionId': workSessionId,
      'breakStartTime': breakStartTime,
      'breakEndTime': breakEndTime,
    };
  }
}
