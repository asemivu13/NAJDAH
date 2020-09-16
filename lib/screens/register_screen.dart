import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:najdah/Design/already_have_account.dart';
import 'package:najdah/screens/login_screen.dart';
import 'package:najdah/services/auth.dart';
import 'package:najdah/Design/rounded_button.dart';
import 'package:najdah/Design/rounded_password_field.dart';
import 'package:najdah/Design/rounded_input_field.dart';
import 'package:najdah/constants.dart';
import 'home_page.dart';
class RegisterScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _RegisterScreenState();

}
class _RegisterScreenState extends State <RegisterScreen> {
  final TextEditingController _fullnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  RegExp emailRegExp = new RegExp(EMAIL_PATTERN);
  RegExp passwordRegExp = new RegExp(PASSWORD_PATTERN);
  RegExp phoneRegExp = new RegExp(PHONE_PATTERN);
  final _registerKey = GlobalKey<FormState>();
  bool _success;
  Auth serviceAuth = new Auth();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    // Building Login Form
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: size.height * 0.14),
            Text(
              "REGISTER",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
            ),
            Form(
              key: _registerKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: size.height * 0.03),
                  SizedBox(height: size.height * 0.03),
                  RoundedInputField(
                    controller: _fullnameController,
                    hintText: "Full Name",
                    onChanged: (value) {},
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Enter Your Name';
                      } else if (value.length < 4) {
                        return 'Enter a valid name';
                      }
                      return null;
                    },
                  ),
                  RoundedInputField(
                    controller: _emailController,
                    hintText: "Email",
                    onChanged: (value) {},
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Enter Your Email';
                      } else if (!emailRegExp.hasMatch(value)) {
                        return 'Enter a vaild Email';
                      }
                      return null;
                    },
                  ),
                  RoundedPasswordField(
                    onChanged: (value) {},
                    controller: _passwordController,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Enter Your Password';
                      } else if (!passwordRegExp.hasMatch(value)) {
                        return 'A vaild password must have at least \n 6 characters 1 capital letter, 1 number';
                      }
                      return null;
                    },
                  ),
                  RoundedInputField(
                    controller: _phoneNumberController,
                    hintText: "Phone Number",
                    onChanged: (value) {},
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Enter Your Phone Number';
                      } else if (!phoneRegExp.hasMatch(value)) {
                        return 'Enter a vaild phone number';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly
                    ],
                  ),
                  Text(
                    _success == null ? '' : (_success ? '' : serviceAuth.errorCode),
                    style: TextStyle(color: Colors.red),
                  ),
                  RoundedButton(
                    text: "REGISTER",
                    press: () {
                      if (_registerKey.currentState.validate()) {
                        register ();
                      }
                    },
                  ),
                  SizedBox(height: size.height * 0.03),
                ],
              ),
            ),
            AlreadyHaveAnAccountCheck(
              login: false,
              press: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return LoginScreen();
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void register () async {
    var result = await serviceAuth.register(
        _fullnameController.value.text,
        _emailController.value.text,
        _passwordController.value.text,
        int.parse(_phoneNumberController.value.text)
    );
    if (result != null) {
      User user = await serviceAuth.getCurrentUser();
      Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (BuildContext context) {
            return HomePage ();
          }
      ));
      setState(() {
        _success = true;
      });
    } else {
      setState(() {
        _success = false;
      });
    }
  }


}