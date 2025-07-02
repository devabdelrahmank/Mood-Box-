import 'package:flutter/material.dart';
import 'package:movie_proj/core/my_styles.dart';
import 'package:movie_proj/core/spacing.dart';

class PhotosSection extends StatelessWidget {
  final List<String> photos;

  const PhotosSection({
    super.key,
    required this.photos,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Photos',
              style: MyStyles.heading2.copyWith(color: Colors.white),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'See all ${photos.length}',
                style: MyStyles.body.copyWith(color: Colors.white70),
              ),
            ),
          ],
        ),
        const SizedBox(height: Spacing.medium),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: photos.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(
                  right: index < photos.length - 1 ? Spacing.medium : 0,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    photos[index],
                    width: 280,
                    height: 180,
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
