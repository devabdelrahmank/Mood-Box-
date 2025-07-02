import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_proj/core/my_colors.dart';
import 'package:movie_proj/core/my_styles.dart';
import 'package:movie_proj/core/my_text.dart';
import 'package:movie_proj/core/spacing.dart';
import 'package:movie_proj/feature/auth/manage/auth_cubit.dart';
import 'package:movie_proj/feature/auth/manage/auth_state.dart';
import 'package:movie_proj/feature/auth/widget/my_text_btns.dart';

class SignupEnd extends StatefulWidget {
  const SignupEnd({super.key});

  @override
  State<SignupEnd> createState() => _SignupEndState();
}

class _SignupEndState extends State<SignupEnd> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    final authCubit = BlocProvider.of<AuthCubit>(context);

    return BlocConsumer<AuthCubit, AuthStates>(
      listener: (context, state) {
        try {
          if (state is SignUpUserSuccessState) {
            // Clear form fields
            authCubit.nameController.clear();
            authCubit.emailController.clear();
            authCubit.passwordController.clear();
            authCubit.confirmPasswordController.clear();

            // Show email verification message with resend option
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                    'Account created! Please check your email to verify your account before logging in.'),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 8),
                action: SnackBarAction(
                  label: 'Resend Email',
                  textColor: Colors.white,
                  onPressed: () {
                    authCubit.sendEmailVerification(context);
                  },
                ),
              ),
            );

            // Navigate back to login screen instead of main screen
            Navigator.pop(context);
          } else if (state is SignUpUserErrorState) {
            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: Colors.red,
              ),
            );
          }
        } catch (e) {
          debugPrint('Error in signup listener: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('An unexpected error occurred'),
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
                Expanded(
                  child: Text(
                    'I agree to the Terms & Conditions',
                    style: MyStyles.title24White400.copyWith(fontSize: 12),
                  ),
                ),
              ],
            ),
            vSpace(8),
            state is SignUpUserLoadingState
                ? Container(
                    width: double.infinity,
                    height: 35,
                    decoration: BoxDecoration(
                      color: MyColors.btnColor.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                  )
                : MyTextBtn(
                    onTap: () {
                      if (!isChecked) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Please agree to the Terms & Conditions'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                        return;
                      }

                      if (authCubit.formKeySignup.currentState!.validate()) {
                        authCubit.userSignUp(
                          email: authCubit.emailController.text.trim(),
                          password: authCubit.passwordController.text,
                          name: authCubit.nameController.text.trim(),
                          image: authCubit.selectedProfileImage,
                          context: context,
                        );
                      }
                    },
                    text: MyText.signup,
                    color: MyColors.btnColor,
                    textColor: Colors.white,
                    width: double.infinity,
                    radius: 20,
                  ),
            vSpace(12),
            Center(
              child: Text(
                MyText.or,
                style: MyStyles.title24White400.copyWith(fontSize: 12),
              ),
            ),
            vSpace(8),

            Center(
              child: Text(
                'Already have an account?',
                style: MyStyles.title24White400.copyWith(fontSize: 12),
              ),
            ),
            vSpace(8),
            MyTextBtn(
              onTap: () {
                // Clear form fields when navigating back to login
                authCubit.emailController.clear();
                authCubit.passwordController.clear();
                authCubit.nameController.clear();
                authCubit.confirmPasswordController.clear();

                Navigator.pop(context);
              },
              text: MyText.login,
              color: MyColors.btnColor,
              textColor: Colors.white,
              width: double.infinity,
              radius: 20,
            ),
            vSpace(8),
            // Test email verification button (for debugging)
            if (kDebugMode)
              MyTextBtn(
                onTap: () {
                  authCubit.testEmailVerification();
                },
                text: 'Test Email Verification',
                color: Colors.blue,
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
