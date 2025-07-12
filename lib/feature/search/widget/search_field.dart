import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_proj/core/my_styles.dart';
import 'package:movie_proj/core/my_text.dart';
import 'package:movie_proj/core/my_text_field.dart';
import 'package:movie_proj/core/spacing.dart';
import 'package:movie_proj/feature/search/manage/search_cubit.dart';
import 'package:movie_proj/feature/search/widget/search_result_item.dart';

class SearchField extends StatefulWidget {
  const SearchField({super.key});

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  late TextEditingController _searchController;
  String _sortBy = 'popularity';
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Expanded(
      child: SizedBox(
        height: size.height,
        width: double.infinity,
        child: Column(
          children: [
            Row(
              children: [
                // Sort By Dropdown
                Expanded(
                  flex: 1,
                  child: _buildSortDropdown(),
                ),
                hSpace(10),
                // Search Field
                Expanded(
                  flex: 3,
                  child: _buildSearchField(),
                ),
              ],
            ),
            vSpace(20),
            // Results Count
            _buildResultsCount(),
            vSpace(10),
            // Search Results
            Expanded(
              child: _buildSearchResults(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortDropdown() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xff1A1A1A),
        borderRadius: BorderRadius.circular(5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _sortBy,
          dropdownColor: const Color(0xff1A1A1A),
          icon: const Icon(
            Icons.arrow_drop_down,
            color: Color(0xff797979),
          ),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _sortBy = newValue;
              });
              _updateSort();
            }
          },
          items: const [
            DropdownMenuItem(
              value: 'popularity',
              child: Text(
                'Popularity',
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
            DropdownMenuItem(
              value: 'rating',
              child: Text(
                'Rating',
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
            DropdownMenuItem(
              value: 'release_date',
              child: Text(
                'Release Date',
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
            DropdownMenuItem(
              value: 'title',
              child: Text(
                'Title',
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return CustomTextField(
      borderDelete: true,
      obscureText: false,
      fillColor: const Color(0xff1A1A1A),
      isDense: true,
      onTap: () {},
      validator: (val) => null,
      text: MyText.searchMoodBox,
      heintStyle: const TextStyle(
        color: Color(0xff797979),
        fontSize: 13,
      ),
      textStyle: MyStyles.title24White400.copyWith(
        fontSize: 13,
        color: Colors.white,
      ),
      textAlign: TextAlign.start,
      controller: _searchController,
      onchanged: (value) {
        // تنفيذ البحث عند تغيير النص
        if (value.trim().isNotEmpty) {
          _debounceTimer?.cancel();
          _debounceTimer = Timer(const Duration(milliseconds: 800), () {
            if (mounted) {
              context.read<SearchCubit>().searchMovies(value);
            }
          });
        } else {
          context.read<SearchCubit>().clearSearch();
        }
      },
      suffix: IconButton(
        icon: const Icon(
          Icons.search,
          color: Color(0xff797979),
        ),
        onPressed: _performSearch,
      ),
    );
  }

  Widget _buildResultsCount() {
    return BlocBuilder<SearchCubit, SearchState>(
      builder: (context, state) {
        if (state is SearchLoaded) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xff1A1A1A),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.search,
                  color: Colors.grey,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'Found ${state.movies.length} results for "${state.query}"',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildSearchResults() {
    return BlocBuilder<SearchCubit, SearchState>(
      builder: (context, state) {
        if (state is SearchInitial) {
          return _buildInitialState();
        } else if (state is SearchLoading) {
          return _buildLoadingState();
        } else if (state is SearchLoaded) {
          return _buildLoadedState(state);
        } else if (state is SearchEmpty) {
          return _buildEmptyState(state.query);
        } else if (state is SearchError) {
          return _buildErrorState(state.message);
        }
        return _buildInitialState();
      },
    );
  }

  Widget _buildInitialState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Search for movies...',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        color: Colors.white,
      ),
    );
  }

  Widget _buildLoadedState(SearchLoaded state) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        // تحميل المزيد عند الوصول لنهاية القائمة
        if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent &&
            state.hasMore) {
          context.read<SearchCubit>().loadMoreResults();
        }
        return false;
      },
      child: ListView.builder(
        itemCount: state.movies.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.movies.length) {
            // Load more indicator
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            );
          }

          return SearchResultItem(movie: state.movies[index]);
        },
      ),
    );
  }

  Widget _buildEmptyState(String query) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'No results found for "$query"',
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _performSearch,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  // Search functionality
  void _performSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      context.read<SearchCubit>().searchMovies(query);
    }
  }

  void _updateSort() {
    final currentFilters = context.read<SearchCubit>().currentFilters;
    final newFilters = currentFilters.copyWith(sortBy: _sortBy);
    context.read<SearchCubit>().updateFilters(newFilters);
  }
}
