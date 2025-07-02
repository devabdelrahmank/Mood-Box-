import 'package:flutter/material.dart';
import 'package:movie_proj/core/my_images.dart';
import 'package:movie_proj/core/my_styles.dart';
import 'package:movie_proj/core/my_text.dart';
import 'package:movie_proj/core/spacing.dart';
import 'package:movie_proj/feature/auth/widget/login_end.dart';
import 'package:movie_proj/feature/auth/widget/login_pass_email.dart';

class LoginScreenBody extends StatefulWidget {
  const LoginScreenBody({super.key});

  @override
  State<LoginScreenBody> createState() => _LoginScreenBodyState();
}

class _LoginScreenBodyState extends State<LoginScreenBody> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        height: 670,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: const DecorationImage(
            image: AssetImage(MyImages.background),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Container(
            width: 400,
            height: 600,
            decoration: BoxDecoration(
              color: const Color(0xff141412),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    MyText.hiThere,
                    style: MyStyles.title24White400.copyWith(fontSize: 18),
                  ),
                  Text(
                    MyText.howAbout,
                    style: MyStyles.title24White400
                        .copyWith(fontSize: 12, color: const Color(0xff969696)),
                  ),
                  vSpace(20),
                  const LoginPassAndEmail(),
                  vSpace(10),
                  const LoginEnd()
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
