import 'package:flutter/material.dart';
import 'package:movie_proj/core/my_images.dart';
import 'package:movie_proj/core/my_styles.dart';
import 'package:movie_proj/core/my_text.dart';
import 'package:movie_proj/core/spacing.dart';
import 'package:movie_proj/feature/auth/widget/my_text_btns.dart';
import 'package:movie_proj/feature/chat/chat_screen.dart';

class MyFriendsGrid extends StatelessWidget {
  const MyFriendsGrid({super.key});

  void _navigateToChat(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          friendName: MyText.patrickBatman,
          friendImage: MyImages.profilePic,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = _getCrossAxisCount(constraints.maxWidth);
        final spacing = _getSpacing(constraints.maxWidth);
        final imageSize = _getImageSize(constraints.maxWidth);
        final fontSize = _getFontSize(constraints.maxWidth);
        final buttonHeight = _getButtonHeight(constraints.maxWidth);

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 18,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisExtent: _getCardHeight(constraints.maxWidth),
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
          ),
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () => _navigateToChat(context),
              child: Container(
                padding: EdgeInsets.all(spacing / 2),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(
                      _getBorderRadius(constraints.maxWidth)),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(imageSize / 2),
                      child: Image.asset(
                        MyImages.profilePic,
                        width: imageSize,
                        height: imageSize,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: imageSize,
                            height: imageSize,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius:
                                  BorderRadius.circular(imageSize / 2),
                            ),
                            child: Icon(
                              Icons.person,
                              color: Colors.grey,
                              size: imageSize / 2,
                            ),
                          );
                        },
                      ),
                    ),
                    hSpace(spacing),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            MyText.patrickBatman,
                            style: MyStyles.title24White400.copyWith(
                              fontSize: fontSize,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          vSpace(spacing / 2),
                          Wrap(
                            spacing: spacing,
                            runSpacing: spacing / 2,
                            children: [
                              Text(
                                '${MyText.friends} :54',
                                style: MyStyles.title24White400.copyWith(
                                  fontSize: fontSize * 0.8,
                                  color: Colors.white70,
                                ),
                              ),
                              Text(
                                '${MyText.watched} :187',
                                style: MyStyles.title24White400.copyWith(
                                  fontSize: fontSize * 0.8,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                          vSpace(spacing / 2),
                          SizedBox(
                            height: buttonHeight,
                            child: MyTextBtn(
                              onTap: () {},
                              text: MyText.add,
                              color: Colors.blue,
                              textColor: Colors.white,
                              radius: buttonHeight / 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  int _getCrossAxisCount(double width) {
    if (width <= 400) return 1;
    if (width <= 700) return 2;
    return 3;
  }

  double _getSpacing(double width) {
    if (width <= 400) return 8;
    if (width <= 700) return 12;
    return 16;
  }

  double _getImageSize(double width) {
    if (width <= 400) return 48;
    if (width <= 700) return 56;
    return 64;
  }

  double _getFontSize(double width) {
    if (width <= 400) return 14;
    if (width <= 700) return 16;
    return 18;
  }

  double _getButtonHeight(double width) {
    if (width <= 400) return 28;
    if (width <= 700) return 32;
    return 36;
  }

  double _getBorderRadius(double width) {
    if (width <= 400) return 8;
    if (width <= 700) return 12;
    return 16;
  }

  double _getCardHeight(double width) {
    if (width <= 400) return 120;
    if (width <= 700) return 160;
    return 200;
  }
}
