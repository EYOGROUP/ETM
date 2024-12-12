import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:time_management/Navigation%20Pages/pagination.dart';
import 'package:time_management/constants.dart';
import 'package:time_management/controller/user.dart';
import 'package:time_management/provider/tm_provider.dart';
import 'package:uuid/uuid.dart';

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
            role: 'soon',
            createdAt: DateTime.now(),
            notificationsEnabled: false);
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
      required String passwordGet}) async {
    if (emailGet != '' && passwordGet != '') {
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: emailGet, password: passwordGet);
        if (!context.mounted) return;
        if (userCredential.user != null) {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => PagesController(
              indexPage: 2,
            ),
          ));
        }
      } on FirebaseAuthException catch (error) {
        Constants.showInSnackBar(
            value: error.message.toString(), context: context);
      }
    }
  }
}
