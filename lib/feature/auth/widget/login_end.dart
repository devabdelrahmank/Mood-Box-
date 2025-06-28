import 'package:flutter/material.dart';
import 'package:movie_proj/core/my_colors.dart';
import 'package:movie_proj/core/my_images.dart';
import 'package:movie_proj/core/my_styles.dart';
import 'package:movie_proj/core/my_text.dart';
import 'package:movie_proj/core/spacing.dart';
import 'package:movie_proj/feature/auth/widget/my_text_btns.dart';
import 'package:movie_proj/feature/auth/widget/social_btn.dart';
import 'package:movie_proj/feature/main/main_navigation_screen.dart';

class LoginEnd extends StatefulWidget {
  const LoginEnd({super.key});

  @override
  State<LoginEnd> createState() => _AuthEndState();
}

class _AuthEndState extends State<LoginEnd> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
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
            MyTextBtn(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MainNavigationScreen(),
                  ),
                );
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
          text: MyText.facebook,
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
          onTap: () {},
          text: MyText.signupFor,
          color: MyColors.btnColor,
          textColor: Colors.white,
          width: double.infinity,
          radius: 20,
        ),
      ],
    );
  }
}
