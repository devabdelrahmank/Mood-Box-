import 'package:flutter/material.dart';
import 'package:movie_proj/core/my_styles.dart';
import 'package:movie_proj/core/spacing.dart';
import 'package:movie_proj/feature/details/model/movie_model.dart';

class CastSection extends StatelessWidget {
  final List<CastMember> cast;

  const CastSection({
    super.key,
    required this.cast,
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
              'Cast',
              style: MyStyles.heading2.copyWith(color: Colors.white),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'See all ${cast.length}',
                style: MyStyles.body.copyWith(color: Colors.white70),
              ),
            ),
          ],
        ),
        const SizedBox(height: Spacing.medium),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: cast.length,
            itemBuilder: (context, index) {
              final member = cast[index];
              return Padding(
                padding: EdgeInsets.only(
                  right: index < cast.length - 1 ? Spacing.medium : 0,
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: NetworkImage(member.imageUrl),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      member.name,
                      style: MyStyles.caption.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
