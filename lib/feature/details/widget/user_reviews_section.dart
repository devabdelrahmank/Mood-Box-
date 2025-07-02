import 'package:flutter/material.dart';
import 'package:movie_proj/core/my_colors.dart';
import 'package:movie_proj/core/my_styles.dart';
import 'package:movie_proj/core/spacing.dart';

class UserReviewsSection extends StatelessWidget {
  const UserReviewsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with "See all" button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.medium),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'User Reviews',
                style: MyStyles.heading2.copyWith(color: Colors.white),
              ),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add, color: Colors.white),
                label: Text(
                  'Review',
                  style: MyStyles.body.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: Spacing.medium),
        // Review cards
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.medium),
          child: Column(
            children: [
              _buildReviewCard(),
              const SizedBox(height: Spacing.medium),
              _buildReviewCard(),
            ],
          ),
        ),
        const SizedBox(height: Spacing.medium),
        // See all button
        Center(
          child: TextButton(
            onPressed: () {},
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'See all 1.4K',
                  style: MyStyles.body.copyWith(color: Colors.white70),
                ),
                const Icon(Icons.chevron_right, color: Colors.white70),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Spacing.medium),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rating and title row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    '10/10',
                    style: MyStyles.body.copyWith(
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: Spacing.medium),
              Expanded(
                child: Text(
                  'One Of The Greatest Sequel Ever Made, Dune: Part Two Was Easily The Best Films Of The Year So Far',
                  style: MyStyles.body.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.small),
          // Username and date
          Row(
            children: [
              Text(
                'username',
                style: MyStyles.caption.copyWith(
                  color: MyColors.secondaryColor,
                ),
              ),
              const SizedBox(width: Spacing.small),
              Text(
                '20 Feb 2024',
                style: MyStyles.caption.copyWith(
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.small),
          // Review text
          Text(
            "In the quiet embrace of ink and page, a story unfolded, timeless and sage, through the lens of a filmmaker's artistry, its essence soared, a masterpiece for all to see, i think Denis Villeneuve has just made the most visually stunning epic story of a movie that's ever been made, the most powerful story of a movie ever been told in the last 20 years, there has been no movies with this scale resulting in not just a piece of a film no more but a piece of art, it's what Infinity War and Endgame looks like...",
            style: MyStyles.body.copyWith(color: Colors.white70),
            maxLines: 6,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: Spacing.medium),
          // Helpful buttons
          Row(
            children: [
              _buildHelpfulButton(true, '210'),
              const SizedBox(width: Spacing.medium),
              _buildHelpfulButton(false, '210'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHelpfulButton(bool isHelpful, String count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          isHelpful ? 'Helpful' : 'Not helpful',
          style: MyStyles.caption.copyWith(color: Colors.white70),
        ),
        const SizedBox(width: 4),
        Icon(
          isHelpful ? Icons.thumb_up_outlined : Icons.thumb_down_outlined,
          color: Colors.white70,
          size: 16,
        ),
        const SizedBox(width: 4),
        Text(
          count,
          style: MyStyles.caption.copyWith(color: Colors.white70),
        ),
      ],
    );
  }
}
