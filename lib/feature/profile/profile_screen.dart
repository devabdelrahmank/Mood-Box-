import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_proj/core/my_colors.dart';
import 'package:movie_proj/core/my_styles.dart';
import 'package:movie_proj/core/shared/shared_pref.dart';
import 'package:movie_proj/core/spacing.dart';
import 'package:movie_proj/feature/auth/login_screen.dart';
import 'package:movie_proj/feature/auth/manage/auth_cubit.dart';
import 'package:movie_proj/feature/auth/manage/auth_state.dart';
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
    _checkAuthenticationAndNavigate();
  }

  void _checkAuthenticationAndNavigate() async {
    final uIdUser = CacheHelper.getString(key: 'uIdUser0');

    if (uIdUser != null && uIdUser.isNotEmpty) {
      // User is authenticated, load user data and stay on profile
      _loadUserData();
    } else {
      // User is not authenticated, navigate to auth screen
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateToAuth();
      });
    }
  }

  void _loadUserData() async {
    final authCubit = context.read<AuthCubit>();
    final uIdUser = CacheHelper.getString(key: 'uIdUser0');

    if (uIdUser != null && uIdUser.isNotEmpty && authCubit.userModel == null) {
      await authCubit.getUserData(uIdUser);
    }
  }

  void _navigateToAuth() {
    // Navigate to auth screen
    Navigator.of(context).pushReplacementNamed('/auth');
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: MyColors.primaryColor,
          title: Text(
            'Logout',
            style: MyStyles.title24White700.copyWith(fontSize: 18),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: MyStyles.title24White400.copyWith(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: MyStyles.title24White400.copyWith(fontSize: 14),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _performLogout();
              },
              child: Text(
                'Logout',
                style: MyStyles.title24White700.copyWith(
                  fontSize: 14,
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performLogout() async {
    try {
      final authCubit = context.read<AuthCubit>();
      await authCubit.logout();

      // Navigate to auth screen
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildAppBarProfileImage(dynamic user, double size) {
    // Check if user has a profile image
    if (user?.image != null && user!.image!.isNotEmpty) {
      return Image.asset(
        user.image!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultAppBarAvatar(size);
        },
      );
    } else {
      return _buildDefaultAppBarAvatar(size);
    }
  }

  Widget _buildDefaultAppBarAvatar(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(size / 2),
      ),
      child: Icon(
        Icons.person,
        color: Colors.white.withValues(alpha: 0.8),
        size: size / 2,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = _getHorizontalPadding(screenWidth);
    final verticalSpacing = _getVerticalSpacing(screenWidth);

    return Scaffold(
      backgroundColor: MyColors.primaryColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: BlocBuilder<AuthCubit, AuthStates>(
          builder: (context, state) {
            final authCubit = context.read<AuthCubit>();
            final user = authCubit.userModel;

            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    MyColors.primaryColor,
                    MyColors.primaryColor.withValues(alpha: 0.8),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    children: [
                      // Back Button
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: IconButton(
                          onPressed: () => widget.onNavigate(0),
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          padding: const EdgeInsets.all(8),
                        ),
                      ),
                      const SizedBox(width: 15),

                      // User Profile Image
                      Hero(
                        tag: 'profile_avatar',
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(25),
                            child: _buildAppBarProfileImage(user, 50),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),

                      // User Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              user?.name ?? 'User Profile',
                              style: MyStyles.title24White700.copyWith(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              user?.email ?? 'user@example.com',
                              style: MyStyles.title24White400.copyWith(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.7),
                                fontWeight: FontWeight.w400,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      // Logout Button
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: IconButton(
                          onPressed: () => _showLogoutDialog(context),
                          icon: const Icon(
                            Icons.logout_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          tooltip: 'Logout',
                          padding: const EdgeInsets.all(8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
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
