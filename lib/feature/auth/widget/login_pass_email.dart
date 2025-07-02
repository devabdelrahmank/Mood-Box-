import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_proj/core/my_text.dart';
import 'package:movie_proj/feature/auth/manage/auth_cubit.dart';
import 'package:movie_proj/feature/auth/manage/auth_state.dart';
import 'package:movie_proj/feature/auth/widget/text_field_with_name.dart';

class LoginPassAndEmail extends StatelessWidget {
  const LoginPassAndEmail({super.key});

  @override
  Widget build(BuildContext context) {
    final authCubit = BlocProvider.of<AuthCubit>(context);

    return Form(
      key: authCubit.formKeyLogIN,
      child: Column(
        children: [
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
        ],
      ),
    );
  }
}
