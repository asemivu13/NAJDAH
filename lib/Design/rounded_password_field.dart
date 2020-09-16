import 'package:flutter/material.dart';
import 'package:najdah/constants.dart';
import 'text_field_container.dart';
class RoundedPasswordField extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final TextEditingController controller;
  final validator;
  const RoundedPasswordField({
    Key key,
    this.onChanged,
    this.controller,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFieldContainer(
      child: TextFormField(
        obscureText: true,
        onChanged: onChanged,
        cursorColor: kPrimaryColor,
        validator: validator,
        controller: controller,
        decoration: InputDecoration(
          hintText: "Password",
          icon: Icon(
            Icons.vpn_key,
            color: kPrimaryColor,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }
}