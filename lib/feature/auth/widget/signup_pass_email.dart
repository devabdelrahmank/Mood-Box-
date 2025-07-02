import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_proj/core/my_text.dart';
import 'package:movie_proj/core/spacing.dart';
import 'package:movie_proj/feature/auth/manage/auth_cubit.dart';
import 'package:movie_proj/feature/auth/manage/auth_state.dart';
import 'package:movie_proj/feature/auth/widget/profile_picture_selector.dart';
import 'package:movie_proj/feature/auth/widget/text_field_with_name.dart';

class SignupPassAndEmail extends StatelessWidget {
  const SignupPassAndEmail({super.key});

  @override
  Widget build(BuildContext context) {
    final authCubit = BlocProvider.of<AuthCubit>(context);

    return Form(
      key: authCubit.formKeySignup,
      child: Column(
        children: [
          TextFieldWithName(
            text: MyText.name,
            validator: (value) {
              if (value!.isEmpty) {
                return 'Name is required';
              }
              if (value.length < 2) {
                return 'Name must be at least 2 characters';
              }
              return null;
            },
            controller: authCubit.nameController,
          ),
          TextFieldWithName(
            text: MyText.emailAddress,
            validator: (value) {
              if (value!.isEmpty) {
                return 'Email is required';
              }
              return authCubit.isEmailValid(value);
            },
            controller: authCubit.emailController,
          ),
          BlocBuilder<AuthCubit, AuthStates>(
            builder: (context, state) {
              return TextFieldWithName(
                text: MyText.password,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Password is required';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
                controller: authCubit.passwordController,
                obscureText: authCubit.isPasswordInVisible,
                suffixWidget: IconButton(
                  onPressed: () {
                    authCubit.changePasswordVisibility();
                  },
                  icon: Icon(
                    authCubit.suffixIcon,
                    color: Colors.grey,
                  ),
                ),
              );
            },
          ),
          BlocBuilder<AuthCubit, AuthStates>(
            builder: (context, state) {
              return TextFieldWithName(
                text: 'Confirm Password',
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please confirm your password';
                  }
                  if (value != authCubit.passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
                controller: authCubit.confirmPasswordController,
                obscureText: authCubit.isRetypePasswordInVisible,
                suffixWidget: IconButton(
                  onPressed: () {
                    authCubit.changeReTypePasswordVisibility();
                  },
                  icon: Icon(
                    authCubit.retypePasswordSuffixIcon,
                    color: Colors.grey,
                  ),
                ),
              );
            },
          ),

          vSpace(20),

          // Profile Picture Selector
          const ProfilePictureSelector(),
        ],
      ),
    );
  }
}
