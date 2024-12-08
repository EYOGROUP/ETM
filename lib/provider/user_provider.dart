import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:time_management/Navigation%20Pages/pagination.dart';
import 'package:time_management/constants.dart';
import 'package:time_management/controller/user.dart';
import 'package:uuid/uuid.dart';

class UserProvider extends ChangeNotifier {
  bool isUserLogin() {
    bool isUserIn = true;
    final currentUser = FirebaseAuth.instance.currentUser?.isAnonymous;
    if (currentUser == null) {
      isUserIn = false;
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
      String? phoneNumber,
      String? phoneCountryCode}) async {
    try {
      bool isUserRegistred =
          await signUpUser(context: context, email: email, password: password);
      if (!mounted) return;
      if (isUserRegistred) {
        var userId = const Uuid().v4();
        ETMUser user = ETMUser(
            id: userId,
            firstName: firstName,
            lastName: lastName,
            email: email,
            phoneCountryCode: phoneCountryCode ?? '',
            phoneNumber: phoneNumber ?? '',
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
}
