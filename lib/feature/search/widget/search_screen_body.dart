import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_proj/core/spacing.dart';
import 'package:movie_proj/feature/search/manage/search_cubit.dart';
import 'package:movie_proj/feature/search/widget/filter_container.dart';
import 'package:movie_proj/feature/search/widget/search_field.dart';

class SearchScreenBody extends StatelessWidget {
  const SearchScreenBody({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return BlocProvider(
      create: (context) => SearchCubit(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (size.width > 1000) const ContainerFilter(),
              hSpace(20),
              const SearchField(),
            ],
          ),
        ),
      ),
    );
  }
}
