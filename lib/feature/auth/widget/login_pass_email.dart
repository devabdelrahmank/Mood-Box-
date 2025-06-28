import 'package:flutter/material.dart';
import 'package:movie_proj/core/my_text.dart';

import 'package:movie_proj/feature/auth/widget/text_field_with_name.dart';

class LoginPassAndEmail extends StatelessWidget {
  const LoginPassAndEmail({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFieldWithName(
          text: MyText.emailAddress,
          validator: (value) {
            if (value!.isEmpty) {
              return 'Email is required';
            }
            return null;
          },
          controller: TextEditingController(),
        ),
        TextFieldWithName(
          text: MyText.password,
          validator: (value) {
            if (value!.isEmpty) {
              return 'Password is required';
            }
            return null;
          },
          controller: TextEditingController(),
          obscureText: true,
        ),
      ],
    );
  }
}
