import 'package:flutter/material.dart';
import 'package:movie_proj/core/my_colors.dart';
import 'package:movie_proj/core/my_images.dart';
import 'package:movie_proj/core/my_styles.dart';
import 'package:movie_proj/core/my_text.dart';
import 'package:movie_proj/core/spacing.dart';
import 'package:movie_proj/feature/details/details_screen.dart';
import 'package:movie_proj/feature/details/model/movie_model.dart';

class SuggestBody extends StatelessWidget {
  const SuggestBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            vSpace(30),
            Center(
              child: Text(
                MyText.forYourTaste,
                style: MyStyles.title24White700.copyWith(fontSize: 24),
              ),
            ),
            vSpace(16),
            Center(
              child: Text(
                MyText.choseFiveMovies,
                style: MyStyles.title24White400.copyWith(fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),
            vSpace(30),
            Text(
              MyText.weRecommend,
              style: MyStyles.title24White700.copyWith(fontSize: 18),
            ),
            vSpace(20),
            _buildRecommendationGrid(context),
            vSpace(30),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationGrid(BuildContext context) {
    final recommendations = [
      MyText.theFallOfTheHouse,
      MyText.lessonsInChemistry,
      MyText.goosebumps,
      MyText.loki,
      MyText.fellowTravelers,
      MyText.genV,
      MyText.ourFlagMeansDeath,
      MyText.thirtyCoins,
      MyText.theOrder,
      MyText.midnightMass,
      MyText.rickAndMorty,
      MyText.wolfLikeMe,
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = _getCrossAxisCount(constraints.maxWidth);
        final spacing = _getSpacing(constraints.maxWidth);

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            childAspectRatio: 0.65,
          ),
          itemCount: recommendations.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                // Create a sample movie data (replace with actual data in your app)
                final movie = MovieModel(
                  title: 'Dune: Part Two',
                  posterUrl: 'assets/images/dune.png',
                  year: '2024',
                  duration: '2h 46m',
                  rating: '8.5',
                  genres: ['Adventure', 'Action', 'Drama'],
                  plot:
                      'Paul Atreides unites with Chani and the Fremen while seeking revenge against the conspirators who destroyed his family.',
                  director: 'Denis Villeneuve',
                  stars: 'Timothée Chalamet, Zendaya, Rebecca Ferguson',
                  reviews:
                      '1K User Reviews, 500 Critic Reviews, 92% Metacritic',
                  photos: [
                    'assets/images/Group 9.png',
                    'assets/images/image 15.png',
                    'assets/images/image 16.png',
                    'assets/images/Group 10.png',
                  ],
                  cast: [
                    CastMember(
                      name: 'Zendaya',
                      role: 'Chani',
                      imageUrl: 'assets/images/image 18(1).png',
                    ),
                    CastMember(
                      name: 'Timothée Chalamet',
                      role: 'Paul Atreides',
                      imageUrl: 'assets/images/image 18(2).png',
                    ),
                    CastMember(
                      name: 'Zendaya',
                      role: 'Chani',
                      imageUrl: 'assets/images/image 18(3).png',
                    ),
                    CastMember(
                      name: 'Timothée Chalamet',
                      role: 'Paul Atreides',
                      imageUrl: 'assets/images/image 18(4).png',
                    ),
                    CastMember(
                      name: 'Zendaya',
                      role: 'Chani',
                      imageUrl: 'assets/images/image 18.png',
                    ),
                    // Add more cast members as needed
                  ],
                );

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailsScreen(movie: movie),
                  ),
                );
              },
              child: _buildRecommendationCard(
                  recommendations[index], constraints.maxWidth),
            );
          },
        );
      },
    );
  }

  int _getCrossAxisCount(double width) {
    if (width <= 400) return 2;
    if (width <= 700) return 3;
    return 4;
  }

  double _getSpacing(double width) {
    if (width <= 400) return 8;
    if (width <= 700) return 12;
    return 16;
  }

  Widget _buildRecommendationCard(String title, double containerWidth) {
    final isSmallScreen = containerWidth <= 400;
    final isMediumScreen = containerWidth <= 700;

    return Container(
      decoration: BoxDecoration(
        color: MyColors.secondaryColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(10)),
                image: DecorationImage(
                  image: const AssetImage(MyImages.dunkirk),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.1),
                    BlendMode.darken,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
              child: Text(
                title,
                style: MyStyles.title24White400.copyWith(
                  fontSize: isSmallScreen ? 10 : (isMediumScreen ? 11 : 12),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
