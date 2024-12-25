enum Status { submitted, inProgress, resolved, closed, failed }

class ContactSupport {
  final String id;
  final Map<String, dynamic> reason;
  final String description;
  final DateTime createdAt;
  final String senderId;
  final String? senderName;
  final String status;
  final String? assignedAgentId;
  ContactSupport({
    required this.id,
    required this.reason,
    required this.description,
    required this.createdAt,
    required this.senderId,
    required this.status, // Default status on creation
    this.senderName,
    this.assignedAgentId,
  });

  Map<String, dynamic> convertToMap() {
    return {
      "id": id,
      "reason": reason,
      "description": description,
      "createdAt": createdAt,
      "senderId": senderId,
      "senderName": senderName,
      "status": status,
      "assignedAgentId": assignedAgentId,
    };
  }
}
