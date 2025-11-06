import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/search_result.dart';
import '../models/user.dart';
import '../services/data_service.dart';
import '../services/search_service.dart';

/// Provides the SearchService instance with sample data.
final searchServiceProvider = Provider<SearchService>((ref) {
  final users = DataService.getSampleUsers();
  return SearchService(users);
});

/// Immutable view-model for the search screen.
class SearchState {
  final String query;
  final bool isSearching;
  final List<SearchResult> allResults;
  final List<SearchResult> usernameResults;
  final List<SearchResult> categoryResults;
  final List<String> categories;

  const SearchState({
    this.query = '',
    this.isSearching = false,
    this.allResults = const [],
    this.usernameResults = const [],
    this.categoryResults = const [],
    this.categories = const [],
  });

  SearchState copyWith({
    String? query,
    bool? isSearching,
    List<SearchResult>? allResults,
    List<SearchResult>? usernameResults,
    List<SearchResult>? categoryResults,
    List<String>? categories,
  }) {
    return SearchState(
      query: query ?? this.query,
      isSearching: isSearching ?? this.isSearching,
      allResults: allResults ?? this.allResults,
      usernameResults: usernameResults ?? this.usernameResults,
      categoryResults: categoryResults ?? this.categoryResults,
      categories: categories ?? this.categories,
    );
  }
}

/// Manages debounced search and derived results.
class SearchNotifier extends StateNotifier<SearchState> {
  final SearchService _searchService;
  Timer? _debounceTimer;

  SearchNotifier(this._searchService) : super(const SearchState());

  void onQueryChanged(String value) {
    final newQuery = value.trimLeft();
    state = state.copyWith(query: newQuery);

    _debounceTimer?.cancel();
    if (newQuery.trim().isEmpty) {
      // Clear state immediately on empty query
      state = const SearchState();
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      await _performSearchInternal(newQuery);
    });
  }

  Future<void> _performSearchInternal(String query) async {
    if (query.trim().isEmpty) {
      state = const SearchState();
      return;
    }

    state = state.copyWith(isSearching: true);
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

      state = state.copyWith(
        allResults: results,
        usernameResults: usernameResults,
        categoryResults: categoryResults,
        categories: categories,
        isSearching: false,
      );
    } catch (_) {
      state = state.copyWith(isSearching: false);
    }
  }

  void onCategorySelected(String category) {
    // Immediately reflect the query change and perform search
    state = state.copyWith(query: category);
    _debounceTimer?.cancel();
    _performSearchInternal(category);
  }

  void clear() {
    _debounceTimer?.cancel();
    state = const SearchState();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

final searchNotifierProvider =
    StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  final service = ref.read(searchServiceProvider);
  return SearchNotifier(service);
});


