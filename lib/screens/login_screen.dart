import 'package:flutter/material.dart';
import 'package:najdah/Design/already_have_account.dart';
import 'package:najdah/screens/register.dart';
import 'package:najdah/services/auth.dart';
import 'package:najdah/Design/rounded_button.dart';
import 'package:najdah/Design/rounded_password_field.dart';
import 'package:najdah/Design/rounded_input_field.dart';

import 'home_page.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LoginScreenState();

}
class _LoginScreenState extends State <LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _loginKey = GlobalKey<FormState>();
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
              SizedBox(height: size.height * 0.25),
              Text(
                "LOGIN",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
              ),
              SizedBox(height: size.height * 0.03),
              SizedBox(height: size.height * 0.03),
              RoundedInputField(
                hintText: "Email",
                onChanged: (value) {},
              ),
              RoundedPasswordField(
                onChanged: (value) {},
              ),
              RoundedButton(
                text: "LOGIN",
                press: () {},
              ),
              SizedBox(height: size.height * 0.03),
              AlreadyHaveAnAccountCheck(
                press: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return RegisterScreen();
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

  void login () async {
    var result = await serviceAuth.login(
        _emailController.value.text,
        _passwordController.value.text
    );
    if (result != null) {
      Navigator.push(context, MaterialPageRoute(
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