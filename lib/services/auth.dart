import 'package:firebase_auth/firebase_auth.dart';

class Auth {
  final FirebaseAuth auth = FirebaseAuth.instance;

  // Login
  Future<UserCredential> login (String email, String password) async {
    UserCredential result;
    try {
      result = await auth.signInWithEmailAndPassword(email: email, password: password);
      return result;
    } catch (error) {
      return result;
    }

  }
  // Register
  Future<UserCredential> register (String fullName, String email, String password, int phoneNumber) async {
    UserCredential result;
    try {
      result = await auth.createUserWithEmailAndPassword(email: email, password: password);
      print ("$fullName + $email + $password + $phoneNumber");
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
  Future<User> getCurrentUser() async {
    return auth.currentUser;
  }
}