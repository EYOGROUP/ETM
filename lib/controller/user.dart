enum Gender { male, female, nothing }

class ETMUser {
  final String id;
  final String firstName;
  final String lastName;
  final String userName;
  final String email;
  final String phoneCountryCode;
  final String phoneNumber;
  final bool isPremium;
  final bool isVerified;
  final String role;
  final DateTime createdAt;

  final String phoneCode;
  final bool isPushNotificationsActive;
  final bool isInAppNotificationsActive;
  final bool isEmailNotificationsActive;
  String? gender;
  String? billingEmailAddress;
  String? payPalEmailAddress;

  ETMUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.userName,
    required this.email,
    required this.phoneCountryCode,
    required this.phoneNumber,
    required this.isVerified,
    required this.isPremium,
    required this.role,
    required this.createdAt,
    required this.phoneCode,
    required this.isPushNotificationsActive,
    required this.isInAppNotificationsActive,
    required this.isEmailNotificationsActive,
    this.billingEmailAddress,
    this.gender,
    this.payPalEmailAddress,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'userName': userName,
      'email': email,
      'phoneCountryCode': phoneCountryCode,
      'phoneNumber': phoneNumber,
      'phoneCode': phoneCode,
      'isPremium': isPremium,
      'isVerified': isVerified,
      'createdAt': createdAt,
      'role': role,
      'gender': gender ?? '',
      "billingEmailAddress": billingEmailAddress,
      "payPalEmailAddress": payPalEmailAddress,
      'isInAppNotificationsActive': isInAppNotificationsActive,
      'isEmailNotificationsActive': isEmailNotificationsActive,
      'isPushNotificationsActive': isPushNotificationsActive,
    };
  }
}

class BusinessUser extends ETMUser {
  final String companyName;
  final String businessType;
  final String businessEmail;
  final String companyPhoneNumber;
  final String businessAddress;
  final String businessLicenseNumber;
  final int employeeCount;
  final String subscriptionPlan;
  final String paymentMethod;
  final String billingAddress;
  final String taxIdentificationNumber;
  final List<String> teamMembers;

  BusinessUser(
    this.companyName,
    this.businessType,
    this.businessEmail,
    this.companyPhoneNumber,
    this.businessAddress,
    this.businessLicenseNumber,
    this.employeeCount,
    this.subscriptionPlan,
    this.paymentMethod,
    this.billingAddress,
    this.taxIdentificationNumber,
    this.teamMembers, {
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.email,
    required super.phoneCountryCode,
    required super.phoneNumber,
    required super.isVerified,
    required super.isPremium,
    required super.role,
    required super.createdAt,
    required super.userName,
    required super.phoneCode,
    super.gender,
    required super.isInAppNotificationsActive,
    required super.isPushNotificationsActive,
    required super.isEmailNotificationsActive,
  });
}
