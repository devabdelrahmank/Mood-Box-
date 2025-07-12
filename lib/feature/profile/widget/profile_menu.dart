import 'package:flutter/material.dart';
import 'package:movie_proj/core/my_text.dart';
import 'package:movie_proj/core/spacing.dart';
import 'package:movie_proj/feature/user_lists/service/user_lists_service.dart';
import 'package:movie_proj/feature/user_lists/model/saved_movie_model.dart';
import 'package:movie_proj/feature/myFriends/service/friends_service.dart';

class ProfileMenu extends StatefulWidget {
  const ProfileMenu({super.key});

  @override
  State<ProfileMenu> createState() => _ProfileMenuState();
}

class _ProfileMenuState extends State<ProfileMenu> {
  int selectedIndex = 0;
  List<Map<String, dynamic>> tabs = [
    {'title': MyText.all, 'count': 0},
    {'title': MyText.tvShows, 'count': 0},
    {'title': MyText.movies, 'count': 0},
    {'title': 'watch later', 'count': 0},
    {'title': 'My Friends', 'count': 0},
  ];

  @override
  void initState() {
    super.initState();
    _loadUserCounts();
  }

  Future<void> _loadUserCounts() async {
    try {
      // Load both favorites and watch later lists
      final favorites = await UserListsService.getFavorites();
      final watchLater = await UserListsService.getWatchLater();

      // Load friends list
      final friends = await FriendsService.getFriends();

      // Combine both lists for total count
      final allMovies = <SavedMovieModel>[];
      allMovies.addAll(favorites);
      allMovies.addAll(watchLater);

      // Remove duplicates based on movieId
      final uniqueMovies = <String, SavedMovieModel>{};
      for (final movie in allMovies) {
        uniqueMovies[movie.movieId] = movie;
      }
      final totalCollection = uniqueMovies.values.toList();

      // Count movies and TV shows based on genre analysis
      int movieCount = 0;
      int tvShowCount = 0;

      for (final movie in totalCollection) {
        if (_isLikelyTVShow(movie)) {
          tvShowCount++;
          // Debug: uncomment to see what's classified as TV
          // print('TV Show: ${movie.title}');
        } else {
          movieCount++;
          // Debug: uncomment to see what's classified as Movie
          // print('Movie: ${movie.title}');
        }
      }

      if (mounted) {
        setState(() {
          tabs = [
            {'title': "All Movies", 'count': totalCollection.length},
            {'title': 'Favorite', 'count': favorites.length},
            {'title': 'watch later', 'count': watchLater.length},
            {'title': 'My Friends', 'count': friends.length},
          ];
        });
      }
    } catch (e) {
      if (mounted) {
        // Handle error silently - keep existing counts
      }
    }
  }

  // Helper method to determine if a saved movie is likely a TV show
  bool _isLikelyTVShow(SavedMovieModel movie) {
    final title = movie.title.toLowerCase().trim();
    final originalTitle = movie.originalTitle.toLowerCase().trim();

    // Known TV shows (manual override for common shows)
    final knownTVShows = [
      'stranger things',
      'breaking bad',
      'game of thrones',
      'the office',
      'friends',
      'the walking dead',
      'house of cards',
      'narcos',
      'orange is the new black',
      'black mirror',
      'sherlock',
      'the crown',
      'westworld',
      'better call saul',
      'the mandalorian',
      'the witcher',
      'squid game',
      'money heist',
      'dark',
      'ozark',
      'the boys',
      'euphoria',
      'succession',
      'ted lasso',
      'bridgerton',
      'the umbrella academy',
      'cobra kai',
      'lucifer',
      'vikings',
      'peaky blinders',
      'the handmaids tale',
      'mindhunter',
      'the good place',
      'atlanta',
      'fargo',
      'true detective',
      'homeland',
      'dexter',
      'lost',
      'prison break',
      'how i met your mother',
      'the big bang theory',
      'modern family',
      'parks and recreation',
      'arrested development',
      'community',
      'scrubs',
      'the sopranos',
      'the wire',
      'mad men',
      'boardwalk empire',
      'house',
      'greys anatomy',
      'supernatural',
      'arrow',
      'the flash',
      'gotham',
      'daredevil',
      'jessica jones',
      'luke cage',
      'iron fist',
      'the defenders',
      'the punisher',
      'agents of shield',
      'legion',
      'the gifted',
      'american horror story',
      'the vampire diaries',
      'the originals',
      'teen wolf',
      'pretty little liars',
      'gossip girl',
      'one tree hill',
      'gilmore girls',
      'dawsons creek',
      'buffy the vampire slayer',
      'angel',
      'charmed',
      'smallville',
      'supernatural',
      'doctor who',
      'torchwood',
      'sherlock',
      'downton abbey',
      'outlander',
      'the walking dead',
      'fear the walking dead',
      'better call saul',
      'el camino',
      'breaking bad',
      'ozark',
      'narcos',
      'narcos mexico',
      'mindhunter',
      'house of cards',
      'orange is the new black',
      'stranger things',
      'dark',
      'money heist',
      'la casa de papel',
      'elite',
      'sex education',
      'the witcher',
      'the umbrella academy',
      'locke and key',
      'cursed',
      'the queens gambit',
      'bridgerton',
      'lupin',
      'emily in paris',
      'the crown',
      'the mandalorian',
      'wandavision',
      'the falcon and the winter soldier',
      'loki',
      'hawkeye',
      'moon knight',
      'she hulk',
      'ms marvel',
      'what if',
      'the boys',
      'invincible',
      'the walking dead',
      'fear the walking dead',
      'world beyond',
      'tales of the walking dead',
      'the last of us',
      'house of the dragon',
      'rings of power',
      'the bear',
      'abbott elementary',
      'wednesday',
      'dahmer',
      'monster',
      'the watcher',
      'the midnight club',
      'the sandman',
      'heartstopper',
      'young royals',
      'elite',
    ];

    // Check if it's a known TV show
    for (final tvShow in knownTVShows) {
      if (title.contains(tvShow) || originalTitle.contains(tvShow)) {
        return true;
      }
    }

    // Strong TV show indicators in title
    final strongTVIndicators = [
      'season',
      'episode',
      'series',
      'tv show',
      'show',
      'miniseries',
      'limited series',
      'anthology',
      ': season',
      ': series',
      ': episode',
      'season 1',
      'season 2',
      'season 3',
      'season 4',
      'season 5',
      's01',
      's02',
      's03',
      's04',
      's05',
      'episode 1',
      'episode 2',
      'ep 1',
      'ep 2',
      'part i',
      'part ii',
      'part iii',
      'chapter 1',
      'chapter 2',
      'volume 1',
      'volume 2',
    ];

    for (final indicator in strongTVIndicators) {
      if (title.contains(indicator) || originalTitle.contains(indicator)) {
        return true;
      }
    }

    // Check for TV-specific genre IDs
    for (final genreId in movie.genreIds) {
      if (tvGenreIds.contains(genreId)) {
        return true;
      }
    }

    return false; // Default to movie if uncertain
  }

  // TV Show genre IDs (based on TMDB)
  static const Set<int> tvGenreIds = {
    10759, // Action & Adventure
    16, // Animation (can be TV)
    35, // Comedy (can be TV)
    80, // Crime (can be TV)
    99, // Documentary (can be TV)
    18, // Drama (can be TV)
    10751, // Family (can be TV)
    10762, // Kids
    9648, // Mystery (can be TV)
    10763, // News
    10764, // Reality
    10765, // Sci-Fi & Fantasy
    10766, // Soap
    10767, // Talk
    10768, // War & Politics
    37, // Western (can be TV)
  };

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
