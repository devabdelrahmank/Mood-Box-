import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_proj/core/my_colors.dart';
import 'package:movie_proj/core/widget/movie_app_bar.dart';
import 'package:movie_proj/feature/suggest/widget/suggest_body.dart';
import 'package:movie_proj/feature/suggest/manage/top_rated_cubit.dart';
import 'package:movie_proj/core/service/index.dart';

class SuggestScreen extends StatefulWidget {
  final Function(int) onNavigate;

  const SuggestScreen({
    super.key,
    required this.onNavigate,
  });

  @override
  State<SuggestScreen> createState() => _SuggestScreenState();
}

class _SuggestScreenState extends State<SuggestScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => false; // Don't keep alive to ensure fresh data

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload data when returning to this screen
    _loadData();
  }

  void _loadData() {
    // Load top rated content with random shuffle
    Future.microtask(() {
      if (mounted) {
        context.read<TopRatedCubit>().loadTopRated();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return Scaffold(
      backgroundColor: MyColors.primaryColor,
      appBar: MovieAppBar(
        currentIndex: 1,
        onNavigate: widget.onNavigate,
      ),
      body: const SuggestBody(),
    );
  }
}
