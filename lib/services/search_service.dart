import 'dart:async';
import 'package:flutter/foundation.dart';
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

    // isolate to prevent UI freezing
    final searchData = _SearchData(
      users: _users,
      usernameIndex: _usernameIndex,
      nameIndex: _nameIndex,
      occupationIndex: _occupationIndex,
      categoryIndex: _categoryIndex,
      query: query.trim().toLowerCase(),
    );

    // Run search in background isolate
    final results = await compute(_performSearchInIsolate, searchData);
    return results;
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

  List<String> getCategorySuggestions(String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.length < 2) {
      return const [];
    }

    final matches = _searchIndexShared(_categoryIndex, normalized);
    final Set<String> categories = {};
    for (final userId in matches) {
      final user = _users[userId];
      categories.add(user.occupation);
      categories.addAll(user.skills);
    }

    final list = categories.toList()..sort();
    return list;
  }
}

class _SearchData {
  final List<User> users;
  final Map<String, Set<int>> usernameIndex;
  final Map<String, Set<int>> nameIndex;
  final Map<String, Set<int>> occupationIndex;
  final Map<String, Set<int>> categoryIndex;
  final String query;

  _SearchData({
    required this.users,
    required this.usernameIndex,
    required this.nameIndex,
    required this.occupationIndex,
    required this.categoryIndex,
    required this.query,
  });
}

List<SearchResult> _performSearchInIsolate(_SearchData data) {
  final queryLower = data.query;
  final Set<int> matchedUserIds = {};
  final Map<int, SearchResult> resultMap = {};

  // Search username index
  final usernameMatches = _searchIndexShared(data.usernameIndex, queryLower);
  for (final userId in usernameMatches) {
    if (!resultMap.containsKey(userId)) {
      final user = data.users[userId];
      final score = _calculateRelevanceScoreInIsolate(
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

  // Search name index
  final nameMatches = _searchIndexShared(data.nameIndex, queryLower);
  for (final userId in nameMatches) {
    if (!resultMap.containsKey(userId)) {
      final user = data.users[userId];
      final score = _calculateRelevanceScoreInIsolate(
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

  // Search occupation index
  final occupationMatches = _searchIndexShared(data.occupationIndex, queryLower);
  for (final userId in occupationMatches) {
    if (!resultMap.containsKey(userId)) {
      final user = data.users[userId];
      final score = _calculateRelevanceScoreInIsolate(
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

  // Search category index
  final categoryMatches = _searchIndexShared(data.categoryIndex, queryLower);
  for (final userId in categoryMatches) {
    if (!resultMap.containsKey(userId)) {
      final user = data.users[userId];
      final score = _calculateRelevanceScoreInIsolate(
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

// fun shared by main and isolate execution)
Set<int> _searchIndexShared(Map<String, Set<int>> index, String query) {
  final Set<int> results = {};
  
  // O(1) direct lookup for exact/prefix matches
  if (index.containsKey(query)) {
    results.addAll(index[query]!);
  }

  if (query.length >= 2) {
    for (final key in index.keys) {
      if (key.length > query.length && key.contains(query)) {
        results.addAll(index[key]!);
      }
    }
  }

  return results;
}

double _calculateRelevanceScoreInIsolate(
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


