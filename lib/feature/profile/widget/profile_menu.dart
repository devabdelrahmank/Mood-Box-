import 'package:flutter/material.dart';
import 'package:movie_proj/core/my_text.dart';
import 'package:movie_proj/core/spacing.dart';

class ProfileMenu extends StatefulWidget {
  const ProfileMenu({super.key});

  @override
  State<ProfileMenu> createState() => _ProfileMenuState();
}

class _ProfileMenuState extends State<ProfileMenu> {
  int selectedIndex = 0;
  final List<Map<String, dynamic>> tabs = [
    {'title': MyText.all, 'count': 3448},
    {'title': MyText.tvShows, 'count': 28},
    {'title': MyText.movies, 'count': 250},
    {'title': MyText.watchList, 'count': 120},
    {'title': MyText.likes, 'count': 3050},
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final fontSize = _getFontSize(constraints.maxWidth);
        final spacing = _getSpacing(constraints.maxWidth);
        final containerHeight = _getContainerHeight(constraints.maxWidth);
        final itemPadding = _getItemPadding(constraints.maxWidth);
        final isSmallScreen = constraints.maxWidth <= 400;

        return Container(
          width: double.infinity,
          height: containerHeight,
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(_getBorderRadius(constraints.maxWidth)),
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                const Color(0xff272729).withOpacity(0.95),
                const Color(0xff272729).withOpacity(0.8),
                const Color(0xff272729).withOpacity(0.4),
                Colors.transparent,
              ],
              stops: const [0.0, 0.3, 0.7, 1.0],
            ),
          ),
          child: ShaderMask(
            shaderCallback: (Rect bounds) {
              return LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.white.withOpacity(0.1),
                  Colors.white,
                  Colors.white,
                  Colors.white.withOpacity(0.1),
                ],
                stops: const [0.0, 0.1, 0.9, 1.0],
              ).createShader(bounds);
            },
            blendMode: BlendMode.dstIn,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: spacing,
                vertical: spacing / 2,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: List.generate(tabs.length, (index) {
                  final isSelected = selectedIndex == index;
                  return Padding(
                    padding: EdgeInsets.only(right: spacing),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              selectedIndex = index;
                            });
                          },
                          borderRadius: BorderRadius.circular(
                              _getItemRadius(constraints.maxWidth)),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: EdgeInsets.symmetric(
                              vertical: itemPadding,
                              horizontal:
                                  itemPadding * (isSmallScreen ? 1.2 : 1.5),
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.red.withOpacity(0.9)
                                  : Colors.black.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(
                                  _getItemRadius(constraints.maxWidth)),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.red
                                    : Colors.transparent,
                                width: 1,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: Colors.red.withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  tabs[index]['title'],
                                  style: TextStyle(
                                    color: Colors.white
                                        .withOpacity(isSelected ? 1 : 0.8),
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                    fontSize: fontSize,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                vSpace(spacing / 2),
                                AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 200),
                                  style: TextStyle(
                                    color: Colors.white
                                        .withOpacity(isSelected ? 1 : 0.7),
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.w600,
                                    fontSize:
                                        fontSize * (isSelected ? 1.2 : 1.1),
                                  ),
                                  child: Text(
                                    _formatCount(tabs[index]['count']),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatCount(int count) {
    if (count >= 1000) {
      final thousands = (count / 1000).toStringAsFixed(1);
      return '${thousands}K';
    }
    return count.toString();
  }

  double _getFontSize(double width) {
    if (width <= 400) return 11;
    if (width <= 600) return 12;
    if (width <= 900) return 13;
    return 14;
  }

  double _getSpacing(double width) {
    if (width <= 400) return 8;
    if (width <= 600) return 10;
    if (width <= 900) return 12;
    return 16;
  }

  double _getContainerHeight(double width) {
    if (width <= 400) return 75;
    if (width <= 600) return 85;
    if (width <= 900) return 95;
    return 100;
  }

  double _getBorderRadius(double width) {
    if (width <= 400) return 16;
    if (width <= 600) return 18;
    if (width <= 900) return 20;
    return 24;
  }

  double _getItemPadding(double width) {
    if (width <= 400) return 8;
    if (width <= 600) return 10;
    if (width <= 900) return 12;
    return 14;
  }

  double _getItemRadius(double width) {
    if (width <= 400) return 8;
    if (width <= 600) return 10;
    if (width <= 900) return 12;
    return 14;
  }
}
