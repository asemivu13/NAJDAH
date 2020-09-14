import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:najdah/main.dart';
import 'package:najdah/screens/home_page.dart';
import 'package:najdah/services/auth.dart';
import 'dart:async';

class Checker extends StatelessWidget {
  bool isLoding = false;
  @override
  Widget build(BuildContext context) {
    Auth serviceAuth = new Auth();
    return FutureBuilder<User>(
      future: serviceAuth.getCurrentUser(),
      builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) { // user is not null go to the user page
            User user = snapshot.data;
            return HomePage();
          } else {
            return LoginScreen();
          }
        } else {
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: Text("Loading..."),
              ),
            ),
          );
        }
      }
    );
  }
}
