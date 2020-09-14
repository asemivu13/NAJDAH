import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class Auth {
  final FirebaseAuth auth = FirebaseAuth.instance;

  // Login
  Future login (String email, String password) async {
    UserCredential result;
    try {
      result = await auth.signInWithEmailAndPassword(email: email, password: password);
      return result;
    } catch (error) {
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
}