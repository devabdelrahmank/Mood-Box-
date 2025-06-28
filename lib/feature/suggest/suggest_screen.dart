import 'package:flutter/material.dart';
import 'package:movie_proj/core/my_colors.dart';
import 'package:movie_proj/core/widget/movie_app_bar.dart';
import 'package:movie_proj/feature/suggest/widget/suggest_body.dart';

class SuggestScreen extends StatelessWidget {
  final Function(int) onNavigate;

  const SuggestScreen({
    super.key,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.primaryColor,
      appBar: MovieAppBar(
        currentIndex: 1,
        onNavigate: onNavigate,
      ),
      body: const SuggestBody(),
    );
  }
}
