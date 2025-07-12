import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_proj/core/my_colors.dart';
import 'package:movie_proj/core/my_styles.dart';
import 'package:movie_proj/core/my_text.dart';
import 'package:movie_proj/core/spacing.dart';
import 'package:movie_proj/feature/search/manage/search_cubit.dart';
import 'package:movie_proj/feature/search/widget/filter_item.dart';

class ContainerFilter extends StatefulWidget {
  const ContainerFilter({super.key});

  @override
  State<ContainerFilter> createState() => _ContainerFilterState();
}

class _ContainerFilterState extends State<ContainerFilter> {
  String? _selectedYear;
  String? _selectedGenre;

  final List<String> _years = [
    '2024',
    '2023',
    '2022',
    '2021',
    '2020',
    '2019',
    '2018',
    '2017',
    '2016',
    '2015'
  ];

  final Map<String, String> _genres = {
    '28': 'Action',
    '12': 'Adventure',
    '16': 'Animation',
    '35': 'Comedy',
    '80': 'Crime',
    '99': 'Documentary',
    '18': 'Drama',
    '10751': 'Family',
    '14': 'Fantasy',
    '36': 'History',
    '27': 'Horror',
    '10402': 'Music',
    '9648': 'Mystery',
    '10749': 'Romance',
    '878': 'Science Fiction',
    '10770': 'TV Movie',
    '53': 'Thriller',
    '10752': 'War',
    '37': 'Western',
  };

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      height: size.height - 150,
      width: size.width / 5,
      color: MyColors.secondaryColor,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    MyText.filters,
                    style: MyStyles.title24White700.copyWith(
                      fontSize: 18,
                      color: const Color(0xff797979),
                    ),
                  ),
                  hSpace(5),
                  const Icon(
                    Icons.filter_list,
                    color: const Color(0xff797979),
                  ),
                ],
              ),
              vSpace(30),

              // Release Year Filter
              _buildYearFilter(),
              vSpace(20),

              // Genre Filter
              _buildGenreFilter(),
              vSpace(20),

              // Clear Filters Button
              _buildClearFiltersButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildYearFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Release Year',
          style: MyStyles.title24White700.copyWith(
            fontSize: 16,
            color: const Color(0xff797979),
          ),
        ),
        vSpace(10),
        DropdownButtonFormField<String>(
          value: _selectedYear,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xff1A1A1A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          dropdownColor: const Color(0xff1A1A1A),
          style: const TextStyle(color: Colors.white),
          hint: const Text(
            'Select Year',
            style: TextStyle(color: Color(0xff797979)),
          ),
          items: _years.map((year) {
            return DropdownMenuItem(
              value: year,
              child: Text(year),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedYear = value;
            });
            _updateFilters();
          },
        ),
      ],
    );
  }

  Widget _buildGenreFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Genre',
          style: MyStyles.title24White700.copyWith(
            fontSize: 16,
            color: const Color(0xff797979),
          ),
        ),
        vSpace(10),
        DropdownButtonFormField<String>(
          value: _selectedGenre,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xff1A1A1A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          dropdownColor: const Color(0xff1A1A1A),
          style: const TextStyle(color: Colors.white),
          hint: const Text(
            'Select Genre',
            style: TextStyle(color: Color(0xff797979)),
          ),
          items: _genres.entries.map((entry) {
            return DropdownMenuItem(
              value: entry.key,
              child: Text(entry.value),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedGenre = value;
            });
            _updateFilters();
          },
        ),
      ],
    );
  }

  Widget _buildClearFiltersButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _clearFilters,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text('Clear Filters'),
      ),
    );
  }

  void _updateFilters() {
    final currentFilters = context.read<SearchCubit>().currentFilters;
    final newFilters = currentFilters.copyWith(
      year: _selectedYear,
      genre: _selectedGenre,
    );
    context.read<SearchCubit>().updateFilters(newFilters);
  }

  void _clearFilters() {
    setState(() {
      _selectedYear = null;
      _selectedGenre = null;
    });

    const newFilters = SearchFilters();
    context.read<SearchCubit>().updateFilters(newFilters);
  }
}
