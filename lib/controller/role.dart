import 'package:uuid/uuid.dart';

class Role {
  final String id;
  final Map<String, dynamic> name;
  final bool isTrackingDayLimited;
  final List<String> permissions;

  Role(
      {required this.id,
      required this.name,
      required this.permissions,
      required this.isTrackingDayLimited});
  static final roles = [
    Role(
        id: const Uuid().v4(),
        name: {'en': 'Admin', 'fr': 'Administrateur', 'de': 'Administrator'},
        isTrackingDayLimited: false,
        permissions: ["manage_users", "view_reports", "assign_roles"]),
    Role(
        name: {'en': 'Manager', 'fr': 'Manager', 'de': 'Manager'},
        isTrackingDayLimited: true,
        permissions: ["view_team_reports", "assign_tasks"],
        id: const Uuid().v4()),
    Role(
        name: {'en': 'Employee', 'fr': 'Employé', 'de': 'Mitarbeiter'},
        isTrackingDayLimited: true,
        permissions: ["log_time", "view_self_reports"],
        id: const Uuid().v4()),
    Role(
        name: {'en': 'HR', 'fr': 'RH', 'de': 'Personalabteilung'},
        permissions: ["manage_absences", "view_all_reports"],
        isTrackingDayLimited: false,
        id: const Uuid().v4()),
    Role(
        name: {
          'en': 'Super Admin',
          'fr': 'Super Administrateur',
          'de': 'Super-Administrator'
        },
        isTrackingDayLimited: false,
        permissions: ["full_access"],
        id: const Uuid().v4()),
    Role(
        name: {'en': 'Support', 'fr': 'Support', 'de': 'Support'},
        isTrackingDayLimited: false,
        permissions: ["view_support_tickets", "respond_tickets"],
        id: const Uuid().v4()),
    Role(
        name: {'en': 'Developer', 'fr': 'Développeur', 'de': 'Entwickler'},
        isTrackingDayLimited: false,
        permissions: ["access_logs", "deploy_updates"],
        id: const Uuid().v4()),
    Role(
        name: {'en': 'Tester', 'fr': 'Testeur', 'de': 'Tester'},
        isTrackingDayLimited: false,
        permissions: ["test_features", "report_issues"],
        id: const Uuid().v4()),
    Role(
        name: {'en': 'Marketing', 'fr': 'Marketing', 'de': 'Marketing'},
        isTrackingDayLimited: false,
        permissions: ["create_campaigns", "analyze_behavior"],
        id: const Uuid().v4()),
  ];
  Map<String, dynamic> roleToMap() {
    return {
      "id": id,
      "name": name,
      "permission": permissions,
      "isTrackingDayLimited": isTrackingDayLimited
    };
  }
}
