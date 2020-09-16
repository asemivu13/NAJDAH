import 'package:flutter/material.dart';
import 'text_field_container.dart';
import 'package:najdah/constants.dart';
class RoundedInputField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final TextEditingController controller;
  final validator;
  final keyboardType;
  final inputFormatters;

  const RoundedInputField({
    Key key,
    this.hintText,
    this.icon = Icons.person,
    this.onChanged,
    this.controller,
    this.validator,
    this.keyboardType,
    this.inputFormatters
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFieldContainer(
      child: TextFormField(
        onChanged: onChanged,
        cursorColor: kPrimaryColor,
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          icon: Icon(
            icon,
            color: kPrimaryColor,
          ),
          hintText: hintText,
          border: InputBorder.none,
        ),
      ),
    );
  }
}