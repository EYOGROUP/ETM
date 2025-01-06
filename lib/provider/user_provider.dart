import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_otp/email_otp.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';
import 'package:time_management/Navigation%20Pages/pagination.dart';
import 'package:time_management/Navigation%20Pages/profile/account/check_email.dart';
import 'package:time_management/Navigation%20Pages/profile/account/create_new_password.dart';
import 'package:time_management/constants.dart';
import 'package:time_management/controller/user.dart';
import 'package:time_management/db/mydb.dart';
import 'package:time_management/provider/tm_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UserProvider extends ChangeNotifier {
  Future<bool> isUserLogin({required BuildContext context}) async {
    bool isUserIn = true;
    bool isConnectedToInternet =
        await Provider.of<TimeManagementPovider>(context, listen: false)
            .isConnectedToInternet(context: context);
    if (isConnectedToInternet) {
      await FirebaseAuth.instance.currentUser?.reload();
    }
    if (context.mounted) {
      final currentUser = FirebaseAuth.instance.currentUser?.isAnonymous;

      if (currentUser == null) {
        isUserIn = false;
      }
    }
    return isUserIn;
  }

  Future<void> signInWithGoogle({required BuildContext context}) async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return;
    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Once signed in, return the UserCredential
    await FirebaseAuth.instance.signInWithCredential(credential);
  }

// check user name already used
  Future<bool> isUserNameAlreadyUser(
      {required String userNameChoosed, required BuildContext context}) async {
    bool isUserNameAlreadyExist = false;
    try {
      final users = await FirebaseFirestore.instance
          .collection('users')
          .where('userName', isEqualTo: userNameChoosed)
          .get();
      if (context.mounted) {
        if (users.size >= 1) {
          isUserNameAlreadyExist = true;
        }
      }
    } on FirebaseException catch (error) {
      Constants.showInSnackBar(
          value: error.message.toString(), context: context);
    }
    return isUserNameAlreadyExist;
  }

// signUp user only with email and password
  Future<bool> signUpUser(
      {required BuildContext context,
      required String email,
      required String password}) async {
    bool isUserRegistred = false;
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      if (context.mounted) {
        isUserRegistred = true;
      }
    } on FirebaseAuthException catch (error) {
      if (context.mounted) {
        Constants.showInSnackBar(
            value: error.message.toString(), context: context);
      }
    }
    return isUserRegistred;
  }

  Future<void> saveUserInFirebase(
      {required BuildContext context,
      required bool mounted,
      required String firstName,
      required String lastName,
      required String email,
      required String password,
      required String userName,
      String? phoneCode,
      String? phoneNumber,
      String? phoneCountryCode}) async {
    try {
      bool isUserRegistred =
          await signUpUser(context: context, email: email, password: password);
      if (!mounted) return;
      if (isUserRegistred) {
        final userId = FirebaseAuth.instance.currentUser?.uid;

        final normalUserRoleGet = await FirebaseFirestore.instance
            .collection('roles')
            .where('name.en', isEqualTo: 'Normal User')
            .get();
        if (!mounted) return;
        String normalUserRoleId = '';
        if (normalUserRoleGet.docs.isNotEmpty) {
          normalUserRoleId = normalUserRoleGet.docs.first.data()['id'];
        }
        //TODO make localisation request
        ETMUser user = ETMUser(
          id: userId!,
          firstName: firstName,
          lastName: lastName,
          userName: userName,
          email: email,
          phoneCountryCode: phoneCountryCode ?? '',
          phoneNumber: phoneNumber ?? '',
          phoneCode: phoneCode ?? '',
          isVerified: false,
          isPremium: false,
          role: normalUserRoleId,
          createdAt: DateTime.now(),
          isEmailNotificationsActive: true,
          isInAppNotificationsActive: true,
          isPushNotificationsActive: false,
          billingEmailAddress: email,
        );
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .set(user.toMap());
        if (context.mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute<void>(
                builder: (BuildContext context) => PagesController(
                      indexPage: 2,
                    )),
            ModalRoute.withName('/profile'),
          );
        }
      }
    } on FirebaseException catch (error) {
      if (context.mounted) {
        return Constants.showInSnackBar(
            value: error.toString(), context: context);
      }
    }
  }

  Future<Map<String, dynamic>> getUserData(
      {required BuildContext context,
      required bool mounted,
      required bool isUserExists}) async {
    Map<String, dynamic> userData = {};

    if (isUserExists) {
      try {
        final userId = FirebaseAuth.instance.currentUser?.uid;
        final userGetDoc = await FirebaseFirestore.instance
            .collection('users')
            .where("id", isEqualTo: userId)
            .get();
        if (context.mounted) {
          if (userGetDoc.docs.isNotEmpty) {
            Map<String, dynamic> userDataToMap = userGetDoc.docs.first.data();
            userData.addAll(userDataToMap);
            final userRoleGet = await FirebaseFirestore.instance
                .collection('roles')
                .where("id", isEqualTo: userDataToMap["role"])
                .get();
            if (context.mounted) {
              if (userRoleGet.docs.isNotEmpty) {
                Map<String, dynamic> userRole = userRoleGet.docs.first.data();
                Map<String, dynamic> userRoleAsMap = {"roleData": userRole};
                userData.addAll(userRoleAsMap);
              }
            }
          }
        }
      } on FirebaseFirestore catch (error) {
        if (context.mounted) {
          Constants.showInSnackBar(value: error.toString(), context: context);
        }
      }
    }
    return userData;
  }

// edit UserName firstname and lastname
  Future<void> editUserFullName({
    required userNameUpdateMap,
    required String userId,
    required BuildContext context,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .update(userNameUpdateMap);
    } on FirebaseException catch (error) {
      if (context.mounted) {
        Constants.showInSnackBar(value: error.toString(), context: context);
      }
    }
  }

  // edit UserName
  Future<void> editUserName({
    required userNameUpdateMap,
    required String userId,
    required BuildContext context,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .update(userNameUpdateMap);
    } on FirebaseException catch (error) {
      if (context.mounted) {
        Constants.showInSnackBar(value: error.toString(), context: context);
      }
    }
  }

  bool isUserAlreadyHasGender(
      {required BuildContext context, required Map<String, dynamic> userData}) {
    bool isUserAlreadyHasGender = true;
    if (userData["gender"] == null ||
        userData["gender"] == '' ||
        userData["gender"] == Gender.nothing.toString()) {
      isUserAlreadyHasGender = false;
    }
    return isUserAlreadyHasGender;
  }

  Future<void> saveUserGender(
      {required BuildContext context,
      required String userId,
      required Map<String, dynamic> selectedGenderMap}) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .update(selectedGenderMap);
  }

  Future<void> editUserPhoneNumber(
      {required BuildContext context,
      required String userId,
      required Map<String, dynamic> phoneNumberMap}) async {
    try {
      if (phoneNumberMap.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update(phoneNumberMap);
      }
    } on FirebaseException catch (error) {
      if (context.mounted) {
        Constants.showInSnackBar(
            value: error.message.toString(), context: context);
      }
    }
  }

  // check if email in Firebase to Login
  Future<bool> isUserEmailInFirebase(
      {required BuildContext context, required String emailGet}) async {
    bool isEmailInFirebase = false;
    try {
      final getEmailUserData = await FirebaseFirestore.instance
          .collection('users')
          .where("email", isEqualTo: emailGet)
          .get();
      if (context.mounted) {
        if (getEmailUserData.size == 1) {
          isEmailInFirebase = true;
        }
      }
    } on FirebaseException catch (error) {
      if (context.mounted) {
        Constants.showInSnackBar(
            value: error.message.toString(), context: context);
      }
    }
    return isEmailInFirebase;
  }

// loginUserWithEmailAndPassword
  Future<void> signInWithEmailAndPassword(
      {required BuildContext context,
      required String emailGet,
      required AppLocalizations labels,
      required String passwordGet}) async {
    if (emailGet != '' && passwordGet != '') {
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: emailGet, password: passwordGet);
        if (!context.mounted) return;
        if (userCredential.user != null) {
          final TimeManagementPovider eTMProvider =
              Provider.of<TimeManagementPovider>(context, listen: false);
          TrackingDB db = TrackingDB();
          await eTMProvider.requestForSyncToCloud(
              context: context, isUserExist: true, labels: labels, db: db);
          if (!context.mounted) return;

          if (context.loaderOverlay.visible &&
              eTMProvider.isLokalDataInCloudSync == null &&
              eTMProvider.isLokalDataInCloudSync!) {
            return;
          }
          await Future.delayed(Duration(milliseconds: 500));
          if (!context.mounted) return;
          context.loaderOverlay.hide();

          await Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => PagesController(
                  indexPage: 2,
                ),
              ),
              (route) => route.isFirst);
        }
      } on FirebaseAuthException catch (error) {
        if (context.mounted) {
          Constants.showInSnackBar(
              value: error.message.toString(), context: context);
        }
      }
    }
  }

  // Update Notifications in Firebase
  Future<void> updateNotificationsUser(
      {required BuildContext context,
      required Map<String, dynamic> updatedData,
      required String userId}) async {
    if (updatedData.isNotEmpty) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update(updatedData);
      } on FirebaseException catch (error) {
        if (context.mounted) {
          Constants.showInSnackBar(
              value: error.message.toString(), context: context);
        }
      }
    }
  }

  // check if User Email Verified
  Future<bool> isEmailVerified({required BuildContext context}) async {
    bool isEmailVerifiedCheck = false;
    await FirebaseAuth.instance.currentUser?.reload();
    if (context.mounted) {
      isEmailVerifiedCheck = FirebaseAuth.instance.currentUser!.emailVerified;
    }
    return isEmailVerifiedCheck;
  }

  // send Email for Verification
  Future<void> sendUserVerificationEmail(
      {required BuildContext context}) async {
    try {
      await FirebaseAuth.instance.currentUser?.sendEmailVerification();
      await FirebaseAuth.instance.currentUser?.reload();
    } on FirebaseAuthException catch (error) {
      if (context.mounted) {
        return Constants.showInSnackBar(
            value: error.message.toString(), context: context);
      }
    }
  }

  // Save Email Paypal in Firebase
  Future<void> savePayPalInFirebase({
    required BuildContext context,
    required Map<String, dynamic> userData,
    required Map<String, dynamic> payPalEmailAddress,
  }) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userData["id"])
        .update(payPalEmailAddress);
  }

//  delete PayPal Email From Address
  Future<void> deleteUserPayPalEmail({
    required BuildContext context,
    required Map<String, dynamic> userData,
    required Map<String, dynamic> payPalEmailDelete,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(userData["id"])
          .update(payPalEmailDelete);
    } on FirebaseException catch (error) {
      if (context.mounted) {
        return Constants.showInSnackBar(
            value: error.message.toString(), context: context);
      }
    }
  }

  // logout User
  Future<void> logoutUser({required BuildContext context}) async {
    try {
      await FirebaseAuth.instance.signOut();
      if (!context.mounted) return;
      bool isUserLoginCheck = await isUserLogin(context: context);
      if (!context.mounted) return;
      if (!isUserLoginCheck) {
        await Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => PagesController(
              indexPage: 2,
            ),
          ),
          (route) => route.isFirst,
        );
      }
    } on FirebaseAuthException catch (error) {
      if (context.mounted) {
        Constants.showInSnackBar(
            value: error.message.toString(), context: context);
      }
    }
  }

  // change User password

  //Check the CurrentPassword
  Future<bool> isNoProblemWithEmailOrPassword(
      {required BuildContext context,
      required String email,
      required String password,
      required User user}) async {
    bool? isCurrentPasswordCorrect;

    try {
      AuthCredential credential =
          EmailAuthProvider.credential(email: email, password: password);
      await user.reauthenticateWithCredential(credential);
      isCurrentPasswordCorrect = true;
    } on FirebaseAuthException catch (error) {
      isCurrentPasswordCorrect = false;
      if (context.mounted) {
        if (error.code == "wrong-password") {
          Constants.showInSnackBar(
              value: "Error: Wrong password provided.", context: context);
        } else if (error.code == "invalid-credential") {
          Constants.showInSnackBar(
              value:
                  "Error: The credential is invalid. Double-check the password.",
              context: context);
        }
      }
    }
    return isCurrentPasswordCorrect;
  }

// Change Password
  Future<void> changePassword(
      {required BuildContext context,
      required String newPassword,
      required String email,
      required currentPassword,
      required AppLocalizations labels}) async {
    User? user = FirebaseAuth.instance.currentUser;
    bool isCurrentPasswordCorrect = await isNoProblemWithEmailOrPassword(
        user: user!, context: context, email: email, password: currentPassword);
    if (!context.mounted) return;
    if (!isCurrentPasswordCorrect) return;
    if (currentPassword == newPassword) {
      return Constants.showInSnackBar(
          value: labels.passwordCannotBeSame, context: context);
    }

    await user.updatePassword(newPassword);
    if (!context.mounted) return;
    Navigator.of(context).pop();
  }

  // delete account
  Future<void> deleteUserAccount({
    required BuildContext context,
    required AppLocalizations labels,
  }) async {
    await Constants.showDialogConfirmation(
        context: context,
        onConfirm: () async {
          try {
            await FirebaseAuth.instance.currentUser?.delete();
            if (!context.mounted) return;
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => PagesController(
                  indexPage: 2,
                ),
              ),
              (route) => false,
            );
          } on FirebaseAuthException catch (error) {
            if (context.mounted) {
              Constants.showInSnackBar(value: error.code, context: context);
            }
          }
        },
        title: labels.delete,
        message: labels.deleteAccountConfirmation);
  }

  dynamic otpConfing() {
    EmailOTP();
    EmailOTP.config(
        expiry: 60000,
        appName: "ETM",
        appEmail: "noreply@eyogroup.com",
        otpLength: 5,
        emailTheme: EmailTheme.v7,
        otpType: OTPType.numeric);
    String template = '''

<head>
   <center><h1 style="color: #333;">{{appName}}</h1> </center>
  <style>
    body {
      font-family: Arial, sans-serif;
      background-color: #f4f4f4;
      margin: 0;
      padding: 0;
    }
    .email-container {
      max-width: 600px;
      margin: 30px auto;
      background-color: #ffffff;
      padding: 20px;
      border-radius: 8px;
      box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
    }
    .header {
      font-size: 20px;
      color: #3b5998;
      margin-bottom: 20px;
    }
    .otp {
      font-size: 36px;
      font-weight: bold;
      color: #28a745;
      margin: 20px 0;
    }
    .content {
      font-size: 16px;
      line-height: 1.6;
    }
    .footer {
      margin-top: 20px;
      font-size: 12px;
      color: #666666;
    }
    .footer a {
      color: #3b5998;
      text-decoration: none;
    }
  </style>
</head>
<body>
  <div class="email-container">
    <center><div class="header">Email Verification</div></center>
    <div class="content">
      <p>Dear User,</p>
      <p>Your One-Time Password (Code) is:</p>
      <center><div class="otp">{{otp}}</div></center>
      <p>Please use this code to complete your login process. Do not share this code with anyone.</p>
    </div>
    <center><div class="footer">
      © <a href="https://www.eyogroup.com">www.eyogroup.com</a>. All rights reserved.
    </div></center>
  </div>
</body>

''';
    EmailOTP.setTemplate(template: template);

    EmailOTP.setSMTP(
        emailPort: EmailPort.port465,
        secureType: SecureType.ssl,
        host: "mail.eyogroup.com",
        username: "support@eyogroup.com",
        password: "789456123eyogroup+");
  } // send User password reset per Email

  Future<void> sendUserEmailPasswordReset(
      {required BuildContext context,
      required String emailGet,
      GlobalKey<FormState>? formKey,
      required Map<String, dynamic> userDataGet,
      bool isInit = true}) async {
    try {
      otpConfing();
      bool? res;

      if (userDataGet.isNotEmpty) {
        res = await EmailOTP.sendOTP(email: emailGet);
      } else {
        if (formKey!.currentState!.validate()) {
          await FirebaseAuth.instance.sendPasswordResetEmail(email: emailGet);
        }
      }
      if (isInit) {
        if (res != null && res) {
          if (!context.mounted) return;
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => CheckEmailAfteCodeSended(
              emailGet: emailGet,
              userDataGet: userDataGet,
            ),
          ));
        }
      }
    } on FirebaseAuthException catch (error) {
      if (context.mounted) {
        if (error.code == "auth/user-not-found") {
          Constants.showInSnackBar(value: 'user-not-found', context: context);
        }
      }
    }
  }

  // check if OTP Code valid
  bool isCodeConfirmationValid() {
    return EmailOTP.isOtpExpired();
  }
// confirm OTP Confirmation Code

  void valideCodeConfirmation(
      {required BuildContext context,
      required String codeGet,
      required Map<String, dynamic> userData}) {
    bool isOtpExpired = isCodeConfirmationValid();

    if (!isOtpExpired) {
      bool isCodeValide = EmailOTP.verifyOTP(otp: codeGet);
      if (isCodeValide) {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => CreateNewPasswordUser(userDataGet: userData),
        ));
      }
    } else {
      return Constants.showInSnackBar(
          value: "Code Invalid or Expired. try again", context: context);
    }
  }

  // reset new Password
  Future<void> resetUserPassword(
      {required BuildContext context, required String newpassword}) async {
    try {
      bool isUserLogIn = await isUserLogin(context: context);
      User? user = FirebaseAuth.instance.currentUser;
      if (!context.mounted) return;
      print(isUserLogIn);
      if (user == null) {
        print("No user is logged in.");
        return;
      }
      if (isUserLogIn) {
        await user.updatePassword(newpassword);
      } else {
        //TODO logi not sign In
        final dynamic result = await FirebaseAuth.instance
            .checkActionCode('the_link_from_the_email');
        if (result != null) {}
      }
    } on FirebaseAuthException catch (error) {
      print(error);
      if (context.mounted) {
        Constants.showInSnackBar(
            value: error.message.toString(), context: context);
      }
    }
  }

  initDeep() async {
    late StreamSubscription _linkSubscription;
    final appLinks = AppLinks();
    // Subscribe to uriLinkStream to handle initial and subsequent links
    print(await appLinks.getInitialLink());
    _linkSubscription = appLinks.uriLinkStream.listen((Uri uri) {
      print("Received URI: $uri");

      // Add your navigation logic based on the URI received
      if (uri.path == '/etm/reset-password') {
        // Navigate to the reset password screen if the link is valid
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //       builder: (context) => ResetPasswordScreen(uri: uri)),
        // );
      } else {
        // Handle other URI paths or show error messages
        print('Link does not match expected pattern');
      }
    });

    // Also handle the first link on app launch
    await initDeepLinks();
  }

  Future<void> initDeepLinks() async {
    final appLinks = AppLinks();
    final Uri? uri = Uri.base;
    print(uri);
    Uri? initialLink = await appLinks.getInitialLink();
    if (initialLink != null) {
      print("Initial link: $initialLink");
      // Navigate based on the initial deep link
      if (initialLink.path == '/etm/reset-password') {
        print('he');
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(builder: (context) => ResetPasswordScreen(uri: initialLink)),
        // );
      }
    }
  }
}
