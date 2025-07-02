import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_proj/core/my_images.dart';
import 'package:movie_proj/core/my_styles.dart';
import 'package:movie_proj/core/my_text.dart';
import 'package:movie_proj/core/spacing.dart';
import 'package:movie_proj/feature/auth/manage/auth_cubit.dart';
import 'package:movie_proj/feature/auth/manage/auth_state.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthStates>(
      builder: (context, state) {
        final authCubit = context.read<AuthCubit>();
        final user = authCubit.userModel;

        return LayoutBuilder(
          builder: (context, constraints) {
            final imageSize = _getImageSize(constraints.maxWidth);
            final spacing = _getSpacing(constraints.maxWidth);
            final fontSize = _getFontSize(constraints.maxWidth);
            final containerHeight = _getContainerHeight(constraints.maxWidth);
            final isSmallScreen = constraints.maxWidth <= 400;

            return SizedBox(
              height: containerHeight,
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(spacing),
                      child: Row(
                        mainAxisAlignment: isSmallScreen
                            ? MainAxisAlignment.start
                            : MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Hero(
                            tag: 'profile_image',
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(imageSize / 2),
                                child: _buildProfileImage(user, imageSize),
                              ),
                            ),
                          ),
                          hSpace(spacing * 1.5),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user?.name ?? 'User Profile',
                                  style: MyStyles.title24White700.copyWith(
                                    fontSize: fontSize,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                vSpace(spacing * 0.5),
                                Text(
                                  user?.email ?? 'user@example.com',
                                  style: MyStyles.title24White400.copyWith(
                                    fontSize: fontSize * 0.7,
                                    color: Colors.white.withValues(alpha: 0.8),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                vSpace(spacing),
                                Wrap(
                                  spacing: spacing,
                                  runSpacing: spacing / 2,
                                  children: [
                                    _buildStat(MyText.friends, '54', fontSize),
                                    _buildStat(MyText.watched, '187', fontSize),
                                    if (!isSmallScreen) ...[
                                      _buildStat(
                                          MyText.following, '26', fontSize),
                                      _buildStat(
                                          MyText.followers, '56', fontSize),
                                    ],
                                  ],
                                ),
                                if (isSmallScreen) ...[
                                  vSpace(spacing / 2),
                                  Wrap(
                                    spacing: spacing,
                                    runSpacing: spacing / 2,
                                    children: [
                                      _buildStat(
                                          MyText.following, '26', fontSize),
                                      _buildStat(
                                          MyText.followers, '56', fontSize),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (constraints.maxWidth > 600)
                    Container(
                      width: _getPosterWidth(constraints.maxWidth),
                      height: containerHeight,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                            _getPosterRadius(constraints.maxWidth)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 10,
                            offset: const Offset(-4, 0),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                            _getPosterRadius(constraints.maxWidth)),
                        child: Image.asset(
                          MyImages.angryMen,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProfileImage(dynamic user, double imageSize) {
    // Check if user has a profile image
    if (user?.image != null && user!.image!.isNotEmpty) {
      return Image.asset(
        user.image!,
        width: imageSize,
        height: imageSize,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultAvatar(imageSize);
        },
      );
    } else {
      return _buildDefaultAvatar(imageSize);
    }
  }

  Widget _buildDefaultAvatar(double imageSize) {
    return Container(
      width: imageSize,
      height: imageSize,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(imageSize / 2),
      ),
      child: Icon(
        Icons.person,
        color: Colors.grey,
        size: imageSize / 2,
      ),
    );
  }

  Widget _buildStat(String label, String value, double fontSize) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$label: $value',
        style: MyStyles.title24White400.copyWith(
          fontSize: fontSize * 0.8,
          color: Colors.white.withValues(alpha: 0.9),
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  double _getImageSize(double width) {
    if (width <= 400) return 90;
    if (width <= 600) return 120;
    if (width <= 900) return 140;
    return 160;
  }

  double _getSpacing(double width) {
    if (width <= 400) return 12;
    if (width <= 600) return 16;
    if (width <= 900) return 20;
    return 24;
  }

  double _getFontSize(double width) {
    if (width <= 400) return 18;
    if (width <= 600) return 20;
    if (width <= 900) return 22;
    return 26;
  }

  double _getContainerHeight(double width) {
    if (width <= 400) return 200;
    if (width <= 600) return 220;
    if (width <= 900) return 240;
    return 260;
  }

  double _getPosterWidth(double width) {
    if (width <= 900) return width * 0.3;
    return 320;
  }

  double _getPosterRadius(double width) {
    if (width <= 600) return 12;
    if (width <= 900) return 16;
    return 20;
  }
}
