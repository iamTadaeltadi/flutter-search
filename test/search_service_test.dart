import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_search_task/services/search_service.dart';
import 'package:flutter_search_task/services/data_service.dart';
import 'package:flutter_search_task/models/search_result.dart';

void main() {
  group('SearchService', () {
    late SearchService service;

    setUp(() {
      service = SearchService(DataService.getSampleUsers());
    });

    test('empty/whitespace query returns empty', () async {
      expect(await service.search(''), isEmpty);
      expect(await service.search('   '), isEmpty);
    });

    test('exact username ranks highly and returns user', () async {
      final results = await service.search('master_carpenter');
      expect(results, isNotEmpty);
      expect(results.first.matchType, MatchType.username);
      expect(results.first.user.username, 'master_carpenter');
    });

    test('name search finds Alice', () async {
      final results = await service.search('Alice');
      expect(results.any((r) => r.user.name.contains('Alice')), isTrue);
    });

    test('category/skills search finds woodworking as category', () async {
      final results = await service.search('Woodworking');
      expect(results.any((r) => r.matchType == MatchType.category), isTrue);
    });

    test('filterByMatchType returns only that type', () async {
      final all = await service.search('car');
      final usernameOnly = service.filterByMatchType(all, MatchType.username);
      expect(usernameOnly.every((r) => r.matchType == MatchType.username), isTrue);
    });

    test('getCategories returns unique sorted list', () async {
      final all = await service.search('Automotive');
      final categoryResults = service.filterByMatchType(all, MatchType.category);
      final categories = service.getCategories(categoryResults);
      expect(categories, isNotEmpty);
      final sorted = [...categories]..sort();
      expect(categories, sorted);
      expect(categories.toSet().length, categories.length);
    });
  });
}
