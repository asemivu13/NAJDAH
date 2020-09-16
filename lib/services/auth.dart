import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:najdah/screens/home_page.dart';
class Auth {
  final FirebaseAuth auth = FirebaseAuth.instance;
  String errorCode = '';
  BuildContext context;
  // Login
  Future<UserCredential> login (String email, String password) async {
    UserCredential result;
    try {
      result = await auth.signInWithEmailAndPassword(email: email, password: password);
      return result;
    } on FirebaseAuthException catch (error) {
      if (error.code == 'user-not-found') {
        errorCode = 'No user found for that email.';
      } else if (error.code == 'wrong-password') {
        errorCode = 'Wrong password.';
      }
      return result;
    }

  }
  // Register
  Future<UserCredential> register (String fullName, String email, String password, int phoneNumber) async {
    UserCredential result;
    try {
      result = await auth.createUserWithEmailAndPassword(email: email, password: password);
      GeoPoint emptyPoint = new GeoPoint(0, 0);
      await FirebaseFirestore.instance.collection('users').doc(auth.currentUser.uid).set({
        'name': fullName,
        'phone_number': phoneNumber,
        'location': emptyPoint,
      });
      return result;
    } on FirebaseAuthException catch (error) {
      if (error.code == 'email-already-in-use') {
        errorCode = 'This Email is already in use.';
      } else if (error.code == 'weak-password') {
        errorCode = 'Weak Password, make it stronger';
      } else if (error.code == 'error-invalid-password'){
        errorCode = 'Problem with Email';
      }
      return result;
    }
  }
  // Sign Out
  Future<void> signOut () async {
    try {
      await auth.signOut();
    } catch (e) {
      print (e);
    }
  }
  Future<User> getCurrentUser() async {
    return auth.currentUser;
  }
}