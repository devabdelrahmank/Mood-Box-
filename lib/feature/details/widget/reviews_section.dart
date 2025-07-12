import 'package:flutter/material.dart';
import 'package:movie_proj/core/model/review_model.dart';
import 'package:movie_proj/core/my_colors.dart';
import 'package:movie_proj/core/my_styles.dart';
import 'package:movie_proj/core/spacing.dart';

class ReviewsSection extends StatelessWidget {
  final List<ReviewModel> reviews;
  final VoidCallback? onSeeAllReviews;

  const ReviewsSection({
    super.key,
    required this.reviews,
    this.onSeeAllReviews,
  });

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'User Reviews',
                style: MyStyles.title24White700.copyWith(fontSize: 20),
              ),
              if (onSeeAllReviews != null)
                GestureDetector(
                  onTap: onSeeAllReviews,
                  child: Row(
                    children: [
                      Text(
                        'See all 1.4K',
                        style: MyStyles.title24White400.copyWith(
                          fontSize: 14,
                          color: Colors.grey[400],
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 12,
                        color: Colors.grey[400],
                      ),
                    ],
                  ),
                ),
            ],
          ),
          vSpace(20),
          ...reviews.map((review) => _buildReviewCard(review)).toList(),
        ],
      ),
    );
  }

  Widget _buildReviewCard(ReviewModel review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MyColors.secondaryColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[800]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with rating and user info
          Row(
            children: [
              // Rating stars
              Row(
                children: [
                  Icon(
                    Icons.star,
                    color: Colors.red,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${review.rating.toStringAsFixed(0)}/10',
                    style: MyStyles.title24White700.copyWith(
                      fontSize: 14,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Review button
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Review',
                      style: MyStyles.title24White400.copyWith(
                        fontSize: 12,
                        color: Colors.grey[300],
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.add,
                      size: 12,
                      color: Colors.grey[300],
                    ),
                  ],
                ),
              ),
            ],
          ),
          vSpace(12),
          
          // Review title (first line of content)
          Text(
            _getReviewTitle(review.content),
            style: MyStyles.title24White700.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          vSpace(8),
          
          // Username and date
          Row(
            children: [
              Text(
                review.username,
                style: MyStyles.title24White400.copyWith(
                  fontSize: 12,
                  color: Colors.grey[400],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                review.date,
                style: MyStyles.title24White400.copyWith(
                  fontSize: 12,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
          vSpace(12),
          
          // Review content
          Text(
            review.content,
            style: MyStyles.title24White400.copyWith(
              fontSize: 14,
              height: 1.5,
            ),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
          vSpace(16),
          
          // Helpful buttons
          Row(
            children: [
              _buildHelpfulButton(
                count: review.helpfulCount,
                isHelpful: true,
              ),
              const SizedBox(width: 16),
              _buildHelpfulButton(
                count: review.notHelpfulCount,
                isHelpful: false,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHelpfulButton({
    required int count,
    required bool isHelpful,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          count.toString(),
          style: MyStyles.title24White400.copyWith(
            fontSize: 12,
            color: Colors.grey[400],
          ),
        ),
        const SizedBox(width: 4),
        Text(
          isHelpful ? 'Helpful' : '',
          style: MyStyles.title24White400.copyWith(
            fontSize: 12,
            color: Colors.grey[400],
          ),
        ),
        const SizedBox(width: 4),
        Icon(
          isHelpful ? Icons.thumb_up_outlined : Icons.thumb_down_outlined,
          size: 14,
          color: Colors.grey[400],
        ),
      ],
    );
  }

  String _getReviewTitle(String content) {
    // استخراج العنوان من أول جملة في المراجعة
    final sentences = content.split('.');
    if (sentences.isNotEmpty) {
      final firstSentence = sentences[0].trim();
      if (firstSentence.length > 60) {
        return firstSentence.substring(0, 60) + '...';
      }
      return firstSentence;
    }
    return content.length > 60 ? content.substring(0, 60) + '...' : content;
  }
}
