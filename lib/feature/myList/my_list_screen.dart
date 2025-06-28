import 'package:flutter/material.dart';
import 'package:movie_proj/core/my_colors.dart';
import 'package:movie_proj/core/widget/movie_app_bar.dart';
import 'package:movie_proj/feature/myList/widget/my_list_body.dart';

class MyListScreen extends StatelessWidget {
  final Function(int) onNavigate;

  const MyListScreen({
    super.key,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.primaryColor,
      appBar: MovieAppBar(
        currentIndex: 2,
        onNavigate: onNavigate,
      ),
      body: const MyListBody(),
    );
  }
}
