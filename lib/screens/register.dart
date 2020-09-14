// Building Register Screen
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:najdah/services/auth.dart';



class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _fullnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

  final _registerKey = GlobalKey<FormState>();
  bool _success;
  Auth serviceAuth = new Auth();

  @override
  Widget build(BuildContext context) {
    const String EMAIL_PATTERN = r'(^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$)';
    RegExp emailRegExp = new RegExp(EMAIL_PATTERN);
    const String PASSWORD_PATTERN = r'(^(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[a-zA-Z]).{6,}$)';
    RegExp passwordRegExp = new RegExp(PASSWORD_PATTERN);
    const String PHONE_PATTERN = r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$';
    RegExp phoneRegExp = new RegExp(PHONE_PATTERN);
    return MaterialApp(
      home: Scaffold(
        body: Container(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Form(
              key: _registerKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,

                  children: <Widget>[
                    Text(
                      "Register",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 23,
                      ),
                    ),
                    TextFormField(
                      controller: _fullnameController,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Enter Your Name';
                        } else if (value.length < 4) {
                          return 'Enter You First Name and Your Last Name';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Full Name',
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
                          return 'A vaild password must have at least 6 characters, 1 capital letter, 1 number';
                        }
                        return null;
                      },
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                      ),
                    ),
                    TextFormField(
                      controller: _phoneNumberController,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Enter Your Phone Number';
                        } else if (!phoneRegExp.hasMatch(value)) {
                          return 'You Must Enter a vaild Phone number';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: OutlineButton(
                        onPressed: () {
                          // Validate returns true if the form is valid, or false
                          // otherwise.
                          if (_registerKey.currentState.validate()) {
                            register ();
                          }
                        },
                        child: Text('Register', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                        borderSide: BorderSide(color: Colors.lightBlue),
                      ),
                    ),
                    Text(
                        _success == null ? '' : (_success ? '' : 'Register Failed')
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
              )
            ),
          ),
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
