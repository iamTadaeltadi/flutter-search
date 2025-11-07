import 'dart:async';
import '../models/user.dart';
import '../models/search_result.dart';

class SearchService {
  final List<User> _users;
  final Map<String, Set<int>> _usernameIndex;
  final Map<String, Set<int>> _nameIndex;
  final Map<String, Set<int>> _occupationIndex;
  final Map<String, Set<int>> _categoryIndex;

  SearchService(List<User> users)
      : _users = users,
        _usernameIndex = {},
        _nameIndex = {},
        _occupationIndex = {},
        _categoryIndex = {} {
    _buildIndexes();
  }

  void _buildIndexes() {
    for (int i = 0; i < _users.length; i++) {
      final user = _users[i];

      final usernameLower = user.username.toLowerCase();
      _addToIndex(_usernameIndex, usernameLower, i);
      _indexPartialMatches(_usernameIndex, usernameLower, i);

      final nameLower = user.name.toLowerCase();
      _addToIndex(_nameIndex, nameLower, i);
      _indexPartialMatches(_nameIndex, nameLower, i);
      for (final part in nameLower.split(' ')) {
        if (part.length >= 2) {
          _addToIndex(_nameIndex, part, i);
        }
      }

      final occupationLower = user.occupation.toLowerCase();
      _addToIndex(_occupationIndex, occupationLower, i);
      _indexPartialMatches(_occupationIndex, occupationLower, i);
      for (final part in occupationLower.split(' ')) {
        if (part.length >= 2) {
          _addToIndex(_occupationIndex, part, i);
        }
      }

      _addToIndex(_categoryIndex, occupationLower, i);
      for (final skill in user.skills) {
        final skillLower = skill.toLowerCase();
        _addToIndex(_categoryIndex, skillLower, i);
        _indexPartialMatches(_categoryIndex, skillLower, i);
      }
    }
  }

  void _addToIndex(Map<String, Set<int>> index, String key, int userId) {
    index.putIfAbsent(key, () => <int>{}).add(userId);
  }

  void _indexPartialMatches(Map<String, Set<int>> index, String text, int userId) {
    for (int len = 2; len <= text.length; len++) {
      final prefix = text.substring(0, len);
      _addToIndex(index, prefix, userId);
    }
  }

  Future<List<SearchResult>> search(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }

    final queryLower = query.trim().toLowerCase();
    final Set<int> matchedUserIds = {};
    final Map<int, SearchResult> resultMap = {};

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

    final results = resultMap.values.toList();
    results.sort(SearchResult.compareByRelevance);

    return results;
  }

  Set<int> _searchIndex(Map<String, Set<int>> index, String query) {
    final Set<int> results = {};
    
    // O(1) direct lookup for exact/prefix matches - FIXED O(n) bug
    // Since we index all prefixes, the query itself is in the index if it matches
    if (index.containsKey(query)) {
      results.addAll(index[query]!);
    }

    // For substring matches where query appears in the middle of a longer key
    // (e.g., searching "penter" in "carpenter"), we need to check longer keys
    // This is still O(n) but optimized: only checks keys longer than query
    // and limited to queries of length 3+ to avoid too many results
    if (query.length >= 3) {
      for (final key in index.keys) {
        if (key.length > query.length && key.contains(query) && !key.startsWith(query)) {
          results.addAll(index[key]!);
        }
      }
    }

    return results;
  }

  double _calculateRelevanceScore(
    String text,
    String query,
    MatchType matchType,
  ) {
    double score = 0.0;

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

    if (text == query) {
      score += 50.0;
    }
    else if (text.startsWith(query)) {
      score += 30.0;
    }
    else if (text.contains(query)) {
      score += 10.0;
    }

    final lengthDiff = (text.length - query.length).abs();
    score -= lengthDiff * 0.5;

    return score;
  }

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

  List<SearchResult> filterByMatchType(
    List<SearchResult> results,
    MatchType matchType,
  ) {
    return results.where((r) => r.matchType == matchType).toList();
  }
}


