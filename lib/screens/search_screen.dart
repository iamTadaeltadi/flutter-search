import 'dart:async';
import 'package:flutter/material.dart';
import '../models/search_result.dart';
import '../models/user.dart';
import '../services/search_service.dart';
import '../services/data_service.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/user_result_card.dart';
import '../widgets/category_chip.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final SearchService _searchService = SearchService(DataService.getSampleUsers());
  Timer? _debounceTimer;

  List<SearchResult> _allResults = [];
  List<SearchResult> _usernameResults = [];
  List<SearchResult> _categoryResults = [];
  List<String> _categories = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer!.cancel();
    }

    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _performSearch(_searchController.text);
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _allResults = [];
        _usernameResults = [];
        _categoryResults = [];
        _categories = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final results = await _searchService.search(query);

      final usernameResults = _searchService.filterByMatchType(
        results,
        MatchType.username,
      );
      final categoryResults = _searchService.filterByMatchType(
        results,
        MatchType.category,
      );

      final categories = _searchService.getCategories(categoryResults);

      setState(() {
        _allResults = results;
        _usernameResults = usernameResults;
        _categoryResults = categoryResults;
        _categories = categories;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Search error: $e')),
        );
      }
    }
  }

  /// Handles category selection
  void _onCategorySelected(String category) {
    _searchController.text = category;
    _performSearch(category);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            SearchBarWidget(
              controller: _searchController,
              onChanged: (_) {
                // Search is handled by controller listener with debouncing
              },
              onClear: () {
                setState(() {
                  _allResults = [];
                  _usernameResults = [];
                  _categoryResults = [];
                  _categories = [];
                });
              },
            ),

            // Search Results
            Expanded(
              child: _isSearching
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : _buildResults(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  /// Builds the results view
  Widget _buildResults() {
    if (_searchController.text.trim().isEmpty) {
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

    if (_allResults.isEmpty) {
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
          if (_usernameResults.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Matching Usernames (${_usernameResults.length})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ..._usernameResults.map(
              (result) => UserResultCard(
                result: result,
                onTap: () {
                  // Handle user tap
                },
              ),
            ),
          ],

          // Matching Categories Section
          if (_categories.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Matching Categories (${_categories.length})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                children: _categories.map(
                  (category) => CategoryChip(
                    category: category,
                    onTap: () => _onCategorySelected(category),
                  ),
                ).toList(),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Other Results (name, occupation matches)
          if (_usernameResults.length < _allResults.length) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Other Results (${_allResults.length - _usernameResults.length})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...() {
              final usernameUserIds = _usernameResults
                  .map((result) => result.user.id)
                  .toSet();
              return _allResults
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

