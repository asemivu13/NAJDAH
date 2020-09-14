import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:najdah/screens/register.dart';
import 'package:najdah/services/auth.dart';

void main() {
  runApp(MaterialApp(
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
            return Container();
          }
          if (snapshot.connectionState == ConnectionState.done) {
            return MaterialApp(
                home: LoginScreen());
          } else {
            return MaterialApp(
              home: Scaffold(
                body: Center(
                  child: Text(
                      "Loading"
                  ),
                ),
              ),
            );
          }
        }
    );
  }
}

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
    // Validation for email and password
    const String EMAIL_PATTERN = r'(^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$)';
    RegExp emailRegExp = new RegExp(EMAIL_PATTERN);
    const String PASSWORD_PATTERN = r'(^(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[a-zA-Z]).{6,}$)';
    RegExp passwordRegExp = new RegExp(PASSWORD_PATTERN);
    // Building Login Form
    return Scaffold(
      body: Container(
        margin: EdgeInsets.all(20),
        child: Center(
          child: Form(
            key: _loginKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              
            children: <Widget>[
              Text(
                "Login",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 23,
                ),
              ),
              TextFormField(
                controller: _emailController,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Enter Your Email';
                  } else if (!emailRegExp.hasMatch(value)) {
                    return 'Enter a vaild Email';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'Email',
                ),
              ),
              TextFormField(
                controller: _passwordController,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Enter Your Password';
                  } else if (!passwordRegExp.hasMatch(value)) {
                    return 'Enter a valid password. A vaild password must have at least 6 characters and a letter and number';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'Password',
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: OutlineButton(
                  onPressed: () {
                    // Validate returns true if the form is valid, or false
                    // otherwise.
                    if (_loginKey.currentState.validate()) {
                      login ();
                    }
                  },
                  child: Text('Login', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                  borderSide: BorderSide(color: Colors.lightBlue),
                ),
              ),
              Text(
                _success == null ? '' : (_success ? '' : 'Login Failed')
              ),
              FlatButton(
                child: Text(
                  "Create Account"
                ),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(
                      builder: (BuildContext context) {
                        return RegisterScreen ();
                      }
                  ));
                },
              )
            ],
          ),
        ),
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