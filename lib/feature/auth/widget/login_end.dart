import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:movie_proj/core/my_colors.dart';
import 'package:movie_proj/core/my_images.dart';
import 'package:movie_proj/core/my_styles.dart';
import 'package:movie_proj/core/my_text.dart';
import 'package:movie_proj/core/spacing.dart';
import 'package:movie_proj/feature/auth/manage/auth_cubit.dart';
import 'package:movie_proj/feature/auth/manage/auth_state.dart';
import 'package:movie_proj/feature/auth/widget/my_text_btns.dart';
import 'package:movie_proj/feature/auth/widget/social_btn.dart';
import 'package:movie_proj/feature/auth/signup_screen.dart';
import 'package:movie_proj/main_navigation_screen.dart';

class LoginEnd extends StatefulWidget {
  const LoginEnd({super.key});

  @override
  State<LoginEnd> createState() => _AuthEndState();
}

class _AuthEndState extends State<LoginEnd> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    final authCubit = BlocProvider.of<AuthCubit>(context);

    return BlocConsumer<AuthCubit, AuthStates>(
      listener: (context, state) {
        try {
          if (state is LogInUserSuccessState) {
            // Check if email is verified before navigating
            final user = FirebaseAuth.instance.currentUser;
            if (user != null && user.emailVerified) {
              // Clear form fields
              authCubit.emailController.clear();
              authCubit.passwordController.clear();

              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Login successful!'),
                  backgroundColor: Colors.green,
                ),
              );

              // Navigate to main screen
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const MainNavigationScreen(),
                ),
              );
            } else {
              // Email not verified - sign out and show message
              FirebaseAuth.instance.signOut();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                    'Please verify your email before logging in. Check your inbox for the verification link.',
                  ),
                  backgroundColor: Colors.orange,
                  duration: const Duration(seconds: 5),
                  action: SnackBarAction(
                    label: 'Resend',
                    textColor: Colors.white,
                    onPressed: () {
                      authCubit.sendEmailVerification(context);
                    },
                  ),
                ),
              );
            }
          } else if (state is LogInUserErrorState) {
            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Login failed. Please check your credentials.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } catch (e) {
          debugPrint('Error in login listener: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('An unexpected error occurred during login'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        return Column(
          children: [
            Row(
              children: [
                Checkbox(
                  activeColor: MyColors.btnColor,
                  value: isChecked,
                  onChanged: (value) {
                    setState(() {
                      isChecked = value!;
                    });
                  },
                ),
                Text(
                  MyText.rememberMe,
                  style: MyStyles.title24White400.copyWith(fontSize: 12),
                ),
                const Spacer(),
                state is LogInUserLoadingState
                    ? Container(
                        width: 80,
                        height: 35,
                        decoration: BoxDecoration(
                          color: MyColors.btnColor.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Center(
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                      )
                    : MyTextBtn(
                        onTap: () {
                          if (authCubit.formKeyLogIN.currentState!.validate()) {
                            authCubit.loginUsers(
                              email: authCubit.emailController.text.trim(),
                              password: authCubit.passwordController.text,
                              context: context,
                            );
                          }
                        },
                        text: MyText.login,
                        color: MyColors.btnColor,
                        textColor: Colors.white,
                        radius: 20,
                      )
              ],
            ),
            Center(
              child: Text(
                MyText.or,
                style: MyStyles.title24White400.copyWith(fontSize: 12),
              ),
            ),
            dSpace(),
            vSpace(10),
            const SocialBtn(
              color: Color(0xff1877F2),
              textColor: Colors.white,
              imagePath: MyImages.facebookLogo,
              radius: 20,
              width: double.infinity,
              text: MyText.facebook,
            ),
            vSpace(10),
            const SocialBtn(
              color: Colors.black,
              textColor: Colors.white,
              imagePath: MyImages.appleLogo,
              radius: 20,
              width: double.infinity,
              text: MyText.apple,
            ),
            vSpace(5),
            dSpace(),
            Center(
              child: Text(
                MyText.dontHaveAccount,
                style: MyStyles.title24White400.copyWith(fontSize: 12),
              ),
            ),
            vSpace(10),
            MyTextBtn(
              onTap: () {
                // Clear form fields when navigating to signup
                authCubit.emailController.clear();
                authCubit.passwordController.clear();
                authCubit.nameController.clear();
                authCubit.confirmPasswordController.clear();

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SignupScreen(),
                  ),
                );
              },
              text: MyText.signupFor,
              color: MyColors.btnColor,
              textColor: Colors.white,
              width: double.infinity,
              radius: 20,
            ),
          ],
        );
      },
    );
  }
}
