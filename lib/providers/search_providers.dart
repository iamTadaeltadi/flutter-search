import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/search_result.dart';
import '../services/data_service.dart';
import '../services/search_service.dart';

final searchServiceProvider = Provider<SearchService>((ref) {
  final users = DataService.getSampleUsers();
  return SearchService(users);
});

class SearchState {
  final String query;
  final List<SearchResult> allResults;
  final List<SearchResult> usernameResults;
  final List<SearchResult> categoryResults;
  final List<String> categories;

  const SearchState({
    this.query = '',
    this.allResults = const [],
    this.usernameResults = const [],
    this.categoryResults = const [],
    this.categories = const [],
  });

  SearchState copyWith({
    String? query,
    List<SearchResult>? allResults,
    List<SearchResult>? usernameResults,
    List<SearchResult>? categoryResults,
    List<String>? categories,
  }) {
    return SearchState(
      query: query ?? this.query,
      allResults: allResults ?? this.allResults,
      usernameResults: usernameResults ?? this.usernameResults,
      categoryResults: categoryResults ?? this.categoryResults,
      categories: categories ?? this.categories,
    );
  }
}

class SearchNotifier extends StateNotifier<AsyncValue<SearchState>> {
  final SearchService _searchService;
  Timer? _debounceTimer;
  String? _lastQuery;

  SearchNotifier(this._searchService)
      : super(const AsyncValue.data(SearchState()));

  void onQueryChanged(String value) {
    final newQuery = value.trimLeft();
    _debounceTimer?.cancel();

    if (newQuery.trim().isEmpty) {
      _lastQuery = null;
      state = const AsyncValue.data(SearchState());
      return;
    }

    final current = state.value ?? const SearchState();
    state = AsyncValue.data(current.copyWith(query: newQuery));

    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      _lastQuery = newQuery;
      await _performSearchInternal(newQuery);
    });
  }

  Future<void> _performSearchInternal(String query) async {
    if (query.trim().isEmpty) {
      state = const AsyncValue.data(SearchState());
      return;
    }

    state = const AsyncLoading<SearchState>().copyWithPrevious(state);
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
      final categories = _searchService.getCategorySuggestions(query);

      state = AsyncValue.data(
        SearchState(
          query: query,
          allResults: results,
          usernameResults: usernameResults,
          categoryResults: categoryResults,
          categories: categories,
        ),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void onCategorySelected(String category) {
    _debounceTimer?.cancel();
    _lastQuery = category;
    final current = state.value ?? const SearchState();
    state = AsyncValue.data(current.copyWith(query: category));
    _performSearchInternal(category);
  }

  void clear() {
    _debounceTimer?.cancel();
    _lastQuery = null;
    state = const AsyncValue.data(SearchState());
  }

  Future<void> retry() async {
    if (_lastQuery == null || _lastQuery!.trim().isEmpty) {
      state = const AsyncValue.data(SearchState());
      return;
    }
    await _performSearchInternal(_lastQuery!);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

final searchNotifierProvider =
    StateNotifierProvider<SearchNotifier, AsyncValue<SearchState>>((ref) {
  final service = ref.read(searchServiceProvider);
  return SearchNotifier(service);
});


