import 'package:flutter/material.dart';
import 'package:movie_proj/core/my_styles.dart';
import 'package:movie_proj/core/my_text_field.dart';
import 'package:movie_proj/core/spacing.dart';

class TextFieldWithName extends StatelessWidget {
  final Widget? suffixWidget;
  final String text;
  final bool obscureText;
  final void Function()? onTap;
  final String? Function(String?)? validator;
  final TextEditingController controller;

  const TextFieldWithName({
    super.key,
    this.suffixWidget,
    required this.text,
    this.obscureText = false,
    this.onTap,
    required this.validator,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: MyStyles.title24White400.copyWith(fontSize: 13),
        ),
        vSpace(10),
        CustomTextField(
          text: '',
          textAlign: TextAlign.start,
          keyboardType: TextInputType.emailAddress,
          controller: controller,
          onTap: onTap,
          validator: validator,
          obscureText: obscureText,
          suffix: suffixWidget,
        ),
        vSpace(15),
      ],
    );
  }
}
