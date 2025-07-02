import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_proj/core/my_colors.dart';
import 'package:movie_proj/core/my_styles.dart';
import 'package:movie_proj/core/spacing.dart';
import 'package:movie_proj/feature/auth/manage/auth_cubit.dart';
import 'package:movie_proj/feature/auth/manage/auth_state.dart';

class ProfilePictureSelector extends StatelessWidget {
  const ProfilePictureSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthStates>(
      builder: (context, state) {
        final authCubit = context.read<AuthCubit>();
        
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose Your Avatar',
                style: MyStyles.title24White700.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              vSpace(12),
              
              // Gender Selection
              Row(
                children: [
                  Expanded(
                    child: _buildGenderButton(
                      context,
                      'Boy',
                      Icons.boy,
                      authCubit.selectedGender == 'boy',
                      () => authCubit.selectGender('boy'),
                    ),
                  ),
                  hSpace(12),
                  Expanded(
                    child: _buildGenderButton(
                      context,
                      'Girl',
                      Icons.girl,
                      authCubit.selectedGender == 'girl',
                      () => authCubit.selectGender('girl'),
                    ),
                  ),
                ],
              ),
              
              vSpace(16),
              
              // Avatar Selection
              Text(
                'Select Avatar:',
                style: MyStyles.title24White400.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              vSpace(8),
              
              // Avatar Gallery
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _getAvatarList(authCubit).length,
                  itemBuilder: (context, index) {
                    final avatarPath = _getAvatarList(authCubit)[index];
                    final isSelected = authCubit.selectedProfileImage == avatarPath;
                    
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: GestureDetector(
                        onTap: () => authCubit.selectProfileImage(avatarPath),
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected 
                                  ? MyColors.btnColor 
                                  : Colors.white.withValues(alpha: 0.3),
                              width: isSelected ? 3 : 1,
                            ),
                          ),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(35),
                                child: Image.asset(
                                  avatarPath,
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 70,
                                      height: 70,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.person,
                                        color: Colors.grey,
                                        size: 30,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              if (isSelected)
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: MyColors.btnColor,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 12,
                                    ),
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
              
              vSpace(12),
              
              // Selected Avatar Preview
              if (authCubit.selectedProfileImage != null)
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: MyColors.btnColor,
                          width: 2,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          authCubit.selectedProfileImage!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    hSpace(12),
                    Text(
                      'Selected Avatar',
                      style: MyStyles.title24White400.copyWith(
                        fontSize: 12,
                        color: MyColors.btnColor,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGenderButton(
    BuildContext context,
    String label,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected 
              ? MyColors.btnColor.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected 
                ? MyColors.btnColor 
                : Colors.white.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? MyColors.btnColor : Colors.white,
              size: 20,
            ),
            hSpace(8),
            Text(
              label,
              style: MyStyles.title24White400.copyWith(
                fontSize: 14,
                color: isSelected ? MyColors.btnColor : Colors.white,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _getAvatarList(AuthCubit authCubit) {
    if (authCubit.selectedGender == 'girl') {
      return authCubit.girlAvatars;
    } else {
      return authCubit.boyAvatars;
    }
  }
}
