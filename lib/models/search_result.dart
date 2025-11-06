import 'user.dart';

class SearchResult {
  final User user;
  final MatchType matchType;
  final double relevanceScore;

  const SearchResult({
    required this.user,
    required this.matchType,
    required this.relevanceScore,
  });

  static int compareByRelevance(SearchResult a, SearchResult b) {
    return b.relevanceScore.compareTo(a.relevanceScore);
  }
}

enum MatchType {
  username,
  name,
  occupation,
  category,
}

