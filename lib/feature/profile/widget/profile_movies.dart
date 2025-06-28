import 'dart:math';
import 'package:flutter/material.dart';
import 'package:movie_proj/core/my_colors.dart';
import 'package:movie_proj/core/my_images.dart';
import 'package:movie_proj/core/my_text.dart';
import 'package:movie_proj/core/spacing.dart';
import 'package:movie_proj/feature/home/widget/film_info.dart';

class ProfileMovies extends StatefulWidget {
  const ProfileMovies({super.key});

  @override
  State<ProfileMovies> createState() => _ProfileMoviesState();
}

class _ProfileMoviesState extends State<ProfileMovies>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<bool> _hoveredItems = List.generate(8, (_) => false);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = _getCrossAxisCount(constraints.maxWidth);
        final spacing = _getSpacing(constraints.maxWidth);
        final padding = _getPadding(constraints.maxWidth);
        final childAspectRatio = _getChildAspectRatio(constraints.maxWidth);
        final isSmallScreen = constraints.maxWidth <= 400;
        final isMediumScreen = constraints.maxWidth <= 900;

        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: MyColors.secondaryColor,
            borderRadius:
                BorderRadius.circular(_getBorderRadius(constraints.maxWidth)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  left: padding / 2,
                  right: padding / 2,
                  bottom: padding,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'My Collection',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: _getTitleFontSize(constraints.maxWidth),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        if (!isSmallScreen) ...[
                          vSpace(padding / 4),
                          Text(
                            'Your favorite movies and TV shows',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize:
                                  _getSubtitleFontSize(constraints.maxWidth) *
                                      0.9,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: padding / 2,
                        vertical: padding / 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(padding / 2),
                        border: Border.all(
                          color: Colors.red.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.movie_outlined,
                            color: Colors.red,
                            size: _getSubtitleFontSize(constraints.maxWidth) *
                                1.2,
                          ),
                          hSpace(padding / 4),
                          Text(
                            '8 items',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize:
                                  _getSubtitleFontSize(constraints.maxWidth),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: spacing,
                  crossAxisSpacing: spacing,
                  childAspectRatio: childAspectRatio,
                ),
                itemCount: 8,
                itemBuilder: (context, index) {
                  final animation = CurvedAnimation(
                    parent: _controller,
                    curve: Interval(
                      (index / 8) * 0.5,
                      min(((index + 1) / 8) * 0.5 + 0.5, 1.0),
                      curve: Curves.easeOutBack,
                    ),
                  );

                  return MouseRegion(
                    onEnter: (_) => setState(() => _hoveredItems[index] = true),
                    onExit: (_) => setState(() => _hoveredItems[index] = false),
                    child: AnimatedBuilder(
                      animation: animation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: animation.value,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            transform: _hoveredItems[index] && !isMediumScreen
                                ? (Matrix4.identity()..scale(1.03))
                                : Matrix4.identity(),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                    _getItemBorderRadius(constraints.maxWidth)),
                                boxShadow: [
                                  BoxShadow(
                                    color: (_hoveredItems[index] &&
                                            !isMediumScreen)
                                        ? Colors.black.withOpacity(0.2)
                                        : Colors.black.withOpacity(0.1),
                                    blurRadius: (_hoveredItems[index] &&
                                            !isMediumScreen)
                                        ? 12
                                        : 8,
                                    offset: (_hoveredItems[index] &&
                                            !isMediumScreen)
                                        ? const Offset(0, 6)
                                        : const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                    _getItemBorderRadius(constraints.maxWidth)),
                                child: Stack(
                                  children: [
                                    _buildFilmInfo(index),
                                    if (_hoveredItems[index] && !isMediumScreen)
                                      Positioned.fill(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                Colors.black.withOpacity(0),
                                                Colors.black.withOpacity(0.7),
                                              ],
                                            ),
                                          ),
                                          child: Center(
                                            child: Icon(
                                              Icons.play_circle_outline,
                                              color: Colors.white,
                                              size: _getPlayIconSize(
                                                  constraints.maxWidth),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilmInfo(int index) {
    final films = [
      {
        'poster': MyImages.strangerThings,
        'year': MyText.usa2016,
        'name': MyText.strangerThings,
        'rating': '86.0 / 100',
        'genres': [MyText.action, MyText.adventure, MyText.horror],
      },
      {
        'poster': MyImages.batMan,
        'year': MyText.usa2005,
        'name': MyText.batmanBegins,
        'rating': '82.0 / 100',
        'genres': [MyText.action, MyText.adventure],
      },
      {
        'poster': MyImages.spiderMan,
        'year': MyText.usa2018,
        'name': MyText.spiderMan,
        'rating': '84.0 / 100',
        'genres': [MyText.action, MyText.adventure, MyText.horror],
      },
      {
        'poster': MyImages.dunkirk,
        'year': MyText.usa2016,
        'name': MyText.strangerThings,
        'rating': '86.0 / 100',
        'genres': [MyText.action, MyText.adventure],
      },
    ];

    final film = films[index % 4];
    return FilmInfo(
      filmPoster: film['poster'] as String,
      filmYear: film['year'] as String,
      filmName: film['name'] as String,
      imdbRating: film['rating'] as String,
      filmGenre1: (film['genres'] as List<String>)[0],
      filmGenre2: (film['genres'] as List<String>)[1],
      filmGenre3: (film['genres'] as List<String>).length > 2
          ? (film['genres'] as List<String>)[2]
          : '',
    );
  }

  double _getPlayIconSize(double width) {
    if (width <= 400) return 40;
    if (width <= 700) return 48;
    if (width <= 1000) return 56;
    return 64;
  }

  double _getItemBorderRadius(double width) {
    if (width <= 400) return 12;
    if (width <= 700) return 14;
    if (width <= 1000) return 16;
    return 18;
  }

  double _getChildAspectRatio(double width) {
    // Standard movie poster aspect ratio is 2:3 (width:height)
    // For the entire card including text, we'll use a slightly taller ratio
    // to accommodate the text content below the poster
    return 0.5; // This gives us roughly a 1:2 ratio which works well for movie posters with text
  }

  int _getCrossAxisCount(double width) {
    if (width <= 400) return 1;
    if (width <= 600) return 2;
    if (width <= 900) return 3;
    if (width <= 1200) return 4;
    if (width <= 1600) return 5;
    return 6; // Added 6 columns for very large screens
  }

  double _getSpacing(double width) {
    if (width <= 400) return 16;
    if (width <= 600) return 18;
    if (width <= 900) return 20;
    if (width <= 1200) return 24;
    if (width <= 1600) return 28;
    return 32; // Larger spacing for 6-column layout
  }

  double _getPadding(double width) {
    if (width <= 400) return 16;
    if (width <= 700) return 24;
    if (width <= 1000) return 32;
    return 40;
  }

  double _getBorderRadius(double width) {
    if (width <= 400) return 16;
    if (width <= 700) return 24;
    if (width <= 1000) return 28;
    return 32;
  }

  double _getTitleFontSize(double width) {
    if (width <= 400) return 20;
    if (width <= 700) return 22;
    if (width <= 1000) return 24;
    return 26;
  }

  double _getSubtitleFontSize(double width) {
    if (width <= 400) return 14;
    if (width <= 700) return 15;
    if (width <= 1000) return 16;
    return 17;
  }
}
