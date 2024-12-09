import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:time_management/Navigation%20Pages/pagination.dart';
import 'package:time_management/constants.dart';
import 'package:time_management/controller/user.dart';
import 'package:uuid/uuid.dart';

class UserProvider extends ChangeNotifier {
  Future<bool> isUserLogin({required BuildContext context}) async {
    bool isUserIn = true;
    await FirebaseAuth.instance.currentUser?.reload();
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
            userData = userGetDoc.docs.first.data();
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
    if (userData["gender"] == null || userData["gender"] == '') {
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
}
