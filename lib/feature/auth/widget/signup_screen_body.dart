import 'package:flutter/material.dart';
import 'package:movie_proj/core/my_images.dart';
import 'package:movie_proj/core/my_styles.dart';
import 'package:movie_proj/core/spacing.dart';
import 'package:movie_proj/feature/auth/widget/signup_end.dart';
import 'package:movie_proj/feature/auth/widget/signup_pass_email.dart';

class SignupScreenBody extends StatefulWidget {
  const SignupScreenBody({super.key});

  @override
  State<SignupScreenBody> createState() => _SignupScreenBodyState();
}

class _SignupScreenBodyState extends State<SignupScreenBody> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        height: 750, // Increased height for additional fields
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
            height: 700, // Increased height for additional fields
            decoration: BoxDecoration(
              color: const Color(0xff141412),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome!',
                      style: MyStyles.title24White400.copyWith(fontSize: 18),
                    ),
                    Text(
                      'Create your account to get started',
                      style: MyStyles.title24White400.copyWith(
                          fontSize: 12, color: const Color(0xff969696)),
                    ),
                    vSpace(15),
                    const SignupPassAndEmail(),
                    vSpace(5),
                    const SignupEnd()
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
