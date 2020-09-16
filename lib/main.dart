import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:najdah/error.dart';
import 'package:najdah/screens/home_page.dart';
import 'package:najdah/screens/register.dart';
import 'package:najdah/services/auth.dart';
import 'package:najdah/services/checker.dart';
import 'package:najdah/constants.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Maintainer(),
  ));
}
class Maintainer extends StatefulWidget {
  @override
  State<Maintainer> createState() => _MaintainerState();
}

class _MaintainerState extends State<Maintainer> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Firebase.initializeApp(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return SomethingWentWrong();
          }
          if (snapshot.connectionState == ConnectionState.done) {
            return Checker();
          }
          return MaterialApp(home: Scaffold(body: Center(child: const Text("Lodaing..."),),));
        }
    );
  }
}