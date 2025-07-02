import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_proj/core/my_colors.dart';
import 'package:movie_proj/core/shared/shared_pref.dart';
import 'package:movie_proj/core/spacing.dart';
import 'package:movie_proj/core/widget/movie_app_bar.dart';
import 'package:movie_proj/feature/auth/manage/auth_cubit.dart';
import 'package:movie_proj/feature/profile/widget/profile_header.dart';
import 'package:movie_proj/feature/profile/widget/profile_menu.dart';
import 'package:movie_proj/feature/profile/widget/profile_movies.dart';

class ProfileScreen extends StatefulWidget {
  final Function(int) onNavigate;

  const ProfileScreen({
    super.key,
    required this.onNavigate,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    final authCubit = context.read<AuthCubit>();
    final uIdUser = CacheHelper.getString(key: 'uIdUser0');

    if (uIdUser != null && uIdUser.isNotEmpty && authCubit.userModel == null) {
      await authCubit.getUserData(uIdUser);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = _getHorizontalPadding(screenWidth);
    final verticalSpacing = _getVerticalSpacing(screenWidth);

    return Scaffold(
      backgroundColor: MyColors.primaryColor,
      appBar: MovieAppBar(
        currentIndex: 4,
        onNavigate: widget.onNavigate,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: _getMaxContainerWidth(screenWidth),
                ),
                child: Stack(
                  alignment: AlignmentDirectional.bottomCenter,
                  children: [
                    const ProfileHeader(),

                    //هخفيهه
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: _getMenuMargin(screenWidth),
                        ),
                        child: const ProfileMenu(),
                      ),
                    ),
                  ],
                ),
              ),
              vSpace(verticalSpacing),
              Container(
                constraints: BoxConstraints(
                    // maxWidth: _getMaxContainerWidth(screenWidth),
                    ),
                child: Column(
                  children: [
                    vSpace(verticalSpacing / 2),
                    const ProfileMovies(),
                  ],
                ),
              ),
              vSpace(verticalSpacing),
            ],
          ),
        ),
      ),
    );
  }

  double _getHorizontalPadding(double width) {
    if (width <= 400) return 12;
    if (width <= 600) return 20;
    if (width <= 900) return 30;
    return 40;
  }

  double _getVerticalSpacing(double width) {
    if (width <= 400) return 24;
    if (width <= 600) return 30;
    if (width <= 900) return 40;
    return 50;
  }

  double _getMaxContainerWidth(double width) {
    if (width <= 900) return width;
    return 1200;
  }

  double _getMenuMargin(double width) {
    if (width <= 400) return 8;
    if (width <= 600) return 16;
    if (width <= 900) return 24;
    return 32;
  }
}
