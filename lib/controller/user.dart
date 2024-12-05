class User {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneCountryCode;
  final String phoneNumber;
  final bool isPremium;
  final bool isVerified;
  final String role;
  final DateTime createdAt;
  final bool notificationsEnabled;

  const User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneCountryCode,
    required this.phoneNumber,
    required this.isVerified,
    required this.isPremium,
    required this.role,
    required this.createdAt,
    required this.notificationsEnabled,
  });
}

class BusinessUser extends User {
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
      this.teamMembers,
      {required super.id,
      required super.firstName,
      required super.lastName,
      required super.email,
      required super.phoneCountryCode,
      required super.phoneNumber,
      required super.isVerified,
      required super.isPremium,
      required super.role,
      required super.createdAt,
      required super.notificationsEnabled});
}
