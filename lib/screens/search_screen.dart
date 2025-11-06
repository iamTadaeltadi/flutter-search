import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/search_result.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/user_result_card.dart';
import '../widgets/category_chip.dart';
import '../providers/search_providers.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchNotifierProvider);
    final notifier = ref.read(searchNotifierProvider.notifier);

    // Keep the TextField in sync with provider state
    if (_searchController.text != searchState.query) {
      _searchController.text = searchState.query;
      _searchController.selection = TextSelection.fromPosition(
        TextPosition(offset: _searchController.text.length),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            SearchBarWidget(
              controller: _searchController,
              onChanged: notifier.onQueryChanged,
              onClear: notifier.clear,
            ),

            // Search Results
            Expanded(
              child: searchState.isSearching
                  ? const Center(child: CircularProgressIndicator())
                  : _buildResults(searchState, notifier),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  /// Builds the results view
  Widget _buildResults(SearchState state, SearchNotifier notifier) {
    if (state.query.trim().isEmpty) {
      return const Center(
        child: Text(
          'Start typing to search...',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      );
    }

    if (state.allResults.isEmpty) {
      return const Center(
        child: Text(
          'No results found',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Matching Usernames Section
          if (state.usernameResults.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Matching Usernames (${state.usernameResults.length})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...state.usernameResults.map(
              (result) => UserResultCard(
                result: result,
                onTap: () {
                  // Handle user tap
                },
              ),
            ),
          ],

          // Matching Categories Section
          if (state.categories.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Matching Categories (${state.categories.length})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                children: state.categories.map(
                  (category) => CategoryChip(
                    category: category,
                    onTap: () => notifier.onCategorySelected(category),
                  ),
                ).toList(),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Other Results (name, occupation matches)
          if (state.usernameResults.length < state.allResults.length) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Other Results (${state.allResults.length - state.usernameResults.length})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...() {
              final usernameUserIds = state.usernameResults
                  .map((result) => result.user.id)
                  .toSet();
              return state.allResults
                  .where((r) => !usernameUserIds.contains(r.user.id))
                  .map(
                    (result) => UserResultCard(
                      result: result,
                      onTap: () {
                        // Handle user tap
                      },
                    ),
                  );
            }(),
          ],
        ],
      ),
    );
  }

  /// Builds the bottom navigation bar
  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: 0,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.info_outline),
          label: 'About',
        ),
      ],
    );
  }
}

