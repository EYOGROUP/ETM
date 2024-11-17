class WorkSession {
  int? id;
  final String startTime;
  final String endTime;
  final int categoryId;
  bool isCompleted;
  WorkSession(
      {this.id,
      required this.startTime,
      required this.endTime,
      required this.categoryId,
      this.isCompleted = false});
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'startTime': startTime,
      'endTime': endTime,
      'categoryId': categoryId,
      'isCompleted': isCompleted ? 1 : 0,
    };
  }
}

class BreakSession {
  int? id;
  final int workSessionId;
  final String breakStartTime;
  final String breakEndTime;
  BreakSession(
      {this.id,
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

class ETMCategory {
  int? id;
  final String name;
  final bool isAdsDisplayed;
  ETMCategory({this.id, required this.name, required this.isAdsDisplayed});
  Map<String, dynamic> toMap() {
    return {"id": id, "name": name, "isAdsDisplayed": isAdsDisplayed ? 1 : 0};
  }
}
