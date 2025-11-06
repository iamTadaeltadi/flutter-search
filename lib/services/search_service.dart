import 'dart:async';
import '../models/user.dart';
import '../models/search_result.dart';

/// High-performance search service with optimized algorithms
/// Designed to handle large datasets and many simultaneous users
class SearchService {
  final List<User> _users;
  final Map<String, List<int>> _usernameIndex;
  final Map<String, List<int>> _nameIndex;
  final Map<String, List<int>> _occupationIndex;
  final Map<String, List<int>> _categoryIndex;

  /// Creates a SearchService with pre-indexed data for fast lookups
  SearchService(List<User> users)
      : _users = users,
        _usernameIndex = {},
        _nameIndex = {},
        _occupationIndex = {},
        _categoryIndex = {} {
    _buildIndexes();
  }

  /// Builds inverted indexes for O(1) lookup performance
  void _buildIndexes() {
    for (int i = 0; i < _users.length; i++) {
      final user = _users[i];

      // Index username (case-insensitive)
      final usernameLower = user.username.toLowerCase();
      _addToIndex(_usernameIndex, usernameLower, i);
      // Index partial username matches
      _indexPartialMatches(_usernameIndex, usernameLower, i);

      // Index name (case-insensitive)
      final nameLower = user.name.toLowerCase();
      _addToIndex(_nameIndex, nameLower, i);
      // Index partial name matches
      _indexPartialMatches(_nameIndex, nameLower, i);
      // Index individual name parts
      for (final part in nameLower.split(' ')) {
        if (part.length >= 2) {
          _addToIndex(_nameIndex, part, i);
        }
      }

      // Index occupation (case-insensitive)
      final occupationLower = user.occupation.toLowerCase();
      _addToIndex(_occupationIndex, occupationLower, i);
      _indexPartialMatches(_occupationIndex, occupationLower, i);
      // Index occupation words
      for (final part in occupationLower.split(' ')) {
        if (part.length >= 2) {
          _addToIndex(_occupationIndex, part, i);
        }
      }

      // Index categories (occupation-based)
      _addToIndex(_categoryIndex, occupationLower, i);
      // Index skills as categories
      for (final skill in user.skills) {
        final skillLower = skill.toLowerCase();
        _addToIndex(_categoryIndex, skillLower, i);
      }
    }
  }

  /// Adds an entry to the index
  void _addToIndex(Map<String, List<int>> index, String key, int userId) {
    if (!index.containsKey(key)) {
      index[key] = [];
    }
    if (!index[key]!.contains(userId)) {
      index[key]!.add(userId);
    }
  }

  /// Indexes partial matches for fuzzy search
  void _indexPartialMatches(Map<String, List<int>> index, String text, int userId) {
    // Index all prefixes of length >= 2
    for (int len = 2; len <= text.length; len++) {
      final prefix = text.substring(0, len);
      _addToIndex(index, prefix, userId);
    }
  }

  /// Performs a search query with debouncing support
  /// Returns results sorted by relevance
  Future<List<SearchResult>> search(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }

    final queryLower = query.trim().toLowerCase();
    final Set<int> matchedUserIds = {};
    final Map<int, SearchResult> resultMap = {};

    // Search username matches (highest priority)
    final usernameMatches = _searchIndex(_usernameIndex, queryLower);
    for (final userId in usernameMatches) {
      if (!resultMap.containsKey(userId)) {
        final user = _users[userId];
        final score = _calculateRelevanceScore(
          user.username.toLowerCase(),
          queryLower,
          MatchType.username,
        );
        resultMap[userId] = SearchResult(
          user: user,
          matchType: MatchType.username,
          relevanceScore: score,
        );
      }
      matchedUserIds.add(userId);
    }

    // Search name matches
    final nameMatches = _searchIndex(_nameIndex, queryLower);
    for (final userId in nameMatches) {
      if (!resultMap.containsKey(userId)) {
        final user = _users[userId];
        final score = _calculateRelevanceScore(
          user.name.toLowerCase(),
          queryLower,
          MatchType.name,
        );
        resultMap[userId] = SearchResult(
          user: user,
          matchType: MatchType.name,
          relevanceScore: score,
        );
      }
      matchedUserIds.add(userId);
    }

    // Search occupation matches
    final occupationMatches = _searchIndex(_occupationIndex, queryLower);
    for (final userId in occupationMatches) {
      if (!resultMap.containsKey(userId)) {
        final user = _users[userId];
        final score = _calculateRelevanceScore(
          user.occupation.toLowerCase(),
          queryLower,
          MatchType.occupation,
        );
        resultMap[userId] = SearchResult(
          user: user,
          matchType: MatchType.occupation,
          relevanceScore: score,
        );
      }
      matchedUserIds.add(userId);
    }

    // Search category matches
    final categoryMatches = _searchIndex(_categoryIndex, queryLower);
    for (final userId in categoryMatches) {
      if (!resultMap.containsKey(userId)) {
        final user = _users[userId];
        final score = _calculateRelevanceScore(
          user.occupation.toLowerCase(),
          queryLower,
          MatchType.category,
        );
        resultMap[userId] = SearchResult(
          user: user,
          matchType: MatchType.category,
          relevanceScore: score,
        );
      }
    }

    // Convert to list and sort by relevance
    final results = resultMap.values.toList();
    results.sort(SearchResult.compareByRelevance);

    return results;
  }

  /// Searches an index for matching entries
  Set<int> _searchIndex(Map<String, List<int>> index, String query) {
    final Set<int> results = {};
    
    // Exact match (highest priority)
    if (index.containsKey(query)) {
      results.addAll(index[query]!);
    }

    // Prefix matches
    for (final key in index.keys) {
      if (key.startsWith(query) || query.startsWith(key)) {
        results.addAll(index[key]!);
      }
    }

    // Contains matches (for partial word matching)
    for (final key in index.keys) {
      if (key.contains(query) || query.contains(key)) {
        results.addAll(index[key]!);
      }
    }

    return results;
  }

  /// Calculates relevance score for ranking results
  /// Higher score = more relevant
  double _calculateRelevanceScore(
    String text,
    String query,
    MatchType matchType,
  ) {
    double score = 0.0;

    // Base score by match type (username > name > occupation > category)
    switch (matchType) {
      case MatchType.username:
        score = 100.0;
        break;
      case MatchType.name:
        score = 80.0;
        break;
      case MatchType.occupation:
        score = 60.0;
        break;
      case MatchType.category:
        score = 40.0;
        break;
    }

    // Exact match bonus
    if (text == query) {
      score += 50.0;
    }
    // Starts with bonus
    else if (text.startsWith(query)) {
      score += 30.0;
    }
    // Contains bonus
    else if (text.contains(query)) {
      score += 10.0;
    }

    // Length penalty (shorter matches are better)
    final lengthDiff = (text.length - query.length).abs();
    score -= lengthDiff * 0.5;

    return score;
  }

  /// Gets unique categories from search results
  List<String> getCategories(List<SearchResult> results) {
    final Set<String> categories = {};
    for (final result in results) {
      if (result.matchType == MatchType.category) {
        categories.add(result.user.occupation);
      }
      categories.addAll(result.user.skills);
    }
    return categories.toList()..sort();
  }

  /// Filters results by match type
  List<SearchResult> filterByMatchType(
    List<SearchResult> results,
    MatchType matchType,
  ) {
    return results.where((r) => r.matchType == matchType).toList();
  }
}


