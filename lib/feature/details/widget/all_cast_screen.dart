import 'package:flutter/material.dart';
import 'package:movie_proj/core/my_colors.dart';
import 'package:movie_proj/core/my_styles.dart';
import 'package:movie_proj/feature/home/model/cast_model.dart';

class AllCastScreen extends StatelessWidget {
  final List<CastModel> castList;
  final String movieTitle;

  const AllCastScreen({
    super.key,
    required this.castList,
    required this.movieTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.primaryColor,
      appBar: AppBar(
        backgroundColor: MyColors.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cast & Crew',
              style: MyStyles.heading2.copyWith(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            Text(
              movieTitle,
              style: MyStyles.caption.copyWith(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Header with count
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Icon(
                  Icons.people,
                  color: MyColors.secondaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  '${castList.length} Cast Members',
                  style: MyStyles.heading2.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // Cast grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 20,
                childAspectRatio: 0.75,
              ),
              itemCount: castList.length,
              itemBuilder: (context, index) {
                final castMember = castList[index];
                return _buildCastCard(context, castMember);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCastCard(BuildContext context, CastModel castMember) {
    return GestureDetector(
      onTap: () {
        _showCastDetails(context, castMember);
      },
      child: Container(
        decoration: BoxDecoration(
          color: MyColors.secondaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: MyColors.secondaryColor.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile image
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.network(
                    castMember.fullProfilePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[800],
                        child: const Center(
                          child: Icon(
                            Icons.person,
                            color: Colors.grey,
                            size: 40,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            // Cast info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Character name
                    Row(
                      children: [
                        const Icon(
                          Icons.person_4,
                          color: MyColors.secondaryColor,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            castMember.displayCharacter,
                            style: MyStyles.body.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Actor name
                    Text(
                      castMember.displayName,
                      style: MyStyles.caption.copyWith(
                        color: MyColors.secondaryColor.withValues(alpha: 0.8),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // Popularity indicator
                    if (castMember.popularity != null &&
                        castMember.popularity! > 20)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: MyColors.secondaryColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Popular',
                          style: MyStyles.caption.copyWith(
                            color: MyColors.secondaryColor,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCastDetails(BuildContext context, CastModel castMember) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => CastDetailsSheet(castMember: castMember),
    );
  }
}

class CastDetailsSheet extends StatelessWidget {
  final CastModel castMember;

  const CastDetailsSheet({
    super.key,
    required this.castMember,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: MyColors.primaryColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[600],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile section
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile image
                      Container(
                        width: 100,
                        height: 140,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            castMember.fullProfilePath,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[800],
                                child: const Center(
                                  child: Icon(
                                    Icons.person,
                                    color: Colors.grey,
                                    size: 40,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              castMember.displayName,
                              style: MyStyles.heading2.copyWith(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.person_4,
                                  color: MyColors.secondaryColor,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    'as ${castMember.displayCharacter}',
                                    style: MyStyles.body.copyWith(
                                      color: MyColors.secondaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (castMember.knownForDepartment != null)
                              _buildDetailRow(
                                'Department',
                                castMember.knownForDepartment!,
                              ),
                            if (castMember.popularity != null)
                              _buildDetailRow(
                                'Popularity',
                                castMember.popularity!.toStringAsFixed(1),
                              ),
                            _buildDetailRow(
                              'Order',
                              '#${(castMember.order ?? 0) + 1}',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Additional info section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: MyColors.secondaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: MyColors.secondaryColor.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Character Information',
                          style: MyStyles.heading2.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'This character is played by ${castMember.displayName} in this movie. ${castMember.displayCharacter} is an important part of the story.',
                          style: MyStyles.body.copyWith(
                            color: Colors.white.withValues(alpha: 0.8),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: MyStyles.caption.copyWith(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: MyStyles.caption.copyWith(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
